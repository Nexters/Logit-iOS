//
//  SSEClient.swift
//  Logit
//
//  Created by 임재현 on 2/4/26.
//

import Foundation

protocol SSEClient {
    func stream(
        endpoint: Endpoint,
        body: Encodable?
    ) -> AsyncThrowingStream<ChatSSEEvent, Error>
}


class DefaultSSEClient: SSEClient {
    private let baseURL: String
    private let tokenManager: TokenManager
    private let timeoutInterval: TimeInterval
    
    init(
        baseURL: String = Config.baseURL,
        tokenManager: TokenManager = .shared,
        timeoutInterval: TimeInterval = 120  // 기본 2분
    ) {
        self.baseURL = baseURL
        self.tokenManager = tokenManager
        self.timeoutInterval = timeoutInterval
    }
    
    func stream(
        endpoint: Endpoint,
        body: Encodable?
    ) -> AsyncThrowingStream<ChatSSEEvent, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    // 1. URLRequest 생성
                    var request = try createURLRequest(endpoint: endpoint, body: body)
                    
                    // 2. 타임아웃 설정
                    request.timeoutInterval = timeoutInterval
                    
                    // 3. 토큰 추가
                    if let accessToken = tokenManager.accessToken {
                        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                    }
                    
                    // 4. URLSession.bytes로 스트리밍
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    
                    // 5. HTTP 응답 검증
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIError.invalidResponse
                    }
                    
                    // 6. 상태코드별 처리 (연결 전 에러)
                    switch httpResponse.statusCode {
                    case 200...299:
                        break  // 정상 → 스트리밍 진행
                        
                    case 400:
                        throw APIError.badRequest(message: "잘못된 요청입니다.")
                        
                    case 401:
                        throw APIError.unauthorized(message: "인증이 필요합니다.")
                        
                    case 403:
                        throw APIError.forbidden(message: "접근 권한이 없습니다.")
                        
                    case 404:
                        throw APIError.notFound(message: "리소스를 찾을 수 없습니다.")
                        
                    case 422:
                        throw APIError.validationError(errors: [
                            ValidationError(
                                from: ValidationErrorDetail(
                                    loc: ["unknown"],
                                    msg: "요청 데이터를 확인해주세요.",
                                    type: "validation_error"
                                )
                            )
                        ])
                        
                    case 429:
                        throw APIError.unknown(
                            statusCode: 429,
                            message: "일일 채팅 제한을 초과했습니다."
                        )
                        
                    case 500...599:
                        throw APIError.serverError(message: "서버 오류가 발생했습니다.")
                        
                    default:
                        throw APIError.unknown(statusCode: httpResponse.statusCode, message: nil)
                    }
                    
                    // 7. 스트리밍 데이터 파싱
                    var receivedDone = false
                    var buffer = ""
                    var byteBuffer = Data()
                    
                    for try await byte in bytes {
                        byteBuffer.append(byte)  //  바이트 누적
                        
                        // UTF-8로 디코딩 시도
                        if let decodedString = String(data: byteBuffer, encoding: .utf8) {
                            buffer.append(decodedString)
                            byteBuffer.removeAll()  //  성공하면 버퍼 비우기
                        }
                        // 디코딩 실패하면 계속 바이트 누적 (멀티바이트 문자 중간)
                        
                        // SSE 이벤트는 \n\n으로 구분됨
                        if buffer.hasSuffix("\n\n") {
                            let eventData = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            if let event = parseSSEEvent(eventData) {
                                continuation.yield(event)
                                
                                // done 이벤트 받으면 정상 종료
                                if case .done = event {
                                    receivedDone = true
                                    continuation.finish()
                                    return
                                }
                                
                                // error 이벤트 받으면 에러 종료
                                if case .error(let message) = event {
                                    continuation.finish(throwing: APIError.serverError(message: message))
                                    return
                                }
                            }
                            
                            buffer = ""
                        }
                    }
                    
                    // 8. done 없이 종료되면 비정상 종료
                    if !receivedDone {
                        continuation.finish(throwing: APIError.serverError(
                            message: "스트리밍이 비정상 종료되었습니다."
                        ))
                    }
                    
                } catch let error as URLError where error.code == .timedOut {
                    // 타임아웃 에러 명시적 처리
                    continuation.finish(throwing: APIError.serverError(
                        message: "응답 시간이 초과되었습니다. 다시 시도해주세요."
                    ))
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func createURLRequest(
        endpoint: Endpoint,
        body: Encodable?
    ) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        
        // Body 추가
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        return request
    }
    
    private func parseSSEEvent(_ eventData: String) -> ChatSSEEvent? {
        // "data: " 접두사 제거
        guard eventData.hasPrefix("data: ") else {
            return nil
        }
        
        let jsonString = eventData.replacingOccurrences(of: "data: ", with: "")
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        
        // type 필드로 어떤 이벤트인지 판단
        if let contentEvent = try? decoder.decode(ChatContentEvent.self, from: data),
           contentEvent.type == "content" {
            return .content(contentEvent.content)
        }
        
        if let doneEvent = try? decoder.decode(ChatDoneEvent.self, from: data),
           doneEvent.type == "done" {
            return .done(
                chatId: doneEvent.chatId,
                isDraft: doneEvent.isDraft,
                remainingChats: doneEvent.remainingChats
            )
        }
        
        if let errorEvent = try? decoder.decode(ChatErrorEvent.self, from: data),
           errorEvent.type == "error" {
            return .error(errorEvent.message)
        }
        
        return nil
    }
}

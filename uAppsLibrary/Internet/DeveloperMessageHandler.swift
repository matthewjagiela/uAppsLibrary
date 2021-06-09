//
//  DeveloperMessageHandler.swift
//  uAppsLibrary
//
//  Created by Matthew Jagiela on 1/15/21.
#if canImport(Combine)
import Combine
#endif

public enum App {
    case uTime
    case uSurf
}
public class DeveloperMessage {
    fileprivate let jsonURL = URL(string: "https://raw.githubusercontent.com/matthewjagiela/uApps-JSON/messageme/uAppsInfo.json")
    public init() {}

    @available(iOS 15, *)
    public func asyncDeveloperMessage() async throws -> Message {
        guard let jsonURL = self.jsonURL else { throw InternetJSONError.genericError }
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: jsonURL))
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw InternetJSONError.dataError}
        let decoder = JSONDecoder()
        guard let message = try? decoder.decode(Message.self, from: data) else { throw InternetJSONError.decodeError }
        return message
    }
    
    #if canImport(Combine)
    @available(iOS 13.0, *)
    public func developerMessage() -> Future<Message, InternetJSONError> {
        return Future { promise in
            if let jsonURL = self.jsonURL {
                URLSession.shared.dataTask(with: jsonURL) { data, _, error in
                    if let error = error {
                        promise(.failure(.fetchError(error)))
                    } else {
                        if let fetchedData = data {
                            let decoder = JSONDecoder()
                            do {
                                let developerMessage = try decoder.decode(Message.self, from: fetchedData)
                                promise(.success(developerMessage))
                            } catch {
                                promise(.failure(.decodeError))
                            }
                        }
                    }
                }.resume()
            } else {
                return promise(.failure(.genericError))
            }
        }
    }
    #endif
    public func legacyDeveloperMessage(completion: @escaping(Message) -> Void) {
        var developerMessage: Message?
        if let jsonURL = self.jsonURL {
            URLSession.shared.dataTask(with: jsonURL) { data, _, error in
                if let fetchedData = data {
                    let decoder = JSONDecoder()
                    do {
                        developerMessage = try decoder.decode(Message.self, from: fetchedData)
                        if let developerMessage = developerMessage {
                            completion(developerMessage)
                        } else {
                            completion(Message())
                        }
                        
                    } catch {
                        print("An Error Has Occured \(error)")
                        completion(Message())
                    }
                }
            }.resume()
        }
    }
}

open class Message: NSObject, Decodable {
    public var uTimeMessage: MessageDetails?
    public var uSurfMessage: MessageDetails?
    enum CodingKeys: String, CodingKey {
        case message = "messages"
        case uTimeMessage = "uTime"
        case uSurfMessage = "uSurf"
    }
    override init() {
        super.init()
    }
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nestedContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .message)
        uTimeMessage = try nestedContainer.decode(MessageDetails.self, forKey: .uTimeMessage)
        uSurfMessage = try nestedContainer.decode(MessageDetails.self, forKey: .uSurfMessage)
    }
}

open class MessageDetails: Decodable {
    public var announcementNumber: Int
    public var message: String
    public var messageActive: Bool
    enum CodingKeys: String, CodingKey {
        case announcementNumber = "Announcement_Number"
        case message = "Message"
        case messageActive = "Message_Active"
    }
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        announcementNumber = try container.decode(Int.self, forKey: .announcementNumber)
        message = try container.decode(String.self, forKey: .message)
        messageActive = try container.decode(Bool.self, forKey: .messageActive)
    }
}

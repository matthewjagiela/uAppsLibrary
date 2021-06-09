//
//  InternetLabelsManager.swift
//  uAppsLibrary
//
//  Created by Matthew Jagiela on 1/13/21.
//
#if canImport(Combine)
import Combine
#endif

public enum InternetJSONError: Error {
    case fetchError(Error)
    case decodeError
    case genericError
    case dataError
}

public class InternetLabelsManager {
    public init() {
        //used to make discoverable
    }
    /**
     Used for devices that can handle iOS 13+
     */
    #if canImport(Combine)
    @available(iOS 13.0, *)
    public func fetchLabels() -> Future<InternetInformation, InternetJSONError> {
        return Future { promise in
            if let jsonURL = URL(string: "https://raw.githubusercontent.com/matthewjagiela/uApps-JSON/master/uAppsInfo.json") {
                URLSession.shared.dataTask(with: jsonURL) { data, _, error in
                    if let error = error {
                        promise(.failure(.fetchError(error)))
                    } else {
                        if let fetchedData = data {
                            let decoder = JSONDecoder()
                            do {
                                let internetInfo = try decoder.decode(InternetInformation.self, from: fetchedData)
                                promise(.success(internetInfo))
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
    /**
     Used for devices using iOS 15 + 
     */
    @available(iOS 15.0, *)
    public func asyncInternetLabels() async throws -> InternetInformation {
        guard let jsonURL = URL(string: "https://raw.githubusercontent.com/matthewjagiela/uApps-JSON/master/uAppsInfo.json") else { throw InternetJSONError.genericError }
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: jsonURL))
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw InternetJSONError.dataError}
        let decoder = JSONDecoder()
        guard let internetInfo = try? decoder.decode(InternetInformation.self, from: data) else { throw InternetJSONError.decodeError }
        return internetInfo
    }
    
    /**
     Call with iOS 12 and lower only for getting relevant information
     */
    public func legacyFetchLabels(completion: @escaping(InternetInformation) -> Void) {
        var internetInfo: InternetInformation?
        if let jsonURL = URL(string: "https://raw.githubusercontent.com/matthewjagiela/uApps-JSON/master/uAppsInfo.json") {
            URLSession.shared.dataTask(with: jsonURL) { data, _, error in
                if let fetchedData = data {
                    let decoder = JSONDecoder()
                    do {
                        internetInfo = try decoder.decode(InternetInformation.self, from: fetchedData)
                        if let internetLabelsFilled = internetInfo {
                            completion(internetLabelsFilled)
                        } else {
                            completion(InternetInformation())
                        }
                        
                    } catch {
                        print("An Error Has Occured \(error)")
                        completion(InternetInformation())
                    }
                }
            }.resume()
        }
    }
}

open class InternetInformation: NSObject, Decodable {
    public var uTimeVersion: String?
    public var uAppsNews: String?
    public var uTimeMacVersion: String?
    public var uSurfVersion: String?
    public var uFailVersion: String?
    enum CodingKeys: String, CodingKey {
        case uTimeVersion = "uTime_Universal"
        case uSurfVersion = "uSurf_Version"
        case uFailVersion = "uFail_Version"
        case uAppsNews =  "uApps_News"
        case uTimeMacVersion = "uTime_macOS"
    }
    override init() {
        super.init()
    }
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uTimeVersion = try? container.decode(String.self, forKey: .uTimeVersion)
        uSurfVersion = try? container.decode(String.self, forKey: .uSurfVersion)
        uFailVersion = try? container.decode(String.self, forKey: .uFailVersion)
        uAppsNews = try? container.decode(String.self, forKey: .uAppsNews)
        uTimeMacVersion = try? container.decodeIfPresent(String.self, forKey: .uTimeMacVersion)
    }
}

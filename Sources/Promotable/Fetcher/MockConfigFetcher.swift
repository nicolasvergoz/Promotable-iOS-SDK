import Foundation

/// Example implementation of ConfigFetcher that loads from a local sample file
struct MockConfigFetcher: ConfigFetcher {
  enum MockError: Error {
    case missingJSONFile
    case decodingFailed(Error)
    case schemaVersionMismatch(received: String, required: String)
  }
  
  let requiredSchemaVersion: String
  
  init(requiredSchemaVersion: String = "0.1.0") {
    self.requiredSchemaVersion = requiredSchemaVersion
  }
  
  func fetchConfig() async throws -> PromotionsResponse {
    // Load from the local PromotionsSample.json file
    guard let fileUrl = Bundle.module.url(forResource: "PromotionsSample", withExtension: "json") else {
      throw MockError.missingJSONFile
    }
    
    do {
      let data = try Data(contentsOf: fileUrl)
      
      // First, parse the JSON to check schema version
      if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
         let schemaVersion = json["schemaVersion"] as? String {
        
        // Validate schema version
        guard schemaVersion == requiredSchemaVersion else {
          throw ConfigError.schemaVersionMismatch(received: schemaVersion, required: requiredSchemaVersion)
        }
        
        // Version is valid, proceed with full decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(PromotionsResponse.self, from: data)
      } else {
        throw ConfigError.invalidResponse
      }
    } catch let error as ConfigError {
      throw error
    } catch let decodingError {
      throw MockError.decodingFailed(decodingError)
    }
  }
}

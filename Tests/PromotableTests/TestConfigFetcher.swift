import Foundation
@testable import Promotable

/// Test implementation of ConfigFetcher
/// Uses a JSON string to provide test configuration
struct TestConfigFetcher: ConfigFetcher {
  let requiredSchemaVersion: String
  let json: String
  
  init(json: String, requiredSchemaVersion: String = "0.1.0") {
    self.json = json
    self.requiredSchemaVersion = requiredSchemaVersion
  }
  // Legacy fetchConfig method removed
  
  func fetchConfig() async throws -> PromotionsResponse {
    // Load from the test bundle's JSON string
    guard let data = json.data(using: .utf8) else {
      throw TestError.decoding
    }
    
    // First, parse the JSON to check schema version
    do {
      if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
         let schemaVersion = json["schemaVersion"] as? String {
        
        // Validate schema version
        guard schemaVersion == requiredSchemaVersion else {
          throw ConfigError.schemaVersionMismatch(received: schemaVersion, required: requiredSchemaVersion)
        }
        
        // Version is valid, proceed with full decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Decode using the promotions format
        do {
          return try decoder.decode(PromotionsResponse.self, from: data)
        } catch {
          throw TestError.decoding
        }
      } else {
        throw ConfigError.invalidResponse
      }
    } catch let error as ConfigError {
      throw error
    } catch {
      throw TestError.decoding
    }
  }
  
  // Legacy helper methods removed

  // Helper method for date formatting
  private func isoDate(_ string: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    return formatter.date(from: string)
  }
}

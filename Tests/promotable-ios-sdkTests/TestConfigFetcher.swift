import Foundation
@testable import promotable_ios_sdk

/// Test implementation of ConfigFetcher
/// Uses the same approach as MockConfigFetcher but adapts for the test environment
struct TestConfigFetcher: ConfigFetcher {
  let requiredSchemaVersion: String
  let json: String
  
  init(json: String, requiredSchemaVersion: String = "0.1.0") {
    self.json = json
    self.requiredSchemaVersion = requiredSchemaVersion
  }
  
  func fetchConfig() async throws -> CampaignsResponse {
    // Load from the test bundle's CampaignsSample.json file
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
        
        do {
          return try decoder.decode(CampaignsResponse.self, from: data)
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

  // Helper method for date formatting
  private func isoDate(_ string: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    return formatter.date(from: string)
  }
}

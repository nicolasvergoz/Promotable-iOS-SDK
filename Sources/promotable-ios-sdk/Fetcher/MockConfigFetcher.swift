import Foundation

/// Example of a custom ConfigFetcher implementation that loads from a local file
struct MockConfigFetcher: ConfigFetcher {
  enum MockError: Error {
    case missingJSONFile
    case decodingFailed(Error)
  }
  
  func fetchConfig() async throws -> CampaignsResponse {
    // Load from the local CampaignsSample.json file
    guard let fileUrl = Bundle.module.url(forResource: "CampaignsSample", withExtension: "json") else {
      throw MockError.missingJSONFile
    }
    
    do {
      let data = try Data(contentsOf: fileUrl)
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      
      return try decoder.decode(CampaignsResponse.self, from: data)
    } catch let decodingError {
      throw MockError.decodingFailed(decodingError)
    }
  }
}

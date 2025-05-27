import Foundation

/// Default implementation of the ConfigFetcher protocol
/// Provides a simple way to fetch campaign configuration from a URL
struct DefaultConfigFetcher: ConfigFetcher {
  private let configURL: URL
  private let urlSession: URLSession
  
  /// Initializes a new instance of DefaultConfigFetcher
  /// - Parameters:
  ///   - configURL: The URL to fetch the campaign configuration from
  ///   - urlSession: The URLSession to use for fetching (defaults to shared)
  init(configURL: URL, urlSession: URLSession = .shared) {
    self.configURL = configURL
    self.urlSession = urlSession
  }
  
  func fetchConfig() async throws -> CampaignsResponse {
    do {
      let (data, response) = try await urlSession.data(from: configURL)
      
      guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
        throw ConfigError.invalidResponse
      }
      
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      
      do {
        return try decoder.decode(CampaignsResponse.self, from: data)
      } catch {
        throw ConfigError.decodingFailed(error)
      }
    } catch let error as ConfigError {
      throw error
    } catch {
      throw ConfigError.networkError(error)
    }
  }
}

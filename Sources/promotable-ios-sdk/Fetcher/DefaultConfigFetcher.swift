import Foundation

/// Default implementation of the ConfigFetcher protocol
/// Provides a simple way to fetch campaign configuration from a URL
public struct DefaultConfigFetcher: ConfigFetcher {
  public let requiredSchemaVersion: String
  private let configURL: URL
  private let urlSession: URLSession
  
  /// Initializes a new instance of DefaultConfigFetcher
  /// - Parameters:
  ///   - configURL: The URL to fetch the campaign configuration from
  ///   - urlSession: The URLSession to use for fetching (defaults to shared)
  ///   - requiredSchemaVersion: The schema version this fetcher expects and can handle
  public init(configURL: URL, urlSession: URLSession = .shared, requiredSchemaVersion: String) {
    self.configURL = configURL
    self.urlSession = urlSession
    self.requiredSchemaVersion = requiredSchemaVersion
  }
  
  public func fetchConfig() async throws -> CampaignsResponse {
    do {
      let (data, response) = try await urlSession.data(from: configURL)
      guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
        throw ConfigError.invalidResponse
      }

      // Parse the JSON data to get the schema version
      guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let schemaVersion = json["schemaVersion"] as? String else {
        throw ConfigError.invalidResponse
      }

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
        throw ConfigError.decodingFailed(error)
      }
    } catch let error as ConfigError {
      throw error
    } catch {
      throw ConfigError.networkError(error)
    }
  }
}

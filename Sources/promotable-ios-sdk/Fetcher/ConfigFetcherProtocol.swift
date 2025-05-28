import Foundation

/// Protocol defining the requirements for fetching campaign configuration
protocol ConfigFetcher: Sendable {
  /// The required schema version that this fetcher can handle
  var requiredSchemaVersion: String { get }
  
  /// Fetches the campaign configuration from a remote source
  /// - Returns: A decoded CampaignsResponse object
  /// - Throws: ConfigError.schemaVersionMismatch if the schema version doesn't match the required version
  func fetchConfig() async throws -> CampaignsResponse
}

/// Errors that can occur during campaign configuration fetching
enum ConfigError: Error {
  /// The server returned an invalid response
  case invalidResponse
  /// Failed to decode the JSON response
  case decodingFailed(Error)
  /// Network error occurred
  case networkError(Error)
  /// Schema version mismatch between required and received versions
  case schemaVersionMismatch(received: String, required: String)
}

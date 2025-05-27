import Foundation

/// Protocol defining the requirements for fetching campaign configuration
protocol ConfigFetcher: Sendable {
  /// Fetches the campaign configuration from a remote source
  /// - Returns: A decoded CampaignsResponse object
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
}

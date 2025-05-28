import Foundation

/// Protocol for tracking cumulative display statistics that persist across configuration changes
public protocol CampaignStorageProtocol {
  var campaignCount: [String: Int] { get set }
  var promotionCount: [String: Int] { get set }
  
  /// Increment the display count for a campaign and promotion
  /// - Parameters:
  ///   - campaignId: Unique identifier for the campaign
  ///   - promotionId: Unique identifier for the promotion
  func incrementDisplayCount(campaignId: String, promotionId: String)
  
  /// Get the display count for a specific campaign
  /// - Parameter id: Campaign identifier
  /// - Returns: Number of times the campaign has been displayed
  func getCampaignDisplayCount(for id: String) -> Int
  
  /// Get the display count for a specific promotion
  /// - Parameter id: Promotion identifier
  /// - Returns: Number of times the promotion has been displayed
  func getPromotionDisplayCount(for id: String) -> Int
  
  /// Reset all balancing counters
  func reset()
}

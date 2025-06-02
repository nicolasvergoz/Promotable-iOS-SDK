import Foundation

/// Protocol for tracking display statistics that persist across configuration changes
public protocol PromotionStorageProtocol {
  var promotionCount: [String: Int] { get set }
  
  /// Increment the display count for a promotion
  /// - Parameter promotionId: Unique identifier for the promotion
  func incrementDisplayCount(promotionId: String)
  
  /// Get the display count for a specific promotion
  /// - Parameter id: Promotion identifier
  /// - Returns: Number of times the promotion has been displayed
  func getPromotionDisplayCount(for id: String) -> Int
  
  /// Reset all counters
  func reset()
}

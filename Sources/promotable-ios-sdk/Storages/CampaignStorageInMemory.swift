import Foundation

/// A simple in-memory implementation of promotion storage
/// Stores promotion display counts in memory dictionary
final class CampaignStorageInMemory: CampaignStorageProtocol {
  var promotionCount: [String : Int] = [:]
  
  func incrementDisplayCount(promotionId: String) {
    promotionCount[promotionId, default: 0] += 1
  }
  
  func getPromotionDisplayCount(for id: String) -> Int {
    return promotionCount[id, default: 0]
  }
  
  func reset() {
    promotionCount = [:]
  }
}

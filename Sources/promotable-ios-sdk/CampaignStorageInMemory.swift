import Foundation

final class InMemoryCampaignStorage: CampaignStorageProtocol {
  var campaignDisplayCounts: [String: Int] = [:]
  var promotionDisplayCounts: [String: Int] = [:]
  
  func incrementDisplayCount(campaignId: String, promotionId: String) {
    campaignDisplayCounts[campaignId, default: 0] += 1
    promotionDisplayCounts[promotionId, default: 0] += 1
  }
  
  func getCampaignDisplayCount(for id: String) -> Int {
    return campaignDisplayCounts[id, default: 0]
  }
  
  func getPromotionDisplayCount(for id: String) -> Int {
    return promotionDisplayCounts[id, default: 0]
  }
  
  func reset() {
    campaignDisplayCounts = [:]
    promotionDisplayCounts = [:]
  }
}

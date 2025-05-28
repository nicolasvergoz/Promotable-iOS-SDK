import Foundation

final class CampaignStorageInMemory: CampaignStorageProtocol {
  var campaignCount: [String : Int] = [:]
  var promotionCount: [String : Int] = [:]
  
  func incrementDisplayCount(campaignId: String, promotionId: String) {
    campaignCount[campaignId, default: 0] += 1
    promotionCount[promotionId, default: 0] += 1
  }
  
  func getCampaignDisplayCount(for id: String) -> Int {
    return campaignCount[id, default: 0]
  }
  
  func getPromotionDisplayCount(for id: String) -> Int {
    return promotionCount[id, default: 0]
  }
  
  func reset() {
    campaignCount = [:]
    promotionCount = [:]
  }
}

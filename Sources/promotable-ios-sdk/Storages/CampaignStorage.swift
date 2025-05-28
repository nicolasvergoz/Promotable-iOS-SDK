import Foundation


/// Implementation of CampaignStorageProtocol for tracking display balancing in memory
/// These counts are reset when campaign configuration changes
final class BalancingCampaignStorage: CampaignStorageProtocol {
  private let campaignsKey = "com.promotable.sdk.balancingCampaignCounts"
  private let promotionsKey = "com.promotable.sdk.balancingPromotionCounts"
  
  var campaignCount: [String: Int] = [:]
  var promotionCount: [String: Int] = [:]
  
  init() {
    load()
  }
  
  private func load() {
    if let data = UserDefaults.standard.data(forKey: campaignsKey),
       let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
      campaignCount = decoded
    }
    if let data = UserDefaults.standard.data(forKey: promotionsKey),
       let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
      promotionCount = decoded
    }
  }
  
  private func save() {
    if let campaignData = try? JSONEncoder().encode(campaignCount) {
      UserDefaults.standard.set(campaignData, forKey: campaignsKey)
    }
    
    if let promotionData = try? JSONEncoder().encode(promotionCount) {
      UserDefaults.standard.set(promotionData, forKey: promotionsKey)
    }
  }
  
  func incrementDisplayCount(campaignId: String, promotionId: String) {
    campaignCount[campaignId, default: 0] += 1
    promotionCount[promotionId, default: 0] += 1
    save()
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
    UserDefaults.standard.removeObject(forKey: campaignsKey)
    UserDefaults.standard.removeObject(forKey: promotionsKey)
  }
}

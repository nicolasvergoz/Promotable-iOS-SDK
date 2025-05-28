import Foundation

/// Persistent storage for cumulative campaign and promotion display statistics
final class CampaignStorageCumulative: CampaignStorageProtocol {
  var campaignCount: [String : Int] = [:]
  var promotionCount: [String : Int] = [:]
  
  private let campaignsKey = "com.promotable.sdk.cumulativecampaignCount"
  private let promotionsKey = "com.promotable.sdk.cumulativepromotionCount"
  
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
    // No need to reset for the moment
  }
}

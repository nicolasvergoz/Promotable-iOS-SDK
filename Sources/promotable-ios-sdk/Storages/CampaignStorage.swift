import Foundation


/// Implementation of CampaignStorageProtocol for tracking display balancing in memory
/// These counts are reset when campaign configuration changes
public final class BalancingCampaignStorage: CampaignStorageProtocol {
  private let campaignsKey = "com.promotable.sdk.balancingCampaignCounts"
  private let promotionsKey = "com.promotable.sdk.balancingPromotionCounts"
  
  public var campaignCount: [String: Int] = [:]
  public var promotionCount: [String: Int] = [:]
  
  public init() {
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
  
  public func incrementDisplayCount(campaignId: String, promotionId: String) {
    campaignCount[campaignId, default: 0] += 1
    promotionCount[promotionId, default: 0] += 1
    save()
  }
  
  public func getCampaignDisplayCount(for id: String) -> Int {
    return campaignCount[id, default: 0]
  }
  
  public func getPromotionDisplayCount(for id: String) -> Int {
    return promotionCount[id, default: 0]
  }
  
  public func reset() {
    campaignCount = [:]
    promotionCount = [:]
    UserDefaults.standard.removeObject(forKey: campaignsKey)
    UserDefaults.standard.removeObject(forKey: promotionsKey)
  }
}

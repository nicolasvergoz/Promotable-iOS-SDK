import Foundation

/// Implementation of CampaignStorageProtocol for tracking display balancing in memory
/// These counts are reset when promotion configuration changes
public final class BalancingCampaignStorage: CampaignStorageProtocol {
  private let promotionsKey = "com.promotable.sdk.balancingPromotionCounts"
  
  public var promotionCount: [String: Int] = [:]
  
  public init() {
    load()
  }
  
  private func load() {
    if let data = UserDefaults.standard.data(forKey: promotionsKey),
       let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
      promotionCount = decoded
    }
  }
  
  private func save() {
    if let promotionData = try? JSONEncoder().encode(promotionCount) {
      UserDefaults.standard.set(promotionData, forKey: promotionsKey)
    }
  }
  
  public func incrementDisplayCount(promotionId: String) {
    promotionCount[promotionId, default: 0] += 1
    save()
  }
  
  public func getPromotionDisplayCount(for id: String) -> Int {
    return promotionCount[id, default: 0]
  }
  
  public func reset() {
    promotionCount = [:]
    UserDefaults.standard.removeObject(forKey: promotionsKey)
  }
}

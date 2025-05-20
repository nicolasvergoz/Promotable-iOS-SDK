import Foundation

protocol CampaignStorageProtocol {
  var campaignDisplayCounts: [String: Int] { get set }
  var promotionDisplayCounts: [String: Int] { get set }
  
  func incrementDisplayCount(campaignId: String, promotionId: String)
  func getCampaignDisplayCount(for id: String) -> Int
  func getPromotionDisplayCount(for id: String) -> Int
  func reset()
}

final class CampaignStorage: CampaignStorageProtocol {
  private let campaignsKey = "com.promotable.sdk.campaignDisplayStats"
  private let promotionsKey = "com.promotable.sdk.promotionDisplayStats"
  
  var campaignDisplayCounts: [String: Int] = [:]
  var promotionDisplayCounts: [String: Int] = [:]
  
  init() {
    load()
  }
  
  private func load() {
    if let data = UserDefaults.standard.data(forKey: campaignsKey),
       let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
      campaignDisplayCounts = decoded
    }
    if let data = UserDefaults.standard.data(forKey: promotionsKey),
       let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
      promotionDisplayCounts = decoded
    }
  }
  
  private func save() {
    UserDefaults.standard.set(campaignDisplayCounts, forKey: campaignsKey)
    UserDefaults.standard.set(promotionDisplayCounts, forKey: promotionsKey)
  }
  
  func incrementDisplayCount(campaignId: String, promotionId: String) {
    campaignDisplayCounts[campaignId, default: 0] += 1
    promotionDisplayCounts[promotionId, default: 0] += 1
    save()
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
    UserDefaults.standard.removeObject(forKey: campaignsKey)
    UserDefaults.standard.removeObject(forKey: promotionsKey)
  }
}

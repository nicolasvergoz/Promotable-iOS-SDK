import Foundation

/// Persistent storage for cumulative promotion display statistics
public final class PromotionStorageCumulative: PromotionStorageProtocol {
  public var promotionCount: [String : Int] = [:]
  
  private let promotionsKey = "com.promotable.sdk.cumulativepromotionCount"
  
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
    // No need to reset for the moment
  }
}

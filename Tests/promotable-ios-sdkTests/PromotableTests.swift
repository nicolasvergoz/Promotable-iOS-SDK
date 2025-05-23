import Testing
import Foundation
@testable import promotable_ios_sdk

enum TestError: Error {
  case missingJSONFile
  case decoding
}

@Suite
struct CampaignsTests {
  let data: Data
  
  init() {
    let fileUrl = Bundle.module.url(forResource: "CampaignsSample", withExtension: "json")!
    
    self.data = try! Data(contentsOf: fileUrl)
  }
  
  func decodeResponse() -> CampaignsResponse? {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try? decoder.decode(CampaignsResponse.self, from: data)
  }
  
  @Test
  func testDecodingCampaignsJSON() {
    guard let response = decodeResponse() else {
      return
    }
    
    #expect(response.campaigns.count == 2)
    
    let campaignA = response.campaigns.first { $0.id == "campaignA" }
    #expect(campaignA?.weight == 1)
    #expect(campaignA?.promotions.count == 1)
    
    let campaignB = response.campaigns.first { $0.id == "campaignB" }
    #expect(campaignB?.weight == 2)
    #expect(campaignB?.promotions.count == 2)
    #expect(campaignB?.promotions.last?.weight == 2)
  }
  
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
  
  @Test("CampaignStorage - increment and reset")
  func testCampaignStorage() {
    let storage = InMemoryCampaignStorage()
    
    storage.incrementDisplayCount(campaignId: "A", promotionId: "A1")
    storage.incrementDisplayCount(campaignId: "A", promotionId: "A1")
    storage.incrementDisplayCount(campaignId: "B", promotionId: "B1")
    
    #expect(storage.getCampaignDisplayCount(for: "A") == 2)
    #expect(storage.getCampaignDisplayCount(for: "B") == 1)
    #expect(storage.getPromotionDisplayCount(for: "A1") == 2)
    #expect(storage.getPromotionDisplayCount(for: "B1") == 1)
    
    storage.reset()
    #expect(storage.getCampaignDisplayCount(for: "A") == 0)
    #expect(storage.getCampaignDisplayCount(for: "B") == 0)
    #expect(storage.getPromotionDisplayCount(for: "A1") == 0)
    #expect(storage.getPromotionDisplayCount(for: "B1") == 0)
  }
  
  @Test("CampaignManager - selects promotion from highest weight campaign")
  @CampaignActor
  func testCampaignSelection() async {
    guard let response = decodeResponse() else {
      return
    }
    
    let storage = InMemoryCampaignStorage()
    let manager = CampaignManager(storage: storage, locale: "en", platform: "ios")
    
    await manager.updateConfiguration(response: response)
    
    var promo: Campaign.Promotion? = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "A1")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "B1")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "B2")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "A1")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "B1")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "B2")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "A1")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "B1")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "B2")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "A1")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "B1")
    
    let stats = manager.getStats()
    print("Display Stats", stats)
  }
  
  // TODO: Test: ignore non-eligible promotions (expired date, unmatched platform/locale)
}

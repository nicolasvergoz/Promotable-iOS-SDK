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
    #expect(campaignB?.promotions.last?.weight == 1)
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
  func testCampaignSelection() async throws {
    let storage = InMemoryCampaignStorage()
    let manager = CampaignManager(storage: storage, locale: "en", platform: "ios")
    
    let jsonResponse: String = try #require(String(data: data, encoding: .utf8))
    try await manager.updateConfiguration(jsonResponse: jsonResponse)
    
    var promo: Campaign.Promotion? = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "a1.acme")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "b1.aven")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "b2.update")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "a1.acme")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "b1.aven")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "b2.update")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "a1.acme")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "b1.aven")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "b2.update")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "a1.acme")
    
    promo = await manager.nextPromotion()
    print("Selected", promo?.id ?? "nil")
    #expect(promo?.id == "b1.aven")
    
    let stats = await manager.getStats()
    print("Display Stats", stats)
  }
  
  // TODO: Test: ignore non-eligible promotions (expired date, unmatched platform/locale)
}

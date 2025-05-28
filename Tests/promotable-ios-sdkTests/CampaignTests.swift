import Testing
import Foundation
@testable import promotable_ios_sdk

/// Tests for campaign models and storage behavior
@Suite
struct CampaignsTests {
  let jsonSample: String
  
  init() {
    let fileUrl = Bundle.module.url(forResource: "CampaignsSample", withExtension: "json")!
    let data = try! Data(contentsOf: fileUrl)
    self.jsonSample = String(data: data, encoding: .utf8)!
  }
  
  /// Tests that the campaign JSON can be properly decoded into model objects
  @Test
  func testDecodingCampaignsJSON() {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let data = jsonSample.data(using: .utf8)!
    
    guard let response = try? decoder.decode(CampaignsResponse.self, from: data) else {
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
  
  /// Tests that the campaign storage correctly increments counts and resets
  @Test("CampaignStorage - increment and reset")
  func testCampaignStorage() {
    let storage = CampaignStorageInMemory()
    
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
    // Create a fresh storage instance for this test
    let manager = CampaignManager(
      balancingStorage: CampaignStorageInMemory(),
      cumulativeStorage: CampaignStorageInMemory()
    )
    
    // Create the mock fetcher that loads from the test bundle
    let mockFetcher = TestConfigFetcher(json: jsonSample)
    try await manager.updateConfig(using: mockFetcher)
    
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
  
  @Test("ConfigFetcher - mock implementation")
  func testConfigFetcher() async throws {
    // Create a campaign manager with a fresh storage instance
    let manager = CampaignManager(
      balancingStorage: CampaignStorageInMemory(),
      cumulativeStorage: CampaignStorageInMemory()
    )
    
    // Create the mock fetcher that loads from the test bundle
    let mockFetcher = TestConfigFetcher(json: jsonSample)
    
    // Update campaign config using the fetcher
    try await manager.updateConfig(using: mockFetcher)
    
    // Verify campaigns were loaded correctly
    #expect(await manager.campaigns.count == 2)
    
    // Verify we can access a campaign promotion using the fetched data
    let promo = await manager.nextPromotion()
    #expect(promo != nil)
    #expect(promo?.id == "a1.acme" || promo?.id == "b1.aven" || promo?.id == "b2.update")
    
    // Verify stats are reset when loading new config
    let stats = await manager.getStats()
    #expect(stats.campaigns.isEmpty == false)
    #expect(stats.promotions.isEmpty == false)
  }
}

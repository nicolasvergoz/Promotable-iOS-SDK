import Testing
import Foundation
@testable import Promotable

/// Tests for promotion models and storage behavior
@Suite
struct PromotionsTests {
  let jsonSample: String
  
  init() {
    let fileUrl = Bundle.module.url(forResource: "CampaignsSample", withExtension: "json")!
    let data = try! Data(contentsOf: fileUrl)
    self.jsonSample = String(data: data, encoding: .utf8)!
  }
  
  /// Tests that the promotions JSON can be properly decoded into model objects
  @Test("Decoding promotions JSON")
  func testDecodingPromotionsJSON() throws {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let data = jsonSample.data(using: .utf8)!
    
    // Try to decode using the new format
    let response = try decoder.decode(PromotionsResponse.self, from: data)
    #expect(response.promotions.count >= 1)
    
    // Verify some promotions properties
    if let promo = response.promotions.first {
      #expect(promo.id.isEmpty == false)
      #expect(promo.action.label.isEmpty == false)
    }
  }
  
  /// Tests that the promotion storage correctly increments counts and resets
  @Test("PromotionStorage - increment and reset")
  func testCampaignStorage() {
    let storage = CampaignStorageInMemory()
    
    storage.incrementDisplayCount(promotionId: "A1")
    storage.incrementDisplayCount(promotionId: "A1")
    storage.incrementDisplayCount(promotionId: "B1")
    
    #expect(storage.getPromotionDisplayCount(for: "A1") == 2)
    #expect(storage.getPromotionDisplayCount(for: "B1") == 1)
    
    storage.reset()
    #expect(storage.getPromotionDisplayCount(for: "A1") == 0)
    #expect(storage.getPromotionDisplayCount(for: "B1") == 0)
  }
  
  @Test("PromotionManager - selects promotion based on weight and targeting")
  func testPromotionSelection() async throws {
    // Create a fresh storage instance for this test
    let manager = CampaignManager(
      balancingStorage: CampaignStorageInMemory(),
      cumulativeStorage: CampaignStorageInMemory()
    )
    
    // Create the mock fetcher that loads from the test bundle
    let mockFetcher = TestConfigFetcher(json: jsonSample)
    try await manager.updateConfig(using: mockFetcher)
    
    var promo: Promotion? = await manager.nextPromotion()
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
    
    // Update promotion config using the fetcher
    try await manager.updateConfig(using: mockFetcher)
    
    // Verify promotions were loaded correctly
    #expect(await manager.promotions.count > 0)
    
    // Verify we can access a promotion using the fetched data
    let promo = await manager.nextPromotion()
    #expect(promo != nil)
    // Check for known promotion IDs from sample file
    #expect(promo?.id == "a1.acme" || promo?.id == "b1.aven" || promo?.id == "b2.update")
    
    // Verify stats are reset when loading new config
    let stats = await manager.getStats()
    #expect(stats.promotions.isEmpty == false)
  }
}

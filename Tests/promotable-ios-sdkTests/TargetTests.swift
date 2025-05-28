import Testing
import Foundation
@testable import promotable_ios_sdk

@Suite
struct TargetTests {
  
  @Test("Promotion Target Eligibility - platforms, languages, and date ranges")
  func testPromotionTargetEligibility() async throws {
    // Create a campaign manager with different platform/language settings for testing
    let manager = CampaignManager(
      balancingStorage: CampaignStorageInMemory(),
      cumulativeStorage: CampaignStorageInMemory(),
      language: "en",
      platform: "ios"
    )
    
    // Create test JSON with various targeting scenarios
    let testJson = """
    {
      "schemaVersion": "0.1.0",
      "campaigns": [
        {
          "id": "no-target",
          "weight": 1,
          "promotions": [{ "id": "promo-no-target", "action": { "label": "Action", "url": "https://example.com" }, "content": [{ "description": "Test content" }] }]
        },
        {
          "id": "ios-only",
          "weight": 1,
          "target": { "platforms": ["ios"] },
          "promotions": [{ "id": "promo-ios", "action": { "label": "Action", "url": "https://example.com" }, "content": [{ "description": "iOS content" }] }]
        },
        {
          "id": "android-only",
          "weight": 1,
          "target": { "platforms": ["android"] },
          "promotions": [{ "id": "promo-android", "action": { "label": "Action", "url": "https://example.com" }, "content": [{ "description": "Android content" }] }]
        },
        {
          "id": "fr-only",
          "weight": 1,
          "target": { "languages": ["fr"] },
          "promotions": [{ "id": "promo-fr", "action": { "label": "Action", "url": "https://example.com" }, "content": [{ "description": "French content" }] }]
        },
        {
          "id": "multi-language",
          "weight": 1,
          "target": { "languages": ["en", "es"] },
          "promotions": [{ "id": "promo-multi-lang", "action": { "label": "Action", "url": "https://example.com" }, "content": [{ "description": "English/Spanish content" }] }]
        },
        {
          "id": "future-campaign",
          "weight": 1,
          "target": { "startDate": "\(ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400)))" },
          "promotions": [{ "id": "promo-future", "action": { "label": "Action", "url": "https://example.com" }, "content": [{ "description": "Future content" }] }]
        },
        {
          "id": "past-campaign",
          "weight": 1,
          "target": { "endDate": "\(ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)))" },
          "promotions": [{ "id": "promo-past", "action": { "label": "Action", "url": "https://example.com" }, "content": [{ "description": "Past content" }] }]
        },
        {
          "id": "active-campaign",
          "weight": 1,
          "target": { 
            "startDate": "\(ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)))",
            "endDate": "\(ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400)))"
          },
          "promotions": [{ "id": "promo-active", "action": { "label": "Action", "url": "https://example.com" }, "content": [{ "description": "Active content" }] }]
        },
        {
          "id": "complex-targeting",
          "weight": 1,
          "target": { 
            "platforms": ["ios"],
            "languages": ["en"],
            "startDate": "\(ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)))",
            "endDate": "\(ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400)))"
          },
          "promotions": [{ "id": "promo-complex", "action": { "label": "Action", "url": "https://example.com" }, "content": [{ "description": "Complex targeting content" }] }]
        }
      ]
    }
    """
    
    // Load the test configuration
    let mockFetcher = TestConfigFetcher(json: testJson)
    try await manager.updateConfig(using: mockFetcher)
    
    // Verify campaigns were loaded correctly
    #expect(await manager.campaigns.count == 9)
    
    // Test with default settings (en, ios)
    var eligibleIds = Set<String>()
    for _ in 0..<20 { // Run multiple times to ensure we see all eligible promotions
      if let promo = await manager.nextPromotion() {
        eligibleIds.insert(promo.id)
      }
    }
    
    // Should include: no-target, ios-only, multi-language, active-campaign, complex-targeting
    // Should exclude: android-only, fr-only, future-campaign, past-campaign
    #expect(eligibleIds.contains("promo-no-target"))
    #expect(eligibleIds.contains("promo-ios"))
    #expect(eligibleIds.contains("promo-multi-lang"))
    #expect(eligibleIds.contains("promo-active"))
    #expect(eligibleIds.contains("promo-complex"))
    #expect(!eligibleIds.contains("promo-android"))
    #expect(!eligibleIds.contains("promo-fr"))
    #expect(!eligibleIds.contains("promo-future"))
    #expect(!eligibleIds.contains("promo-past"))
    
    // Change platform to Android and verify
    await manager.setPlatform("android")
    eligibleIds.removeAll()
    
    for _ in 0..<20 {
      if let promo = await manager.nextPromotion() {
        eligibleIds.insert(promo.id)
      }
    }
    
    #expect(eligibleIds.contains("promo-no-target"))
    #expect(eligibleIds.contains("promo-android"))
    #expect(eligibleIds.contains("promo-multi-lang"))
    #expect(eligibleIds.contains("promo-active"))
    #expect(!eligibleIds.contains("promo-ios"))
    #expect(!eligibleIds.contains("promo-fr"))
    #expect(!eligibleIds.contains("promo-future"))
    #expect(!eligibleIds.contains("promo-past"))
    #expect(!eligibleIds.contains("promo-complex")) // Requires iOS
    
    // Change language to French and verify
    await manager.setPlatform("ios") // Reset platform
    await manager.setLanguage("fr")
    eligibleIds.removeAll()
    
    for _ in 0..<20 {
      if let promo = await manager.nextPromotion() {
        eligibleIds.insert(promo.id)
      }
    }
    
    #expect(eligibleIds.contains("promo-no-target"))
    #expect(eligibleIds.contains("promo-ios"))
    #expect(eligibleIds.contains("promo-fr"))
    #expect(eligibleIds.contains("promo-active"))
    #expect(!eligibleIds.contains("promo-android"))
    #expect(!eligibleIds.contains("promo-multi-lang")) // Only en, es
    #expect(!eligibleIds.contains("promo-future"))
    #expect(!eligibleIds.contains("promo-past"))
    #expect(!eligibleIds.contains("promo-complex")) // Requires en
  }
  
}

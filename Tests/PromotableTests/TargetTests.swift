import Testing
import Foundation
@testable import Promotable

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
    
    // Create test JSON with various targeting scenarios using the new promotion-focused structure
    let testJson = """
    {
      "schemaVersion": "0.1.0",
      "promotions": [
        {
          "id": "promo-no-target", 
          "action": { "label": "Action", "url": "https://example.com" }, 
          "content": [{ "description": "Test content" }],
          "weight": 1
        },
        {
          "id": "promo-ios", 
          "action": { "label": "Action", "url": "https://example.com" }, 
          "content": [{ "description": "iOS content" }],
          "weight": 1,
          "target": { "platforms": ["ios"] }
        },
        {
          "id": "promo-android", 
          "action": { "label": "Action", "url": "https://example.com" }, 
          "content": [{ "description": "Android content" }],
          "weight": 1,
          "target": { "platforms": ["android"] }
        },
        {
          "id": "promo-fr", 
          "action": { "label": "Action", "url": "https://example.com" }, 
          "content": [{ "description": "French content" }],
          "weight": 1,
          "target": { "languages": ["fr"] }
        },
        {
          "id": "promo-multi-lang", 
          "action": { "label": "Action", "url": "https://example.com" }, 
          "content": [{ "description": "English/Spanish content" }],
          "weight": 1,
          "target": { "languages": ["en", "es"] }
        },
        {
          "id": "promo-future", 
          "action": { "label": "Action", "url": "https://example.com" }, 
          "content": [{ "description": "Future content" }],
          "weight": 1,
          "target": { "startDate": "\(ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400)))" }
        },
        {
          "id": "promo-past", 
          "action": { "label": "Action", "url": "https://example.com" }, 
          "content": [{ "description": "Past content" }],
          "weight": 1,
          "target": { "endDate": "\(ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)))" }
        },
        {
          "id": "promo-active", 
          "action": { "label": "Action", "url": "https://example.com" }, 
          "content": [{ "description": "Active content" }],
          "weight": 1,
          "target": { 
            "startDate": "\(ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)))",
            "endDate": "\(ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400)))"
          }
        },
        {
          "id": "promo-complex", 
          "action": { "label": "Action", "url": "https://example.com" }, 
          "content": [{ "description": "Complex targeting content" }],
          "weight": 1,
          "target": { 
            "platforms": ["ios"],
            "languages": ["en"],
            "startDate": "\(ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400)))",
            "endDate": "\(ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400)))"
          }
        }
      ]
    }
    """
    
    // Load the test configuration
    let mockFetcher = TestConfigFetcher(json: testJson)
    try await manager.updateConfig(using: mockFetcher)
    
    // Verify promotions were loaded correctly
    #expect(await manager.promotions.count == 9)
    
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

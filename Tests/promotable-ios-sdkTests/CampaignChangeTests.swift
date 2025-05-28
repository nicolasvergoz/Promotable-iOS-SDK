import Testing
import Foundation
@testable import promotable_ios_sdk

@Suite
struct CampaignChangeTests {
  // Minimal JSON for testing config versioning
  private let minimalJsonConfig1 = """
  {
    "schemaVersion": "0.1.0",
    "campaigns": [
      {
        "id": "campaign_v1",
        "weight": 1,
        "promotions": [
          {
            "id": "promo_v1_1",
            "action": { "label": "Action 1", "url": "https://example.com/action1" },
            "content": [{ "description": "Content for V1 P1" }]
          }
        ]
      }
    ]
  }
  """
  
  private let minimalJsonConfig2_changedId = """
  {
    "schemaVersion": "0.1.0",
    "campaigns": [
      {
        "id": "campaign_v2_changed",
        "weight": 1,
        "promotions": [
          {
            "id": "promo_v1_1",
            "action": { "label": "Action 1", "url": "https://example.com/action1" },
            "content": [{ "description": "Content for V1 P1" }]
          }
        ]
      }
    ]
  }
  """
  
  private let minimalJsonConfig3_changedWeight = """
  {
    "schemaVersion": "0.1.0",
    "campaigns": [
      {
        "id": "campaign_v1",
        "weight": 5,
        "promotions": [
          {
            "id": "promo_v1_1",
            "action": { "label": "Action 1", "url": "https://example.com/action1" },
            "content": [{ "description": "Content for V1 P1" }]
          }
        ]
      }
    ]
  }
  """
  
  @Test("Config Versioning - When config changes, balancing resets, cumulative persists")
  func testConfigVersioning_whenConfigChanges_balancingResets_cumulativePersists() async throws {
    let balancingStorage = CampaignStorageInMemory()
    let cumulativeStorage = CampaignStorageInMemory()
    let manager = CampaignManager(
      balancingStorage: balancingStorage,
      cumulativeStorage: cumulativeStorage
    )
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    // Initial config from minimalJsonConfig1
    let initialData = minimalJsonConfig1.data(using: .utf8)!
    let initialResponse = try decoder.decode(CampaignsResponse.self, from: initialData)
    await manager.configure(with: initialResponse)
    let initialConfigHash = await manager.currentConfigHash()
    #expect(initialConfigHash != nil)
    
    // Simulate some impressions
    for _ in 0..<2 { // Reduced impressions for faster test with minimal config
      _ = await manager.nextPromotion()
    }
    
    let balancingStatsBeforeChange = await manager.getBalancingStats()
    let cumulativeStatsBeforeChange = await manager.getStats()
    #expect(balancingStatsBeforeChange.campaigns.isEmpty == false)
    #expect(cumulativeStatsBeforeChange.campaigns.isEmpty == false)
    
    // Create a modified config from minimalJsonConfig2_changedId
    let modifiedData = minimalJsonConfig2_changedId.data(using: .utf8)!
    let modifiedResponse = try decoder.decode(CampaignsResponse.self, from: modifiedData)
    
    // Reconfigure with modified config
    let changed = await manager.configure(with: modifiedResponse)
    #expect(changed == true, "configure(with:) should return true when config changes")
    
    let newConfigHash = await manager.currentConfigHash()
    #expect(newConfigHash != nil)
    #expect(newConfigHash != initialConfigHash, "Config hash should change after modification")
    
    let balancingStatsAfterChange = await manager.getBalancingStats()
    let cumulativeStatsAfterChange = await manager.getStats()
    
    #expect(balancingStatsAfterChange.campaigns.isEmpty == true, "Balancing campaign stats should reset")
    #expect(balancingStatsAfterChange.promotions.isEmpty == true, "Balancing promotion stats should reset")
    
    #expect(cumulativeStatsAfterChange.campaigns == cumulativeStatsBeforeChange.campaigns, "Cumulative campaign stats should persist")
    #expect(cumulativeStatsAfterChange.promotions == cumulativeStatsBeforeChange.promotions, "Cumulative promotion stats should persist")
  }
  
  @Test("Config Versioning - When same config applied, stats persist")
  func testConfigVersioning_whenSameConfigApplied_statsPersist() async throws {
    let balancingStorage = CampaignStorageInMemory()
    let cumulativeStorage = CampaignStorageInMemory()
    let manager = CampaignManager(
      balancingStorage: balancingStorage,
      cumulativeStorage: cumulativeStorage
    )
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    // Initial config from minimalJsonConfig1
    let initialData = minimalJsonConfig1.data(using: .utf8)!
    let initialResponse = try decoder.decode(CampaignsResponse.self, from: initialData)
    await manager.configure(with: initialResponse)
    let initialConfigHash = await manager.currentConfigHash()
    #expect(initialConfigHash != nil)
    
    // Simulate some impressions
    for _ in 0..<2 { // Reduced impressions
      _ = await manager.nextPromotion()
    }
    
    let balancingStatsBeforeReapply = await manager.getBalancingStats()
    let cumulativeStatsBeforeReapply = await manager.getStats()
    #expect(balancingStatsBeforeReapply.campaigns.isEmpty == false)
    #expect(cumulativeStatsBeforeReapply.campaigns.isEmpty == false)
    
    // Reconfigure with the exact same config (decode minimalJsonConfig1 again)
    let sameData = minimalJsonConfig1.data(using: .utf8)!
    let sameResponse = try decoder.decode(CampaignsResponse.self, from: sameData)
    let changed = await manager.configure(with: sameResponse)
    #expect(changed == false, "configure(with:) should return false when config is the same")
    
    let newConfigHash = await manager.currentConfigHash()
    #expect(newConfigHash == initialConfigHash, "Config hash should NOT change")
    
    let balancingStatsAfterReapply = await manager.getBalancingStats()
    let cumulativeStatsAfterReapply = await manager.getStats()
    
    #expect(balancingStatsAfterReapply.campaigns == balancingStatsBeforeReapply.campaigns, "Balancing campaign stats should NOT reset")
    #expect(balancingStatsAfterReapply.promotions == balancingStatsBeforeReapply.promotions, "Balancing promotion stats should NOT reset")
    #expect(cumulativeStatsAfterReapply.campaigns == cumulativeStatsBeforeReapply.campaigns, "Cumulative campaign stats should persist")
    #expect(cumulativeStatsAfterReapply.promotions == cumulativeStatsBeforeReapply.promotions, "Cumulative promotion stats should persist")
  }
  
  @Test("Config Versioning - Helper methods currentConfigHash and wouldConfigChange")
  func testConfigVersioning_helperMethods_currentConfigHash_wouldConfigChange() async throws {
    let manager = CampaignManager(
      balancingStorage: CampaignStorageInMemory(),
      cumulativeStorage: CampaignStorageInMemory()
    )
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    // 1. Before any config
    #expect(await manager.currentConfigHash() == nil, "Initial config hash should be nil")
    
    let data1 = minimalJsonConfig1.data(using: .utf8)!
    let response1 = try decoder.decode(CampaignsResponse.self, from: data1)
    
    #expect(await manager.wouldConfigChange(with: response1.campaigns) == true, "wouldConfigChange should be true for initial load")
    
    // 2. Load initial config (response1 from minimalJsonConfig1)
    await manager.configure(with: response1)
    let hash1 = await manager.currentConfigHash()
    #expect(hash1 != nil, "Config hash should not be nil after first load")
    #expect(await manager.wouldConfigChange(with: response1.campaigns) == false, "wouldConfigChange should be false for same campaigns")
    
    // 3. Create modified config (response2 from minimalJsonConfig3_changedWeight)
    let data2 = minimalJsonConfig3_changedWeight.data(using: .utf8)!
    let response2 = try decoder.decode(CampaignsResponse.self, from: data2)
    
    #expect(await manager.wouldConfigChange(with: response2.campaigns) == true, "wouldConfigChange should be true for modified campaigns")
    
    // 4. Load modified config (response2)
    await manager.configure(with: response2)
    let hash2 = await manager.currentConfigHash()
    #expect(hash2 != nil, "Config hash should not be nil after second load")
    #expect(hash2 != hash1, "Config hash should change after loading modified config")
    
    #expect(await manager.wouldConfigChange(with: response2.campaigns) == false, "wouldConfigChange should be false for current (modified) campaigns")
    #expect(await manager.wouldConfigChange(with: response1.campaigns) == true, "wouldConfigChange should be true for original campaigns now")
  }
}

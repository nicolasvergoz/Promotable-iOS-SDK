import Testing
import Foundation
@testable import promotable_ios_sdk

@Suite
struct PromotionChangeTests {
  // Minimal JSON for testing date-based reset mechanism
  private let minimalJsonConfig1 = """
  {
    "schemaVersion": "0.1.0",
    "promotions": [
      {
        "id": "promo_v1_1",
        "action": { "label": "Action 1", "url": "https://example.com/action1" },
        "content": [{ "description": "Content for V1 P1" }],
        "weight": 1
      }
    ]
  }
  """
  
  private let minimalJsonConfig2_withBalancingReset = """
  {
    "schemaVersion": "0.1.0",
    "resetBalancingDate": "2025-06-01T00:00:00Z",
    "promotions": [
      {
        "id": "promo_v1_1",
        "action": { "label": "Action 1", "url": "https://example.com/action1" },
        "content": [{ "description": "Content for V1 P1" }],
        "weight": 1
      }
    ]
  }
  """
  
  private let minimalJsonConfig3_withGlobalReset = """
  {
    "schemaVersion": "0.1.0",
    "resetBalancingDate": "2025-06-01T00:00:00Z",
    "resetCumulativeDate": "2025-06-01T00:00:00Z",
    "promotions": [
      {
        "id": "promo_v1_1",
        "action": { "label": "Action 1", "url": "https://example.com/action1" },
        "content": [{ "description": "Content for V1 P1" }],
        "weight": 1
      }
    ]
  }
  """
  
  @Test("Reset Mechanism - When resetBalancingDate is provided, balancing storage resets")
  func testResetMechanism_whenResetBalancingDateProvided_balancingStorageResets() async throws {
    let balancingStorage = CampaignStorageInMemory()
    let cumulativeStorage = CampaignStorageInMemory()
    let manager = CampaignManager(
      balancingStorage: balancingStorage,
      cumulativeStorage: cumulativeStorage
    )
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    // Initial config from minimalJsonConfig1 (no reset dates)
    let initialData = minimalJsonConfig1.data(using: .utf8)!
    let initialResponseData = try JSONSerialization.jsonObject(with: initialData) as! [String: Any]
    var promotionsResponseDict = initialResponseData
    let promotionsResponse = PromotionsResponse(promotions: try JSONDecoder().decode([Promotion].self, from: JSONSerialization.data(withJSONObject: initialResponseData["promotions"]!)))
    await manager.configure(with: promotionsResponse)
    
    // Simulate some impressions
    for _ in 0..<2 { // Reduced impressions for faster test
      _ = await manager.nextPromotion()
    }
    
    let balancingStatsBeforeReset = await manager.getBalancingStats()
    let cumulativeStatsBeforeReset = await manager.getStats()
    #expect(balancingStatsBeforeReset.promotions.isEmpty == false, "Should have promotion stats before reset")
    #expect(cumulativeStatsBeforeReset.promotions.isEmpty == false, "Should have cumulative stats before reset")
    
    // Configure with config that has a resetBalancingDate
    let resetConfigData = minimalJsonConfig2_withBalancingReset.data(using: .utf8)!
    let resetResponseData = try JSONSerialization.jsonObject(with: resetConfigData) as! [String: Any]
    promotionsResponseDict = resetResponseData
    
    // Create PromotionsResponse with resetDate
    let resetPromotionsResponse = try decoder.decode(PromotionsResponse.self, from: resetConfigData)
    
    // Configure with the reset config
    let wasReset = await manager.configure(with: resetPromotionsResponse)
    #expect(wasReset == true, "configure(with:) should return true when resetBalancingDate causes reset")
    
    // Check last reset dates
    let lastBalancingReset = await manager.lastBalancingResetDate()
    #expect(lastBalancingReset > Date.distantPast, "Last balancing reset date should be updated")
    
    // Verify balancing stats were reset but cumulative stats persist
    let balancingStatsAfterReset = await manager.getBalancingStats()
    let cumulativeStatsAfterReset = await manager.getStats()
    
    #expect(balancingStatsAfterReset.promotions.isEmpty == true, "Balancing promotion stats should be reset")
    #expect(cumulativeStatsAfterReset.promotions == cumulativeStatsBeforeReset.promotions, "Cumulative promotion stats should persist")
  }
  
  @Test("Reset Mechanism - When no reset dates provided, stats persist")
  func testResetMechanism_whenNoResetDatesProvided_statsPersist() async throws {
    let balancingStorage = CampaignStorageInMemory()
    let cumulativeStorage = CampaignStorageInMemory()
    let manager = CampaignManager(
      balancingStorage: balancingStorage,
      cumulativeStorage: cumulativeStorage
    )
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    // Initial config from minimalJsonConfig1 (no reset dates)
    let initialData = minimalJsonConfig1.data(using: .utf8)!
    let promotionsResponse = try decoder.decode(PromotionsResponse.self, from: initialData)
    await manager.configure(with: promotionsResponse)
    
    // Simulate some impressions
    for _ in 0..<2 { // Reduced impressions
      _ = await manager.nextPromotion()
    }
    
    let balancingStatsBeforeReapply = await manager.getBalancingStats()
    let cumulativeStatsBeforeReapply = await manager.getStats()
    #expect(balancingStatsBeforeReapply.promotions.isEmpty == false, "Should have promotion stats before reapply")
    
    // Reconfigure with the exact same config (decode minimalJsonConfig1 again)
    let sameData = minimalJsonConfig1.data(using: .utf8)!
    let sameResponse = try decoder.decode(PromotionsResponse.self, from: sameData)
    let wasReset = await manager.configure(with: sameResponse)
    #expect(wasReset == false, "configure(with:) should return false when no reset needed")
    
    let balancingStatsAfterReapply = await manager.getBalancingStats()
    let cumulativeStatsAfterReapply = await manager.getStats()
    
    #expect(balancingStatsAfterReapply.promotions == balancingStatsBeforeReapply.promotions, "Balancing promotion stats should NOT reset")
    #expect(cumulativeStatsAfterReapply.promotions == cumulativeStatsBeforeReapply.promotions, "Cumulative promotion stats should persist")
  }
  
  @Test("Reset Mechanism - When resetCumulativeDate provided, both storages reset")
  func testResetMechanism_whenResetCumulativeDateProvided_bothStoragesReset() async throws {
    let balancingStorage = CampaignStorageInMemory()
    let cumulativeStorage = CampaignStorageInMemory()
    let manager = CampaignManager(
      balancingStorage: balancingStorage,
      cumulativeStorage: cumulativeStorage
    )
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    // Initial config from minimalJsonConfig1 (no reset dates)
    let initialData = minimalJsonConfig1.data(using: .utf8)!
    let promotionsResponse = try decoder.decode(PromotionsResponse.self, from: initialData)
    await manager.configure(with: promotionsResponse)
    
    // Simulate some impressions
    for _ in 0..<2 { // Reduced impressions
      _ = await manager.nextPromotion()
    }
    
    let balancingStatsBeforeReset = await manager.getBalancingStats()
    let cumulativeStatsBeforeReset = await manager.getStats()
    #expect(balancingStatsBeforeReset.promotions.isEmpty == false, "Should have promotion stats before reset")
    #expect(cumulativeStatsBeforeReset.promotions.isEmpty == false, "Should have cumulative stats before reset")
    
    // Configure with config that has a resetCumulativeDate
    let globalResetData = minimalJsonConfig3_withGlobalReset.data(using: .utf8)!
    let globalResetResponse = try decoder.decode(PromotionsResponse.self, from: globalResetData)
    
    // Configure with the global reset config
    let wasReset = await manager.configure(with: globalResetResponse)
    #expect(wasReset == true, "configure(with:) should return true when resetCumulativeDate causes reset")
    
    // Check last reset dates
    let lastBalancingReset = await manager.lastBalancingResetDate()
    let lastCumulativeReset = await manager.lastCumulativeResetDate()
    #expect(lastBalancingReset > Date.distantPast, "Last balancing reset date should be updated")
    #expect(lastCumulativeReset > Date.distantPast, "Last cumulative reset date should be updated")
    
    // Verify both storages were reset
    let balancingStatsAfterReset = await manager.getBalancingStats()
    let cumulativeStatsAfterReset = await manager.getStats()
    
    #expect(balancingStatsAfterReset.promotions.isEmpty == true, "Balancing promotion stats should be reset")
    #expect(cumulativeStatsAfterReset.promotions.isEmpty == true, "Cumulative promotion stats should be reset")
  }
}

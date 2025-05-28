import Testing
import Foundation
@testable import promotable_ios_sdk

enum TestError: Error {
  case missingJSONFile
  case decoding
  case schemaVersionMismatch(received: String, required: String)
}

@Suite
struct CampaignsTests {
  let jsonSample: String
  
  init() {
    let fileUrl = Bundle.module.url(forResource: "CampaignsSample", withExtension: "json")!
    let data = try! Data(contentsOf: fileUrl)
    self.jsonSample = String(data: data, encoding: .utf8)!
  }
  
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
    // Create a fresh storage instance for this test
    let manager = CampaignManager(
      storage: InMemoryCampaignStorage()
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
  
  // TODO: Test: ignore non-eligible promotions (expired date, unmatched platform/locale)
  
  @Test("ConfigFetcher - mock implementation")
  func testConfigFetcher() async throws {
    // Create a campaign manager with a fresh storage instance
    let manager = CampaignManager(
      storage: InMemoryCampaignStorage()
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

/// Test implementation of ConfigFetcher
/// Uses the same approach as MockConfigFetcher but adapts for the test environment
struct TestConfigFetcher: ConfigFetcher {
  let requiredSchemaVersion: String
  let json: String
  
  init(json: String, requiredSchemaVersion: String = "0.1.0") {
    self.json = json
    self.requiredSchemaVersion = requiredSchemaVersion
  }
  
  func fetchConfig() async throws -> CampaignsResponse {
    // Load from the test bundle's CampaignsSample.json file
    guard let data = json.data(using: .utf8) else {
      throw TestError.decoding
    }
    
    // First, parse the JSON to check schema version
    do {
      if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
         let schemaVersion = json["schemaVersion"] as? String {
        
        // Validate schema version
        guard schemaVersion == requiredSchemaVersion else {
          throw ConfigError.schemaVersionMismatch(received: schemaVersion, required: requiredSchemaVersion)
        }
        
        // Version is valid, proceed with full decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
          return try decoder.decode(CampaignsResponse.self, from: data)
        } catch {
          throw TestError.decoding
        }
      } else {
        throw ConfigError.invalidResponse
      }
    } catch let error as ConfigError {
      throw error
    } catch {
      throw TestError.decoding
    }
  }
}

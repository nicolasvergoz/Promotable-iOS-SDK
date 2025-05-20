import Testing
import Foundation
@testable import promotable_ios_sdk

enum TestError: Error {
  case missingJSONFile
}

@Suite
struct CampaignsTests {
  
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
  
  @Test
  func testDecodingCampaignsJSON() throws {
    guard let fileUrl = Bundle.module.url(forResource: "CampaignsSample", withExtension: "json") else {
      throw TestError.missingJSONFile
    }
    
    let data = try Data(contentsOf: fileUrl)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    let response = try decoder.decode(CampaignsResponse.self, from: data)
    
    #expect(response.campaigns.count == 2)
    
    let campaignA = response.campaigns.first { $0.campaignId == "campaignA" }
    #expect(campaignA?.campaignWeight == 1)
    #expect(campaignA?.promotions.count == 1)
    #expect(campaignA?.promotions.first?.title == "Try CoolApp")
    
    let campaignB = response.campaigns.first { $0.campaignId == "campaignB" }
    #expect(campaignB?.campaignWeight == 2)
    #expect(campaignB?.promotions.count == 2)
    #expect(campaignB?.promotions.last?.weight == 2)
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
    let campaignsResponse = CampaignsResponse(campaigns: [
      CampaignDTO(
        campaignId: "A",
        campaignWeight: 1,
        targeting: nil,
        promotions: [
          PromotionDTO(
            id: "A1",
            title: "A1",
            description: "",
            iconUrl: URL(string: "https://cdn.com/a1.png")!,
            bannerUrl: URL(string: "https://cdn.com/a1b.png")!,
            link: URL(string: "https://appstore.com/a1")!,
            weight: 1,
            minDisplayDuration: nil
          )
        ]
      ),
      CampaignDTO(
        campaignId: "B",
        campaignWeight: 2,
        targeting: TargetingDTO(platforms: ["ios"], locales: ["en"], displayAfterLaunch: nil, startDate: nil, endDate: nil),
        promotions: [
          PromotionDTO(
            id: "B1",
            title: "B1",
            description: "",
            iconUrl: URL(string: "https://cdn.com/b1.png")!,
            bannerUrl: URL(string: "https://cdn.com/b1b.png")!,
            link: URL(string: "https://appstore.com/b1")!,
            weight: 1,
            minDisplayDuration: nil
          ),
          PromotionDTO(
            id: "B2",
            title: "B2",
            description: "",
            iconUrl: URL(string: "https://cdn.com/b1.png")!,
            bannerUrl: URL(string: "https://cdn.com/b1b.png")!,
            link: URL(string: "https://appstore.com/b1")!,
            weight: 1,
            minDisplayDuration: nil
          )
        ]
      )
    ])
    
    let storage = InMemoryCampaignStorage()
    let manager = CampaignManager(storage: storage, locale: "en", platform: "ios")
    
    await manager.updateConfiguration(campaignResponse: campaignsResponse)
    
    var promo: Promotion? = await manager.nextPromotion()
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

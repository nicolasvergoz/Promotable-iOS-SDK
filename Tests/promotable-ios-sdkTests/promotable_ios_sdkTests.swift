import Testing
import Foundation
@testable import promotable_ios_sdk

enum TestError: Error {
  case missingJSONFile
}

@Suite
struct CampaignsDecodingTests {
  
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
}

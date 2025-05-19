import Foundation

struct CampaignsResponse: Codable {
  let campaigns: [CampaignDTO]
}

struct CampaignDTO: Codable {
  let campaignId: String
  let campaignWeight: Int
  let targeting: TargetingDTO?
  let promotions: [PromotionDTO]
}

struct TargetingDTO: Codable {
  let platforms: [String]?
  let locales: [String]?
  let displayAfterLaunch: Int?
  let startDate: Date?
  let endDate: Date?
}

struct PromotionDTO: Codable {
  let id: String
  let title: String
  let description: String
  let iconUrl: URL
  let bannerUrl: URL
  let link: URL
  let weight: Int
  let minDisplayDuration: Int?
}

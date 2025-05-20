import Foundation

struct Campaign: Identifiable {
  let id: String
  let weight: Int
  let targeting: Targeting?
  let promotions: [Promotion]
}

struct Targeting {
  var platforms: [String]?
  var locales: [String]?
  var displayAfterLaunch: Int?
  var startDate: Date?
  var endDate: Date?
}

struct Promotion: Identifiable {
  let id: String
  let title: String
  let description: String
  let link: URL
  var iconUrl: URL?
  var bannerUrl: URL?
  var weight: Int?
  var minDisplayDuration: Int?
}

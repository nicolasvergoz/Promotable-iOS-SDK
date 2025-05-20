import Foundation

extension CampaignsResponse {
  var domain: [Campaign] {
    self.campaigns.map { dto in
      Campaign(
        id: dto.campaignId,
        weight: dto.campaignWeight,
        targeting: dto.targeting?.domain,
        promotions: dto.promotions.map { $0.domain }
      )
    }
  }
}

extension TargetingDTO {
  var domain: Targeting {
    Targeting(
      platforms: self.platforms,
      locales: self.locales,
      displayAfterLaunch: self.displayAfterLaunch,
      startDate: self.startDate,
      endDate: self.endDate
    )
  }
}

extension PromotionDTO {
  var domain: Promotion {
    Promotion(
      id: self.id,
      title: self.title,
      description: self.description,
      link: self.link,
      iconUrl: self.iconUrl,
      bannerUrl: self.bannerUrl,
      weight: self.weight,
      minDisplayDuration: self.minDisplayDuration
    )
  }
}

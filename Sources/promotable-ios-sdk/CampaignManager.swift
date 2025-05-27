import Foundation
/// Manages campaign configurations, selection, and statistics
public actor CampaignManager: Sendable {
  private var campaigns: [Campaign] = []
  private let storage: CampaignStorageProtocol
  var platform: String
  var locale: String
  
  init(
    storage: CampaignStorageProtocol = CampaignStorage(),
    locale: String = "en",
    platform: String = "ios"
  ) {
    self.storage = storage
    self.locale = locale
    self.platform = platform
  }
  
  /// Updates the campaign configuration using a string JSON response
  /// - Parameter jsonResponse: JSON string containing campaign configuration
  func updateConfiguration(jsonResponse: String) async throws {
    do {
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      let data = Data(jsonResponse.utf8)
      
      let response = try decoder.decode(CampaignsResponse.self, from: data)
      self.configure(with: response)
    } catch {
      print("ERROR", error)
      throw ConfigError.decodingFailed(error)
    }
  }
  
  /// Updates the campaign configuration using the provided fetcher
  /// - Parameter fetcher: An implementation of ConfigFetcher
  /// - Returns: Updated campaign configuration
  /// - Throws: Error from the fetcher if configuration cannot be fetched or decoded
  func updateConfig(using fetcher: ConfigFetcher) async throws -> CampaignsResponse {
    let response = try await fetcher.fetchConfig()
    self.configure(with: response)
    return response
  }
  
  /// Configures the campaign manager with the provided campaign response
  /// - Parameter response: The campaign response containing campaigns
  private func configure(with response: CampaignsResponse) {
    self.campaigns = response.campaigns
    storage.reset()
  }
  
  func nextPromotion() async -> Campaign.Promotion? {
    // Filter campaigns matching current device context
    let eligibleCampaigns = campaigns.filter {
      $0.target?.matches(locale: locale, platform: platform) ?? true
    }
    
    guard let selectedCampaign = pickCampaign(
      eligibleCampaigns,
      weight: \.weight
    ) else {
      return nil
    }
    
    guard let selectedPromotion = pickPromotion(
      selectedCampaign.promotions,
      weight: { $0.weight ?? 1 }
    ) else {
      return nil
    }
    
    storage.incrementDisplayCount(campaignId: selectedCampaign.id, promotionId: selectedPromotion.id)
    
    return selectedPromotion
  }
  
  func getStats() -> DisplayStats {
    DisplayStats(
      campaigns: storage.campaignDisplayCounts,
      promotions: storage.promotionDisplayCounts
    )
  }
  
  func setLocale(_ locale: String) {
    self.locale = locale
  }
  
  func setPlatform(_ platform: String) {
    self.platform = platform
  }
  
  private func pickCampaign(_ entries: [Campaign], weight: (Campaign) -> Int) -> Campaign? {
    let weighted: [Balancer.Entry] = entries.map {
      let displayCounts = storage.getCampaignDisplayCount(for: $0.id)
      return Balancer.Entry(item: $0, weight: weight($0), displayCounts: displayCounts)
    }
    return Balancer(weighted).pick()
  }
  
  private func pickPromotion(_ entries: [Campaign.Promotion], weight: (Campaign.Promotion) -> Int) -> Campaign.Promotion? {
    let weighted: [Balancer.Entry] = entries.map {
      let displayCounts = storage.getPromotionDisplayCount(for: $0.id)
      return Balancer.Entry(item: $0, weight: weight($0), displayCounts: displayCounts)
    }
    return Balancer(weighted).pick()
  }
}

extension Campaign.Target {
  func matches(locale: String, platform: String) -> Bool {
    if let platforms = platforms, !platforms.contains(platform) {
      return false
    }
    
    if let locales = locales, !locales.contains(locale) {
      return false
    }
    return true
  }
}

extension Thread {
  /// A convenience method to print out the current thread from an async method.
  /// This is a workaround for compiler error:
  /// Class property 'current' is unavailable from asynchronous contexts; Thread.current cannot be used from async contexts.
  /// See: https://github.com/swiftlang/swift-corelibs-foundation/issues/5139
  public static var currentThread: Thread {
    return Thread.current
  }
}

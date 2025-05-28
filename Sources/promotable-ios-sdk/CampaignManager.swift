import Foundation

/// Manages campaign configurations, selection, and statistics
public actor CampaignManager: Sendable {
  /// The current loaded campaigns
  var campaigns: [Campaign] = []

  /// Stores the hash of the current campaigns configuration
  private var configHash: Int? = nil
  
  /// Storage for balancing campaign and promotion display counts
  /// These counts reset when configuration changes
  private let balancingStorage: CampaignStorageProtocol
  
  /// Storage for cumulative display statistics
  /// These stats persist across configuration changes
  private let cumulativeStorage: CampaignStorageProtocol
  
  var platform: String
  var language: String
  
  /// Initialize the campaign manager with a targeting context
  /// - Parameters:
  ///   - balancingStorage: Storage implementation for balancing campaign display counts (resets on config change)
  ///   - statsStorage: Storage implementation for cumulative display statistics (persists across config changes)
  ///   - language: Current language for targeting, defaults to "en"
  ///   - platform: Current platform for targeting, defaults to "ios"
  init(
    balancingStorage: CampaignStorageProtocol = BalancingCampaignStorage(),
    cumulativeStorage: CampaignStorageProtocol = CampaignStorageCumulative(),
    language: String = "en",
    platform: String = "ios"
  ) {
    self.balancingStorage = balancingStorage
    self.cumulativeStorage = cumulativeStorage
    self.language = language
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
  /// - Throws: Error from the fetcher if configuration cannot be fetched or decoded
  func updateConfig(using fetcher: ConfigFetcher) async throws {
    let response = try await fetcher.fetchConfig()
    self.configure(with: response)
  }
  
  /// Configures the campaign manager with the provided campaign response
  /// - Parameter response: The campaign response containing campaigns
  /// - Returns: Bool indicating if the configuration actually changed
  @discardableResult
  func configure(with response: CampaignsResponse) -> Bool {
    let newHash = hashCampaigns(response.campaigns)
    let changed = (configHash == nil) || (configHash != newHash)
    if changed {
      // Only update campaigns and reset balancing storage if config changed
      self.campaigns = response.campaigns
      configHash = newHash
      balancingStorage.reset()
    }
    return changed
  }

  /// Calculates the hash of a campaigns array for config versioning
  /// - Parameter campaigns: The array of Campaign objects
  /// - Returns: Int hash value
  private func hashCampaigns(_ campaigns: [Campaign]) -> Int {
    var hasher = Hasher()
    campaigns.hash(into: &hasher)
    return hasher.finalize()
  }

  /// Returns the current config hash, or nil if not loaded
  public func currentConfigHash() -> Int? {
    return configHash
  }

  /// Checks if a given campaigns array would change the current config
  /// - Parameter newCampaigns: The new campaigns to check
  /// - Returns: Bool indicating if the config would change
  func wouldConfigChange(with newCampaigns: [Campaign]) -> Bool {
    let newHash = hashCampaigns(newCampaigns)
    return configHash == nil || configHash != newHash
  }
  
  /// Get the next promotion to display based on eligibility and weighted balancing
  /// - Returns: A promotion to display, or nil if none available
  func nextPromotion() async -> Campaign.Promotion? {
    // Filter campaigns matching current device context
    let eligibleCampaigns = campaigns.filter {
      $0.target?.matches(language: language, platform: platform) ?? true
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
    
    // Increment both storage systems when a promotion is displayed
    balancingStorage.incrementDisplayCount(campaignId: selectedCampaign.id, promotionId: selectedPromotion.id)
    cumulativeStorage.incrementDisplayCount(campaignId: selectedCampaign.id, promotionId: selectedPromotion.id)
    
    return selectedPromotion
  }
  
  /// Get cumulative display statistics across all configurations
  /// - Returns: DisplayStats containing campaign and promotion view counts
  func getStats() -> DisplayStats {
    DisplayStats(
      campaigns: cumulativeStorage.campaignCount,
      promotions: cumulativeStorage.promotionCount
    )
  }
  
  /// Get current balancing display counts (resets when configuration changes)
  /// - Returns: DisplayStats containing campaign and promotion current balancing counts
  func getBalancingStats() -> DisplayStats {
    DisplayStats(
      campaigns: balancingStorage.campaignCount,
      promotions: balancingStorage.promotionCount
    )
  }
  
  func setLanguage(_ language: String) {
    self.language = language
  }
  
  func setPlatform(_ platform: String) {
    self.platform = platform
  }
  
  /// Select a campaign using weighted balancing
  /// - Parameters:
  ///   - entries: List of campaigns to select from
  ///   - weight: Function to get the weight of a campaign
  /// - Returns: Selected campaign or nil if none available
  private func pickCampaign(_ entries: [Campaign], weight: (Campaign) -> Int) -> Campaign? {
    let weighted: [Balancer.Entry] = entries.map {
      let displayCounts = balancingStorage.getCampaignDisplayCount(for: $0.id)
      return Balancer.Entry(item: $0, weight: weight($0), displayCounts: displayCounts)
    }
    return Balancer(weighted).pick()
  }
  
  /// Select a promotion using weighted balancing
  /// - Parameters:
  ///   - entries: List of promotions to select from
  ///   - weight: Function to get the weight of a promotion
  /// - Returns: Selected promotion or nil if none available
  private func pickPromotion(_ entries: [Campaign.Promotion], weight: (Campaign.Promotion) -> Int) -> Campaign.Promotion? {
    let weighted: [Balancer.Entry] = entries.map {
      let displayCounts = balancingStorage.getPromotionDisplayCount(for: $0.id)
      return Balancer.Entry(item: $0, weight: weight($0), displayCounts: displayCounts)
    }
    return Balancer(weighted).pick()
  }
}

extension Campaign.Target {
  func matches(language: String, platform: String) -> Bool {
    // Check platform targeting
    if let platforms = platforms, !platforms.contains(platform) {
      return false
    }
    
    // Check language targeting
    if let languages = languages, !languages.contains(language) {
      return false
    }
    
    // Check date range targeting
    let currentDate = Date()
    
    // If there's a start date and current date is before it, campaign is not yet active
    if let startDate = startDate, currentDate < startDate {
      return false
    }
    
    // If there's an end date and current date is after it, campaign has expired
    if let endDate = endDate, currentDate > endDate {
      return false
    }
    
    // All targeting conditions passed
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

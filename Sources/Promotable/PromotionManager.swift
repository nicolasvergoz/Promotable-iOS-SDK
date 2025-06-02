import Foundation

/// Manages promotion configurations, selection, and statistics
public actor PromotionManager: Sendable {
  /// The current loaded promotions
  var promotions: [Promotion] = []

  /// Stores the last time balancing storage was reset
  private var lastBalancingReset: Date = Date.distantPast
  
  /// Stores the last time cumulative storage was reset
  private var lastCumulativeReset: Date = Date.distantPast
  
  /// Storage for balancing promotion display counts
  /// These counts reset when configuration changes
  private let balancingStorage: PromotionStorageProtocol
  
  /// Storage for cumulative display statistics
  /// These stats persist across configuration changes
  private let cumulativeStorage: PromotionStorageProtocol
  
  public var platform: String
  public var language: String
  
  /// Initialize the promotion manager with a targeting context
  /// - Parameters:
  ///   - balancingStorage: Storage implementation for balancing promotion display counts (resets on config change)
  ///   - statsStorage: Storage implementation for cumulative display statistics (persists across config changes)
  ///   - language: Current language for targeting, defaults to "en"
  ///   - platform: Current platform for targeting, defaults to "ios"
  public init(
    balancingStorage: PromotionStorageProtocol = PromotionStorageBalancing(),
    cumulativeStorage: PromotionStorageProtocol = PromotionStorageCumulative(),
    language: String = "en",
    platform: String = "ios"
  ) {
    self.balancingStorage = balancingStorage
    self.cumulativeStorage = cumulativeStorage
    self.language = language
    self.platform = platform
  }
  
  /// Updates the promotion configuration using the provided fetcher
  /// - Parameter fetcher: An implementation of ConfigFetcher
  /// - Throws: Error from the fetcher if configuration cannot be fetched or decoded
  public func updateConfig(using fetcher: ConfigFetcher) async throws {
    let response = try await fetcher.fetchConfig()
    self.configure(with: response)
  }
  
  /// Configures the manager with the provided promotions response
  /// - Parameter response: The promotions response containing promotions
  /// - Returns: Bool indicating if any storage was reset
  @discardableResult
  public func configure(with response: PromotionsResponse) -> Bool {
    let currentDate = Date()
    var wasReset = false
    
    // Check if balancing storage should be reset based on resetBalancingDate
    if let resetBalancingDate = response.resetBalancingDate, resetBalancingDate > lastBalancingReset {
      balancingStorage.reset()
      lastBalancingReset = currentDate
      wasReset = true
    }
    
    // Check if cumulative storage should be reset based on resetCumulativeDate
    if let resetCumulativeDate = response.resetCumulativeDate, resetCumulativeDate > lastCumulativeReset {
      cumulativeStorage.reset()
      lastCumulativeReset = currentDate
      wasReset = true
    }
    
    // Always update the promotions
    self.promotions = response.promotions
    
    return wasReset
  }
  
  /// Returns whether balancing storage was reset on the last configure call
  /// - Returns: Date when balancing storage was last reset
  public func lastBalancingResetDate() -> Date {
    return lastBalancingReset
  }
  
  /// Returns whether cumulative storage was reset on the last configure call
  /// - Returns: Date when cumulative storage was last reset
  public func lastCumulativeResetDate() -> Date {
    return lastCumulativeReset
  }

  // Legacy wouldConfigChange methods removed
  
  /// Get the next promotion to display based on eligibility and weighted balancing
  /// - Returns: A promotion to display, or nil if none available
  public func nextPromotion() async -> Promotion? {
    // Filter promotions matching current device context
    let eligiblePromotions = promotions.filter {
      $0.target?.matches(language: language, platform: platform) ?? true
    }
    
    guard let selectedPromotion = pickPromotion(
      eligiblePromotions,
      weight: { $0.weight ?? 1 }
    ) else {
      return nil
    }
    
    // Increment both storage systems when a promotion is displayed
    balancingStorage.incrementDisplayCount(promotionId: selectedPromotion.id)
    cumulativeStorage.incrementDisplayCount(promotionId: selectedPromotion.id)
    
    return selectedPromotion
  }
  
  /// Get cumulative display statistics across all configurations
  /// - Returns: DisplayStats containing promotion view counts
  public func getStats() -> DisplayStats {
    DisplayStats(
      promotions: cumulativeStorage.promotionCount
    )
  }
  
  /// Get current balancing display counts (resets when configuration changes)
  /// - Returns: DisplayStats containing promotion current balancing counts
  public func getBalancingStats() -> DisplayStats {
    DisplayStats(
      promotions: balancingStorage.promotionCount
    )
  }
  
  public func setLanguage(_ language: String) {
    self.language = language
  }
  
  public func setPlatform(_ platform: String) {
    self.platform = platform
  }
  
  /// Select a promotion using weighted balancing
  /// - Parameters:
  ///   - entries: List of promotions to select from
  ///   - weight: Function to get the weight of a promotion
  /// - Returns: Selected promotion or nil if none available
  private func pickPromotion(_ entries: [Promotion], weight: (Promotion) -> Int) -> Promotion? {
    let weighted: [Balancer.Entry] = entries.map {
      let displayCounts = balancingStorage.getPromotionDisplayCount(for: $0.id)
      return Balancer.Entry(item: $0, weight: weight($0), displayCounts: displayCounts)
    }
    return Balancer(weighted).pick()
  }
}

extension Promotion.Target {
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
    
    // If there's a start date and current date is before it, promotion is not yet active
    if let startDate = startDate, currentDate < startDate {
      return false
    }
    
    // If there's an end date and current date is after it, promotion has expired
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

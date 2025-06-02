import Foundation

/// Example showing how to use the ConfigFetcher protocol
struct ConfigFetcherExample {
  
  /// Example of using the default implementation
  static func fetchWithDefaultImplementation() async {
    // Create a promotion manager
    let promotionManager = PromotionManager()
    
    // Create the default fetcher with a config URL
    let configURL = URL(string: "https://example.com/promotions.json")!
    let defaultFetcher = DefaultConfigFetcher(configURL: configURL, requiredSchemaVersion: "0.1.0")
    
    do {
      // Use the fetcher to update promotion config
      try await promotionManager.updateConfig(using: defaultFetcher)
      let promotions = await promotionManager.promotions
      print("Successfully fetched \(promotions.count) promotions")
    } catch {
      print("Failed to fetch promotions config: \(error)")
    }
  }
  
  /// Example of using a custom implementation that loads from a local JSON file
  static func fetchWithCustomImplementation() async {
    // Create a promotion manager
    let promotionManager = PromotionManager()
    
    // Create a custom fetcher that loads from a local JSON file
    let mockFetcher = MockConfigFetcher()
    
    do {
      // Use the custom fetcher to update promotion config
      try await promotionManager.updateConfig(using: mockFetcher)
      let promotions = await promotionManager.promotions
      print("Successfully fetched \(promotions.count) promotions")
      
      // Print some information about the loaded promotions
      for promotion in promotions {
        print("  - Promotion: \(promotion.id), Title: \(promotion.title ?? "No title")")
      }
    } catch {
      print("Failed to fetch promotion config: \(error)")
    }
  }
}

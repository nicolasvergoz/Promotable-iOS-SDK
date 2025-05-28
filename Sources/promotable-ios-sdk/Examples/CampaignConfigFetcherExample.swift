import Foundation

// This file contains examples of how to use the ConfigFetcher protocol
// and is not part of the actual SDK implementation

/// Example showing how to use the ConfigFetcher protocol
struct ConfigFetcherExample {
  
  /// Example of using the default implementation
  static func fetchWithDefaultImplementation() async {
    // Create a campaign manager
    let campaignManager = CampaignManager()
    
    // Create the default fetcher with a config URL
    let configURL = URL(string: "https://example.com/campaigns.json")!
    let defaultFetcher = DefaultConfigFetcher(configURL: configURL, requiredSchemaVersion: "0.1.0")
    
    do {
      // Use the fetcher to update campaign config
      try await campaignManager.updateConfig(using: defaultFetcher)
      let campaigns = await campaignManager.campaigns
      print("Successfully fetched \(campaigns.count) campaigns")
    } catch {
      print("Failed to fetch campaign config: \(error)")
    }
  }
  
  /// Example of using a custom implementation that loads from a local JSON file
  static func fetchWithCustomImplementation() async {
    // Create a campaign manager
    let campaignManager = CampaignManager()
    
    // Create a custom fetcher that loads from a local JSON file
    let mockFetcher = MockConfigFetcher()
    
    do {
      // Use the custom fetcher to update campaign config
      try await campaignManager.updateConfig(using: mockFetcher)
      let campaigns = await campaignManager.campaigns
      print("Successfully fetched \(campaigns.count) campaigns")
      
      // Print some information about the loaded campaigns
      for campaign in campaigns {
        print("Campaign ID: \(campaign.id), Weight: \(campaign.weight), Promotions: \(campaign.promotions.count)")
        for promotion in campaign.promotions {
          print("  - Promotion: \(promotion.id), Title: \(promotion.title ?? "No title")")
        }
      }
    } catch {
      print("Failed to fetch campaign config: \(error)")
    }
  }
}

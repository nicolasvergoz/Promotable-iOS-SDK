# Promotable

A lightweight Swift package to manage and display in-app self-promotion campaigns.

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platforms](https://img.shields.io/badge/platforms-iOS%2017.0%2B%20%7C%20macOS%2014.0%2B-lightgrey.svg)
![License](https://img.shields.io/badge/license-MPL--2.0-blue.svg)
![Version](https://img.shields.io/badge/version-0.1.0-green.svg)

## Overview

Promotable is a Swift Package that provides a lightweight and extensible system for managing and displaying in-app self-promotion campaigns. It helps developers promote their own apps, updates, or affiliated projects within their mobile portfolio.

### Key Features

- Remote configuration of campaigns and promotions through a structured JSON format
- Targeting support by platform and language
- Weighted display logic for balanced promotion visibility
- Impression tracking and display rules
- Dynamic adaptation to new remotely pushed content
- Default SwiftUI implementation for promotional interstitials
- Modern Swift architecture with Swift Concurrency

## Installation

### Swift Package Manager

Add Promotable to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/promotable-ios-sdk.git", from: "0.1.0")
]
```

## Usage

### Basic Setup

```swift
import Promotable

// Create a campaign manager
let campaignManager = CampaignManager()

// Configure with a JSON URL
try await campaignManager.configure(with: URL(string: "https://your-domain.com/campaigns.json")!)

// Use the default presenter in SwiftUI
struct ContentView: View {
    @State private var showPromotion: Bool = false
    
    var body: some View {
        Button("Show Promotion") {
            showPromotion = true
        }
        .promotionPresenter(
            isPresented: $showPromotion,
            campaignManager: campaignManager
        )
    }
}
```

### Custom Configuration

You can implement your own config fetcher by conforming to the `ConfigFetcher` protocol:

```swift
struct MyCustomConfigFetcher: ConfigFetcher {
    func fetchConfig() async throws -> CampaignsResponse {
        // Your custom implementation
    }
}

// Then use it with the campaign manager
let customFetcher = MyCustomConfigFetcher()
let campaignManager = CampaignManager(configFetcher: customFetcher)
```

### Custom Presentation

You can create your own promotion view instead of using the default one:

```swift
struct MyCustomPromotionView: View {
    let promotion: Promotion
    let onDismiss: () -> Void
    let onAction: () -> Void
    
    var body: some View {
        // Your custom promotion view implementation
    }
}

// Use it with the promotion presenter
.promotionPresenter(
    isPresented: $showPromotion,
    campaignManager: campaignManager,
    content: { promotion, dismiss, action in
        MyCustomPromotionView(
            promotion: promotion,
            onDismiss: dismiss,
            onAction: action
        )
    }
)
```

## JSON Configuration Format

Promotable uses a structured JSON format to configure campaigns and promotions. Here's a basic example:

```json
{
  "schema_version": "1.0",
  "campaigns": [
    {
      "id": "new_app_promotion",
      "active": true,
      "target": {
        "platforms": ["ios", "macos"],
        "languages": ["en", "fr"]
      },
      "promotions": [
        {
          "id": "main_promotion",
          "weight": 100,
          "title": "Check Out Our New App!",
          "subtitle": "Enhance your productivity with our latest tool",
          "content": "Our new app helps you organize your workflow...",
          "icon": {
            "url": "https://example.com/icon.png",
            "size": {
              "width": 120,
              "height": 120
            }
          },
          "cover": {
            "url": "https://example.com/cover.jpg"
          },
          "action": {
            "title": "Download Now",
            "url": "https://apps.apple.com/app/id123456789",
            "background_color": "#FF5733"
          }
        }
      ]
    }
  ]
}
```

### JSON Schema Location

The JSON schema used for campaign configuration validation is located in the repository at:

```
Sources/promotable-ios-sdk/campaigns.schema.json
```

This file defines the structure and validation rules for campaign configuration JSON payloads used by the SDK.

You can use this schema to validate your own JSON configuration files before integrating them with the SDK. This helps ensure compatibility and catch errors early. The schema can be used with standard JSON schema validation tools or libraries in your preferred language.

For a quick and easy validation, you can also use the online tool [jsonschemavalidator.net](https://www.jsonschemavalidator.net) to check your configuration against the schema.

**Note:** The JSON schema will be moved to a separate repository in the future for better versioning and documentation.

## Components

Promotable includes several public components that you can use to build custom promotion presentations:

- `DefaultPromotionView`: The default full-screen promotion view
- `PromotionActionButton`: A styled button for promotion actions
- `PromotionCloseButton`: A close button for dismissing promotions
- `PromotionCoverView`: A view for displaying promotion cover images
- `PromotionHeaderView`: A view for displaying promotion headers
- `PromotionContentView`: A view for displaying promotion content

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 6.0+
- Xcode 15.0+

## License

Promotable is available under the Mozilla Public License 2.0. See the [LICENSE](LICENSE) file for more info.

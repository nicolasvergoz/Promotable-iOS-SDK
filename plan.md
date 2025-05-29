**Promotable** is a swift package to manage and display in-app self-promotion campaigns.

## Description
This Swift module provides a lightweight and extensible system for managing and displaying in-app self-promotion campaigns. It handles remote configuration of campaigns and promotions through a structured JSON format, supports targeting by platform and language, and balances display frequencies using weighted logic. Designed with Swift Concurrency and SwiftUI in mind, the module provide a default SwiftUI implementation to present promotional interstitials. It tracks impressions, respects display rules, and adapts dynamically as new content is pushed remotely, making it ideal for developers who want to promote their own apps, updates, or affiliated projects within their mobile portfolio.

## Dev Project
- The module is a Swift Package, with clear separation of concerns and responsibilities
- Keep files small and modular
- Use service-based architecture with clear boundaries
- Each step and feature should be tested as unit tests or end-to-end tests
- Swift 6 with Swift Concurrency
- SwiftUI

# Plan

## Setup Swift Module
The module will be for iOS 16 minimum. 
Should have a target test based on Swift Testing to run end-to-end and unit tests.

## JSON structure
- Defined the structure of the JSON file that will be consume by the module to setup the campaigns and promotions.
- Create a mock JSON

## Implement Codable Model
Create Models to decode the JSON file into Swift structs

## Campaign Manager
- Manage campaigns and promotions
- Select what promotion to display by campaign and promotion weight to balance the visibility of each.
- Store displaying data for balancing and stats
- Reset data when configuration has changed
- Handle targeting conditions (language, platform)

## Default presented Layout
- The module can present a promotion with a built-in SwiftUI layout by default
- It's displayed as a fullscreencover
- Design can be find in this Figma as light or dark mode https://www.figma.com/design/66s6J6drkwzKN5YFB7BoJh/Promotable?node-id=79-73&t=jy4acHtrQUf9W6tJ-4
- Use the default SwiftUI color `primary` and `background` for the colors.
- Images come from remote URLs
- Almost everything is optional, so can be ignored in the layout if nil or empty. What is mandatory are, the action button and close button.
- Only the close button or action button can dismiss the presented view
- The layout should be as simple as possible

## Dominant color top
- Make a new file for this feature
- Take the top 10% of an image and extract the dominant color the top 10% of the image to extract the dominant color
- Use code from this outdated cocoapod: https://github.com/BomberFish/swift-vibrant
- Use this feature in DefaultPresentedPromotionView.swift as the top border color in the ignored safe area when a cover image is provided
- Blend the image and the top border color with blur
- Use the dominant color as action color background, and figure out the text color based on the dominant color

## Presenter
- ViewModifier that can be put on views to present a promotion
- Can display the default layout, or a custom one
- Use CampaignManager to handle what promotion to use
- When to display is not the responsibility of the module/presenter. Add a parameter so the developer can decide when to trigger de presented view

## Json config fetcher as protocol
- Make a protocol to fetch the campaign config json file
- The developer will implement the protocol, so the manager can use it to fetch the json file
- Provide a default implementation, the simplest possible (json url -> GET url session -> JsonString -> Decode (CampaignsResponse))

## Create JSON Schema
- Based on the current CampaignsSample.json create a JSON Schema file

## Add versioning to json schema
- Add a versionning on schema
- Add a schema version to json file
- ConfigFetcher implementations validate schema version before decoding the full model

## Separate stats and balancing
- Separate cumulative display stats and current display weight balancing. But use the same protocol and struct
- Save cumulative display stats in a different user default storage
- Increment both counters when a promotion is displayed
- When the config file has changed, reset only the current display counters

## Test promotion target eligibility
- Test if a campaign is eligible to be displayed based target parameter

## Config versioning
- [x] Chat: Choose a technical solution to determine when to reset the current display counters -> Chosen: Hashable models and hash comparison.
- [x] Implement campaign configuration change detection using Hashable models
  - [x] Make `Campaign` and nested models conform to `Hashable` in `Models/Campaign.swift`
  - [x] Implement logic in `CampaignManager.swift` to store and compare hashes of the `[Campaign]` array.
- [x] When the config file has changed, the manager should act accordingly (reset balancing stats). -> Implemented in `CampaignManager.configure(with:)`.
- [x] Keep the record of all the cumulative view count but reset the current display weight balancing stats. -> This was already part of `CampaignManager` logic, now triggered by hash change.
- [x] Test config change, and check for stats are reset and cumulative are persisted.

## Clean up code base
- [x] Make the module's classes/structs/methods/init/properties public when it's needed outside the module
- [x] Rearrange files and folders
- [x] Suggest better namings for files, folders, classes, methods, properties, etc.
- [x] Add comments in code when it's tricky and remove comments when the code is clear
- [x] Add documentation comments on methods and classes. With a description and example when it's needed
- [x] Remove any personal identity names from files
- [x] Review code, file by file
- [x] Handle TODOS

## Make views public
Views and components can be used by the developer to present a promotion in their app.
- [x] Make DefaultPromotionView public
- [x] Make PromotionActionButton public
- [x] Make PromotionCloseButton public
- [x] Make PromotionCoverView public
- [x] Make PromotionHeaderView public
- [x] Make PromotionContentView public

## Update DominantColorExtractor
- [x] Add action background color in promotion: schema/json/models
- [x] Change strategy: 
  - if provided: use action button background color 
  - else if: cover provided: use cover dominant color
  - else if: icon provided: use icon dominant color
  - else: use system background color
- [x] Remove the topPercentage parameter and "top" notion in dominant color extractor
- [x] Always use 100% of the image to get the dominant color
- [x] Determine the most suitable text color based on the previously determined accent color in DefaultPromotionView

## Prepare for public github repository
- [ ] Version the module 0.1.0
- [ ] Add a README file to explain the code
- [ ] Explain that json schema will be move to a separated repository

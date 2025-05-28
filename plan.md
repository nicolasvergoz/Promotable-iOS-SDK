**Promotable** is a swift package to manage and display in-app self-promotion campaigns.

## Description
This Swift module provides a lightweight and extensible system for managing and displaying in-app self-promotion campaigns. It handles remote configuration of campaigns and promotions through a structured JSON format, supports targeting by platform and locale, and balances display frequencies using weighted logic. Designed with Swift Concurrency and SwiftUI in mind, the module provide a default SwiftUI implementation to present promotional interstitials. It tracks impressions, respects display rules, and adapts dynamically as new content is pushed remotely, making it ideal for developers who want to promote their own apps, updates, or affiliated projects within their mobile portfolio.

## Dev Project
- The module is a Swift Package, with clear separation of concerns and responsibilities
- Keep files small and modular
- Use service-based architecture with clear boundaries
- Each step and feature should be tested as unit tests or end-to-end tests
- Swift 6 with Swift Concurrency
- SwiftUI

# Plan
- [x] Setup Swift Module
- [x] JSON structure
- [x] Decodable Model
- [x] Implement Codable Model
- [x] Campaigns Manager
- [x] Default presented Layout
- [x] Dominant color top
- [x] Presenter
- [x] Json config fetcher as protocol
- [x] Create JSON Schema
- [x] Add versioning to json schema
- [ ] Rework Targeting
- [ ] Config file versionning
- [ ] Clean up
- [ ] Prepare for public github repository

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
- Handle targeting conditions (locale, platform)

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

## Rework Targeting
Since json can be fetched from different platforms with specific targeting criterias, we should find a new way to handle targeting, based on a collection of rules with key, condition and values.
Like: plateform, device, locale, appVersion, region, in-app page, website page type, web page zoning, etc.

Here is a suggestion sample of the target property:

```json
"target": {
  "rules": [
    { "key": "platform", "op": "equals", "value": "ios" },
    { "key": "language", "op": "in", "value": ["en", "fr"] },
    { "key": "appVersion", "op": "greaterThanOrEqual", "value": "2.1.0" },
    { "key": "deviceType", "op": "equals", "value": "tablet" },
    { "key": "page", "op": "equals", "value": "Home" },
    { "key": "region", "op": "notEquals", "value": "CN" }
  ],
  "startDate": "2025-05-17T00:00:00Z",
  "endDate": "2025-06-17T00:00:00Z"
}
```

- Challenge this approach and validate if ok
- Add target property to campaign and promotion json. We add target on both because we could have a campaign targeting ios, and a promotion targeting french.
- Promotion target narrow down campaign target
- Both are optional
- The manager will be initialized with a collection of key/value that will be used to evaluate the targeting conditions.
- Do not update the json schema version, I'm still developing the first version.
- If **all** the local key/value match **some** of the rules of targeting from the config campaign and promotion, the campaign is eligible. Update CampaignManager to handle this logic.
- Test the new targeting logic in the module test target

## Config versionning
- Chat: Choose a technical solution to determine when to reset the current display counters
- When the config file has changed, the manager should act accordingly
- Keep a record of all the cumulative view count by promotion and campaign ids but reset the current display weight balancing mechanism

## Clean up
- Make the module classes/structs/methods/init/properties public when it's needed outside the module
- Rearrange files and folders
- Review code, file by file
- Suggest few code refactors when necessary
- Add comments in code when it's tricky
- Add document comments on methods and classes. With a description and example when it's needed
- Remove any personal identity names from files

## Prepare for public github repository
- Add a README file to explain the code

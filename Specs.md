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
- [ ] Dominant color top
- [ ] Presenter
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
- When the cover image is available, take the top 10% of the image and extract the dominant color
- Use this color as the top border color in the ignored safe area
- Blend the image and the top border color with blur
- Use the dominant color as action color background, and figure out the text color based on the dominant color

## Presenter
- ViewModifier that can be put on views to present a promotion
- Can display the default layout, or a custom one
- Use CampaignManager to handle what promotion to use
- When to display is not the responsibility of the module/presenter. Add a parameter so the developer can decide when to trigger de presented view

## Clean up
- Review code, file by file
- Suggest few code refactors when necessary
- Add common comments in code when it's tricky
- Add doc comments on methods and class. With a description when it's needed
- Remove any personal identity names from files

## Prepare for public github repository
- Add a README file to explain the code
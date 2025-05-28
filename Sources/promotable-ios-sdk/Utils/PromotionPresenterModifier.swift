import SwiftUI

enum PromotionPresentationMode {
  case sheet
  case fullScreen
}

struct PromotionPresenterModifier<PromotionView: View>: ViewModifier {
  @Binding var isPresented: Bool
  let campaignManager: CampaignManager
  let presentationMode: PromotionPresentationMode
  let interactiveDismissDisabled: Bool
  let content: (Campaign.Promotion) -> PromotionView

  @State private var promotion: Campaign.Promotion?

  func body(content base: Content) -> some View {
    base
      .background {
        PresentationModifier()
      }
      .task(id: isPresented) { @MainActor in
        if isPresented {
          promotion = await campaignManager.nextPromotion()
        }
      }
  }

  @ViewBuilder
  private func PresentationModifier() -> some View {
    switch presentationMode {
    case .sheet:
      Color.clear
        .sheet(isPresented: $isPresented) {
          if let promo = promotion {
            self.content(promo)
              .interactiveDismissDisabled(interactiveDismissDisabled)
          }
        }

    case .fullScreen:
      Color.clear
        .fullScreenCover(isPresented: $isPresented) {
          if let promo = promotion {
            self.content(promo)
              .interactiveDismissDisabled(interactiveDismissDisabled)
          }
        }
    }
  }
}

extension View {
  func promotionPresenter<PromotionView: View>(
    isPresented: Binding<Bool>,
    campaignManager: CampaignManager,
    presentationMode: PromotionPresentationMode = .fullScreen,
    interactiveDismissDisabled: Bool = true,
    content: @escaping (Campaign.Promotion) -> PromotionView
  ) -> some View {
    modifier(PromotionPresenterModifier(
      isPresented: isPresented,
      campaignManager: campaignManager,
      presentationMode: presentationMode,
      interactiveDismissDisabled: interactiveDismissDisabled,
      content: content
    ))
  }
}

@available(iOS 17.0, macOS 15.0, *)
#Preview {
  @Previewable @State var isPresented: Bool = false
  
  let manager = CampaignManager(
    language: "en",
    platform: "ios"
  )
  
  Button("Present") {
    isPresented = true
  }
  .promotionPresenter(
    isPresented: $isPresented,
    campaignManager: manager
  ) { promotion in
    DefaultPromotionView(
      promotion: promotion,
      onDismiss: { isPresented = false },
      onAction: { url in print("ACTION", url.absoluteString ?? "nil" ) }
    )
  }
  .task {
    let fileUrl = Bundle.module.url(forResource: "CampaignsSample", withExtension: "json")!
    
    do {
      // Create a custom fetcher that loads from a local JSON file
      let mockFetcher = MockConfigFetcher()
      try await manager.updateConfig(using: mockFetcher)
    } catch {
      print("ERROR", error)
    }
  }
}

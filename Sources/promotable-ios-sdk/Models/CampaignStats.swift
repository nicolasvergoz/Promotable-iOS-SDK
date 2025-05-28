import Foundation

/// Represents cumulative display statistics for campaigns and promotions
public struct DisplayStats: Sendable {
  let campaigns: [String: Int]
  let promotions: [String: Int]
}

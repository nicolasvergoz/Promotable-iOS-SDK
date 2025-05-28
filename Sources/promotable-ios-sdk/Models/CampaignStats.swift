import Foundation

/// Represents cumulative display statistics for campaigns and promotions
public struct DisplayStats: Sendable {
  public let campaigns: [String: Int]
  public let promotions: [String: Int]
}

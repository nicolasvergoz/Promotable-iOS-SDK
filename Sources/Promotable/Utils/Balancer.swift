import Foundation

/// Balances item selection based on weights and previous display counts
final class Balancer<T: Identifiable> {
  /// Entry combining an item with its weight and display history
  struct Entry {
    let item: T
    let weight: Int
    let displayCounts: Int
  }
  
  private let entries: [Entry]
  
  /// Creates a new balancer with weighted entries
  /// - Parameter entries: Array of entries to balance
  init(_ entries: [Entry]) {
    self.entries = entries.filter { $0.weight > 0 }
  }
  
  /// Selects the most underrepresented item based on weights
  /// - Returns: The selected item or nil if no items available
  func pick() -> T? {
    guard !entries.isEmpty else { return nil }
    
    let totalWeight = entries.map(\.weight).reduce(0, +)
    let totalDisplays = entries.map(\.displayCounts).reduce(0, +)
    
    // Select the element with the greatest relative delay
    let best = entries.max { lhs, rhs in
      let lhsExpected = Double(totalDisplays) * Double(lhs.weight) / Double(totalWeight)
      let rhsExpected = Double(totalDisplays) * Double(rhs.weight) / Double(totalWeight)
      
      let lhsDiff = lhsExpected - Double(lhs.displayCounts)
      let rhsDiff = rhsExpected - Double(rhs.displayCounts)
      
      return lhsDiff < rhsDiff
    }
    
    return best?.item
  }
}

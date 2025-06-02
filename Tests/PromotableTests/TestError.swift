import Foundation

enum TestError: Error {
  case missingJSONFile
  case decoding
  case schemaVersionMismatch(received: String, required: String)
}

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum SwiftRaterError: Error {
  case malformedURL
  case missingBundleIdOrAppId
}

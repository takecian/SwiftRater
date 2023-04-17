#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum SwiftRaterErrorCode: Int {
  case malformedURL = 1000
  case appStoreDataRetrievalFailure
  case appStoreJSONParsingFailure
  case appStoreAppIDFailure
}

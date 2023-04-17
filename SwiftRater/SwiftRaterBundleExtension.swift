#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

internal extension Bundle {
  
  class func bundleID() -> String? {
    return Bundle.main.bundleIdentifier
  }
  
}

//
//  deviceModel.swift
//
//  Created by Tobias Hales on 12/18/2023.
//  Copyright © 2025 TobiasHales. All rights reserved.

// Updated by Tobias Hales on 10/06/2025
//

import Foundation
import UIKit

public extension UIDevice {

    // MARK: - Device List
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        print(identifier)

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
                    
                //** Including All Devices Of Each Family Since Their Inception **
                    
                // MARK: - iPhone
                case "iPhone1,1":                                       return "iPhone"
                case "iPhone1,2":                                       return "iPhone 3G"
                case "iPhone2,1":                                       return "iPhone 3GS"
                case "iPhone3,1", "iPhone3,2", "iPhone3,3":             return "iPhone 4"
                case "iPhone4,1":                                       return "iPhone 4S"
                case "iPhone5,1", "iPhone5,2":                          return "iPhone 5"
                case "iPhone5,3", "iPhone5,4":                          return "iPhone 5C"
                case "iPhone6,1", "iPhone6,2":                          return "iPhone 5S"
                case "iPhone7,1":                                       return "iPhone 6 Plus"
                case "iPhone7,2":                                       return "iPhone 6"
                case "iPhone8,1":                                       return "iPhone 6s"
                case "iPhone8,2":                                       return "iPhone 6s Plus"
                case "iPhone8,4":                                       return "iPhone SE"
                case "iPhone9,1", "iPhone9,3":                          return "iPhone 7"
                case "iPhone9,2", "iPhone9,4":                          return "iPhone 7 Plus"
                case "iPhone10,1", "iPhone10,4":                        return "iPhone 8"
                case "iPhone10,2", "iPhone10,5":                        return "iPhone 8 Plus"
                case "iPhone10,3", "iPhone10,6":                        return "iPhone X"
                case "iPhone11,2":                                      return "iPhone XS"
                case "iPhone11,4", "iPhone11,6":                        return "iPhone XS Max"
                case "iPhone11,8":                                      return "iPhone XR"
                case "iPhone12,1":                                      return "iPhone 11"
                case "iPhone12,3":                                      return "iPhone 11 Pro"
                case "iPhone12,5":                                      return "iPhone 11 Pro Max"
                case "iPhone12,8":                                      return "iPhone SE 2"
                case "iPhone13,1":                                      return "iPhone 12 Mini"
                case "iPhone13,2":                                      return "iPhone 12"
                case "iPhone13,3":                                      return "iPhone 12 Pro"
                case "iPhone13,4":                                      return "iPhone 12 Pro Max"
                case "iPhone14,2":                                      return "iPhone 13 Pro"
                case "iPhone14,3":                                      return "iPhone 13 Pro Max"
                case "iPhone14,4":                                      return "iPhone 13 Mini"
                case "iPhone14,5":                                      return "iPhone 13"
                case "iPhone14,6":                                      return "iPhone SE 3"
                case "iPhone14,7":                                      return "iPhone 14"
                case "iPhone14,8":                                      return "iPhone 14 Plus"
                case "iPhone15,2":                                      return "iPhone 14 Pro"
                case "iPhone15,3":                                      return "iPhone 14 Pro Max"
                case "iPhone15,4":                                      return "iPhone 15"
                case "iPhone15,5":                                      return "iPhone 15 Plus"
                case "iPhone16,1":                                      return "iPhone 15 Pro"
                case "iPhone16,2":                                      return "iPhone 15 Pro Max"
                case "iPhone17,1":                                      return "iPhone 16 Pro"
                case "iPhone17,2":                                      return "iPhone 16 Pro Max"
                case "iPhone17,3":                                      return "iPhone 16"
                case "iPhone17,4":                                      return "iPhone 16 Plus"
                case "iPhone17,5":                                      return "iPhone 16e"
                case "iPhone18,3":                                      return "iPhone 17"
                case "iPhone18,4":                                      return "iPhone Air"
                case "iPhone18,1":                                      return "iPhone 17 Pro"
                case "iPhone18,2":                                      return "iPhone 17 Pro Max"
                

                // MARK: - iPod
                case "iPod1,1":                                         return "iPod 1"
                case "iPod2,1":                                         return "iPod 2"
                case "iPod3,1":                                         return "iPod 3"
                case "iPod4,1":                                         return "iPod 4"
                case "iPod5,1":                                         return "iPod 5"
                case "iPod7,1":                                         return "iPod 6"
                case "iPod9,1":                                         return "iPod 7"

                // MARK: - iPad
                case "iPad1,1", "iPad1,2":                              return "iPad"
                case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":        return "iPad 2"
                case "iPad3,1", "iPad3,2", "iPad3,3":                   return "iPad 3"
                case "iPad3,4", "iPad3,5", "iPad3,6":                   return "iPad 4"
                case "iPad6,11", "iPad6,12":                            return "iPad 5"
                case "iPad7,5", "iPad7,6":                              return "iPad 6"
                case "iPad7,11", "iPad7,12":                            return "iPad 7"
                case "iPad11,6", "iPad11,7":                            return "iPad 8"
                case "iPad12,1", "iPad12,2":                            return "iPad 9"
                case "iPad13,18", "iPad13,19":                          return "iPad 10"
                case "iPad15,7", "iPad15,8":                            return "iPad 11"

                // MARK: - iPad Air
                case "iPad4,1", "iPad4,2", "iPad4,3":                   return "iPad Air"
                case "iPad5,3", "iPad5,4":                              return "iPad Air 2"
                case "iPad11,3", "iPad11,4":                            return "iPad Air 3"
                case "iPad13,1", "iPad13,2":                            return "iPad Air 4"
                case "iPad13,16", "iPad13,17":                          return "iPad Air 5"
                case "iPad14,8", "iPad14,9":                            return "iPad Air 6"
                case "iPad14,10", "iPad14,11":                          return "iPad Air 7"

                // MARK: - iPad Mini
                case "iPad2,5", "iPad2,6", "iPad2,7":                   return "iPad Mini"
                case "iPad4,4", "iPad4,5", "iPad4,6":                   return "iPad Mini 2"
                case "iPad4,7", "iPad4,8", "iPad4,9":                   return "iPad Mini 3"
                case "iPad5,1", "iPad5,2":                              return "iPad Mini 4"
                case "iPad11,1", "iPad11,2":                            return "iPad Mini 5"
                case "iPad14,1", "iPad14,2":                            return "iPad Mini 6"
                case "iPad15,1", "iPad15,2":                            return "iPad Mini 7"

                // MARK: - iPad Pro 9.7
                case "iPad6,3", "iPad6,4":                              return "iPad Pro 9.7-inch"

                // MARK: - iPad Pro 10.5
                case "iPad7,3", "iPad7,4":                              return "iPad Pro 10.5-inch"

                // MARK: - iPad Pro 11-inch
                case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":        return "iPad Pro 11-inch 1"
                case "iPad8,9", "iPad8,10":                             return "iPad Pro 11-inch 2"
                case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":    return "iPad Pro 11-inch 3"
                case "iPad14,3", "iPad14,4":                            return "iPad Pro 11-inch 4"
                case "iPad16,3", "iPad16,4":                            return "iPad Pro 11-inch 5"

                // MARK: - iPad Pro 12.9
                case "iPad6,7", "iPad6,8":                              return "iPad Pro 12.9-inch"
                case "iPad7,1", "iPad7,2":                              return "iPad Pro 12.9-inch 2"
                case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":        return "iPad Pro 12.9-inch 3"
                case "iPad8,11", "iPad8,12":                            return "iPad Pro 12.9-inch 4"
                case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":  return "iPad Pro 12.9-inch 5"
                case "iPad14,5", "iPad14,6":                            return "iPad Pro 12.9-inch 6"
                case "iPad16,5", "iPad16,6":                            return "iPad Pro 12.9-inch 7"

                
                //Other
                case "i386", "x86_64", "arm64":                          return "\(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
                default:                                                return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()
    
    
    
    
    
    // MARK: - isIPad
    static var isIPad: Bool {
        let modelName = UIDevice.modelName
        return modelName.contains("iPad")
    }
    
    // MARK: - isIPhoneNoEars
    static var isIPhoneNoEars: Bool {
        let modelName = UIDevice.modelName
        return modelName == "iPod Touch 5" || modelName == "iPod Touch 6" || modelName == "iPod Touch 7" ||
               modelName == "iPhone 4" || modelName == "iPhone 4s" ||
               modelName == "iPhone 5" || modelName == "iPhone 5c" || modelName == "iPhone 5s" ||
               modelName == "iPhone 6" || modelName == "iPhone 6 Plus" || modelName == "iPhone 6s" || modelName == "iPhone 6s Plus" ||
               modelName == "iPhone 7" || modelName == "iPhone 7 Plus" ||
               modelName == "iPhone 8" || modelName == "iPhone 8 Plus" ||
               modelName == "iPhone SE" || modelName == "iPhone SE 2" || modelName == "iPhone SE 3"
    }
    
    // MARK: - isIPhoneEars
    static var isIPhoneEars: Bool {
        let modelName = UIDevice.modelName
        return modelName == "iPhone X" || modelName == "iPhone XS" || modelName == "iPhone XS Max" || modelName == "iPhone XR" ||
               modelName == "iPhone 11" || modelName == "iPhone 11 Pro" || modelName == "iPhone 11 Pro Max" ||
               modelName == "iPhone 12 Mini" || modelName == "iPhone 12" || modelName == "iPhone 12 Pro" || modelName == "iPhone 12 Pro Max" ||
               modelName == "iPhone 13 Mini" || modelName == "iPhone 13" || modelName == "iPhone 13 Pro" || modelName == "iPhone 13 Pro Max" ||
               modelName == "iPhone 14" || modelName == "iPhone 14 Plus" || modelName == "iPhone 14 Pro" || modelName == "iPhone 14 Pro Max" ||
               modelName == "iPhone 15" || modelName == "iPhone 15 Plus" || modelName == "iPhone 15 Pro" || modelName == "iPhone 15 Pro Max" ||
               modelName == "iPhone 16" || modelName == "iPhone 16 Plus" || modelName == "iPhone 16 Pro" || modelName == "iPhone 16 Pro Max" ||
               modelName == "iPhone 16e" || modelName == "iPhone 17" || modelName == "iPhone 17 Pro" || modelName == "iPhone 17 Pro Max" || modelName == "iPhone Air"
    }

    // MARK: - isAppleTV
    static var isAppleTV: Bool {
        #if os(tvOS)
        return true
        #else
        return UIDevice.current.userInterfaceIdiom == .tv
        #endif
    }
    
    // MARK: - hasProMotion
    static var hasProMotion: Bool {
        let modelName = UIDevice.modelName
        return modelName == "iPhone 13 Pro" || modelName == "iPhone 13 Pro Max" || modelName == "iPhone 14 Pro" || modelName == "iPhone 14 Pro Max" || modelName == "iPhone 15 Pro" || modelName == "iPhone 15 Pro Max" || modelName == "iPhone 16 Pro" || modelName == "iPhone 16 Pro Max" || modelName == "iPhone 17" || modelName == "iPhone Air" || modelName == "iPhone 17 Pro" || modelName == "iPhone 17 Pro Max" || modelName == "iPad Pro 12.9-inch 2" || modelName == "iPad Pro 12.9-inch 3" || modelName == "iPad Pro 12.9-inch 4" || modelName == "iPad Pro 12.9-inch 5" || modelName == "iPad Pro 12.9-inch 6" || modelName == "iPad Pro 12.9-inch 7" ||
               modelName == "iPad Pro 10.5-inch" ||
               modelName == "iPad Pro 11-inch 1" || modelName == "iPad Pro 11-inch 2" || modelName == "iPad Pro 11-inch 3" || modelName == "iPad Pro 11-inch 4" || modelName == "iPad Pro 11-inch 5"
    }

}

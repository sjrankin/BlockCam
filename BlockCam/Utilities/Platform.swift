//
//  Platform.swift
//  BlockCam
//  Adapted from Fouris and BumpCamera.
//
//  Created by Stuart Rankin on 12/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import Metal
import AVFoundation

/// Functions to get information about the platform upon which we are running.
class Platform
{
    /// Break a number (presumably the string sent is a number) into groups of three digits separated by a
    /// specified separator.
    /// - Parameters:
    ///   - Raw: The number (in string format) to separate.
    ///   - Separator: The string to use separate groups.
    /// - Returns: String of digits (or anything, really) separated into groups of three, separated by the
    ///            specified separator string.
    private static func SeparateNumber(_ Raw: String, Separator: String) -> String
    {
        if Raw.count <= 3
        {
            return Raw
        }
        let Working = String(Raw.reversed())
        var Final = ""
        for i in 0 ..< Working.count
        {
            let CharIndex = Working.index(Working.startIndex, offsetBy: i)
            let AChar = String(Working[CharIndex])
            if i > 0 && i % 3 == 0
            {
                Final = Final + Separator
            }
            Final = Final + AChar
        }
        Final = String(Final.reversed())
        if String(Final.first!) == Separator
        {
            Final.removeFirst()
        }
        return Final
    }
    
    /// Convert the passed UInt64 value into a string, separated into groups of three.
    /// - Parameters:
    ///   - Raw: The UInt64 to convert and format.
    ///   - Separator: The string to separate the groups of digits.
    /// - Returns: Value converted to a string with separators breaking the value into groups of three each.
    public static func MakeSeparatedNumber(_ Raw: UInt64, Separator: String) -> String
    {
        let SRaw = "\(Raw)"
        return SeparateNumber(SRaw, Separator: Separator)
    }
    
    /// Convert the passed UInt value into a string, separated into groups of three.
    /// - Parameters:
    ///   - Raw: The UInt to convert and format.
    ///   - Separator: The string to separate the groups of digits.
    /// - Returns: Value converted to a string with separators breaking the value into groups of three each.
    public static func MakeSeparatedNumber(_ Raw: UInt, Separator: String) -> String
    {
        let SRaw = "\(Raw)"
        return SeparateNumber(SRaw, Separator: Separator)
    }
    
    /// Convert the passed Int value into a string, separated into groups of three.
    /// - Parameters:
    ///   - Raw: The Int to convert and format.
    ///   - Separator: The string to separate the groups of digits.
    /// - Returns: Value converted to a string with separators breaking the value into groups of three each.
    public static func MakeSeparatedNumber(_ Raw: Int, Separator: String) -> String
    {
        let SRaw = "\(Raw)"
        return SeparateNumber(SRaw, Separator: Separator)
    }
    
    /// Returns the type of processor architecture we're running on.
    /// - Returns: String description of the processor's architecture.
    public static func MachineType() -> String
    {
        var SysInfo = utsname()
        uname(&SysInfo)
        let Name = withUnsafePointer(to: &SysInfo.machine.0)
        {
            ptr in
            return String(cString: ptr)
        }
        return Name
    }
    
    /// Returns the user's name for the device.
    /// - Returns: Name of the device as given by the user.
    public static func SystemName() -> String
    {
        var SysInfo = utsname()
        uname(&SysInfo)
        let Name = withUnsafePointer(to: &SysInfo.nodename.0)
        {
            ptr in
            return String(cString: ptr)
        }
        let Parts = Name.split(separator: ".")
        return String(Parts[0])
    }
    
    /// Returns the Kernel name and version.
    /// - Returns: OS kernel name and version.
    public static func KernelInfo() -> String
    {
        var SysInfo = utsname()
        uname(&SysInfo)
        let Name = withUnsafePointer(to: &SysInfo.nodename.0)
        {
            ptr in
            return String(cString: ptr)
        }
        let Parts = Name.split(separator: ":")
        return String(Parts[0])
    }
    
    /// Return the OS version.
    /// - Returns: OS version we're running on.
    public static func OSVersion() -> String
    {
        let SysVer = UIDevice.current.systemVersion
        return SysVer
    }
    
    /// Name of the OS.
    /// - Returns: OS name.
    public static func SystemOSName() -> String
    {
        return UIDevice.current.systemName
    }
    
    /// Return a string indicating the system pressure. System pressure is essentially a thermal measurement - the hotter the
    /// device, the more pressure is being applied to the system. Once the device reaches .shutdown, the system will turn itself
    /// off to protect itself from damage.
    /// - Note: "Pressure" in this case has nothing to do with barametric pressure.
    /// - Returns: String indicating thermal system pressure. One of: Nominal, Fair, Serious, Critical, Catastrophic, and Unknown.
    public static func GetSystemPressure() -> String
    {
        let VideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,
                                                                                         .builtInWideAngleCamera],
                                                                           mediaType: .video,
                                                                           position: .unspecified)
        let DefaultVideoDevice: AVCaptureDevice? = VideoDeviceDiscoverySession.devices.first
        let Pressure = DefaultVideoDevice?.systemPressureState
        switch (Pressure?.level)!
        {
            case .nominal:
                return "Nominal"
            
            case .fair:
                return "Fair"
            
            case .serious:
                return "Serious"
            
            case .critical:
                return "Critical"
            
            case .shutdown:
                return "Catastrophic"
            
            default:
                return "Unknown"
        }
    }
    
    /// Return the amount of RAM (used and unused) on the system.
    /// - Note: [Determining the Available Amount of RAM on an iOS Device](https://stackoverflow.com/questions/5012886/determining-the-available-amount-of-ram-on-an-ios-device)
    /// - Returns: Tuple with the values (Used memory, free memory).
    public static func RAMSize() -> (Int64, Int64)
    {
        var PageSize: vm_size_t = 0
        let HostPort: mach_port_t = mach_host_self()
        var HostSize: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.stride / MemoryLayout<integer_t>.stride)
        host_page_size(HostPort, &PageSize)
        var vm_stat: vm_statistics = vm_statistics_data_t()
        withUnsafeMutablePointer(to: &vm_stat)
        {
            (vmStatPointer) -> Void in
            vmStatPointer.withMemoryRebound(to: integer_t.self, capacity: Int(HostSize))
            {
                if host_statistics(HostPort, HOST_VM_INFO, $0, &HostSize) != KERN_SUCCESS
                {
                    print("Error: failed to get vm statistics")
                }
            }
        }
        let MemUsed: Int64 = Int64(vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * Int64(PageSize)
        let MemFree: Int64 = Int64(vm_stat.free_count) * Int64(PageSize)
        return (MemUsed, MemFree)
    }
    
    /// Return the battery level percent.
    /// - Returns: Percent full the battery is. If monitoring not enabled, nil is returned.
    public static func BatteryLevel() -> Float?
    {
        if UIDevice.current.isBatteryMonitoringEnabled
        {
            return UIDevice.current.batteryLevel
        }
        else
        {
            return nil
        }
    }
    
    /// Enable or disable battery monitoring.
    /// - Parameter Enabled: Value to control battery monitoring.
    public static func MonitorBatteryLevel(_ Enabled: Bool)
    {
        UIDevice.current.isBatteryMonitoringEnabled = Enabled
    }
    
    /// Return a string of the name of the device.
    /// - Note: [How to determine the current iPhone device model](https://stackoverflow.com/questions/26028918/how-to-determine-the-current-iphone-device-model)
    /// - Returns: String describing the current device.
    public static func NiceModelName() -> String
    {
        let ModelType = UIDevice.current.SystemType
        let ModelTypeString = ModelType.rawValue
        return ModelTypeString
    }
    
    /// Return the name of the processor and its nominal operating frequency. Derived from static tables.
    /// - Returns: Tuple of the name of the processor and nominal operating frequency (in string format).
    public static func GetProcessorInfo() -> (String, String)
    {
        let (CPUName, CPUFrequency) = Processor[UIDevice.current.SystemType]!
        return (CPUName, CPUFrequency)
    }
    
    /// Determines if the back camera has true depth capabilities.
    /// - Returns: True if the back camera supports true depth, false if not.
    public static func HasTrueDepthCamera() -> Bool
    {
        return GetCameraResolution(CameraType: .builtInTrueDepthCamera, Position: .back) != nil
    }
    
    /// Determines if the back camera has a built-in telephoto lens.
    /// - Returns: True if the back camera has a telephoto lens, false if not.
    public static func HasTelephotoCamera() -> Bool
    {
        return GetCameraResolution(CameraType: .builtInTelephotoCamera, Position: .back) != nil
    }
    
    /// Return the native resolution of the specified camera in the specified position.
    /// - Parameters:
    ///   - CameraType: The camera type to check.
    ///   - Position: The position of the camera.
    /// - Returns: Size of the resolution on success, nil if no such camera found.
    public static func GetCameraResolution(CameraType: AVCaptureDevice.DeviceType, Position: AVCaptureDevice.Position) -> CGSize?
    {
        var Resolution = CGSize.zero
        if let CaptureDevice = AVCaptureDevice.default(CameraType, for: AVMediaType.video, position: Position)
        {
            let Description = CaptureDevice.activeFormat.formatDescription
            let Dimensions = CMVideoFormatDescriptionGetDimensions(Description)
            Resolution = CGSize(width: CGFloat(Dimensions.width), height: CGFloat(Dimensions.height))
            return Resolution
        }
        else
        {
            return nil
        }
    }
    
    /// Return a string that describes the Metal GPU.
    /// - Returns: Metal GPU description.
    public static func MetalGPU() -> String
    {
        let MetalDevice = MTLCreateSystemDefaultDevice()
        var SupportedGPU = ""
        var GPUValue: UInt = 0
        for (GPUFamily, _) in MetalFeatureTable
        {
            if (MetalDevice?.supportsFeatureSet(GPUFamily))!
            {
                if GPUFamily.rawValue > GPUValue
                {
                    GPUValue = GPUFamily.rawValue
                }
            }
        }
        
        let FinalGPU = MTLFeatureSet(rawValue: GPUValue)
        SupportedGPU = MetalFeatureTable[FinalGPU!]!
        return SupportedGPU.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Return a string that describes the Metal device name.
    /// - Returns: Metal device name.
    public static func MetalDeviceName() -> String
    {
        let MetalDevice = MTLCreateSystemDefaultDevice()
        return (MetalDevice?.name)!
    }
    
    /// Return a string of the amount of space currently allocated by Metal.
    /// - Returns: Number of bytes (in string format) allocated by Metal.
    public static func MetalAllocatedSpace() -> String
    {
        let MetalDevice = MTLCreateSystemDefaultDevice()
        let Allocated = MetalDevice?.currentAllocatedSize
        return MakeSeparatedNumber(Allocated!, Separator: ",")
    }
    
    
    #if targetEnvironment(macCatalyst)
    /// Table of GPU families for Metal. Not supported on macCatalyst.
    static let MetalFeatureTable: [MTLFeatureSet: String] = [MTLFeatureSet: String]()
    #else
    /// Table of GPU families for Metal.
    static let MetalFeatureTable: [MTLFeatureSet: String] =
        [
            MTLFeatureSet.iOS_GPUFamily1_v1: "GPU 1, v1",
            MTLFeatureSet.iOS_GPUFamily1_v2: "GPU 1, v2",
            MTLFeatureSet.iOS_GPUFamily1_v3: "GPU 1, v3",
            MTLFeatureSet.iOS_GPUFamily1_v4: "GPU 1, v4",
            MTLFeatureSet.iOS_GPUFamily1_v5: "GPU 1, v5",
            MTLFeatureSet.iOS_GPUFamily2_v1: "GPU 2, v1",
            MTLFeatureSet.iOS_GPUFamily2_v2: "GPU 2, v2",
            MTLFeatureSet.iOS_GPUFamily2_v3: "GPU 2, v2",
            MTLFeatureSet.iOS_GPUFamily2_v4: "GPU 2, v4",
            MTLFeatureSet.iOS_GPUFamily2_v5: "GPU 2, v5",
            MTLFeatureSet.iOS_GPUFamily3_v1: "GPU 3, v1",
            MTLFeatureSet.iOS_GPUFamily3_v2: "GPU 3, v2",
            MTLFeatureSet.iOS_GPUFamily3_v3: "GPU 3, v2",
            MTLFeatureSet.iOS_GPUFamily3_v4: "GPU 3, v4",
            MTLFeatureSet.iOS_GPUFamily4_v1: "GPU 4, v1",
            MTLFeatureSet.iOS_GPUFamily4_v2: "GPU 4, v2",
            MTLFeatureSet.iOS_GPUFamily5_v1: "GPU 5, v1"
    ]
    #endif
    
    /// Table of devices to processor names and nominal frequencies.
    /// - Note: See [Device Specifications](https://www.devicespecifications.com/en/brand/cefa26)
    private static let Processor: [Model: (String, String)] =
        [
            .simulator        : ("N/A", ""),
            .iPad2            : ("A5", "1GHz"),
            .iPad3            : ("A5X", "1GHz"),
            .iPad4            : ("A6X", "1.4GHz"),
            .iPhone4          : ("A4", "800MHz"),
            .iPhone4S         : ("A5", "800MHz"),
            .iPhone5          : ("A6", "1.3GHz"),
            .iPhone5S         : ("A7", "1.3GHz"),
            .iPhone5C         : ("A6", "1.3GHz"),
            .iPadMini1        : ("A5", "1GHz"),
            .iPadMini2        : ("A7", "1.3GHz"),
            .iPadMini3        : ("A7", "1.3GHz"),
            .iPadMini4        : ("A8", "1.5GHz"),
            .iPadAir1         : ("A7", "1.3GHz"),
            .iPadAir2         : ("A8X", "1.5GHz"),
            .iPadPro9_7       : ("A9X", "2.26GHz"),
            .iPadPro9_7_cell  : ("A9X", "2.26GHz"),
            .iPadPro10_5      : ("A10X", "2.36GHz"),
            .iPadPro10_5_cell : ("A10X", "2.36GHz"),
            .iPadPro12_9      : ("A10X Fusion", "2.36GHz"),
            .iPadPro12_9_cell : ("A10X Fusion", "2.36GHz"),
            .iPadPro11        : ("A12X Bionic", "2.5GHz"),
            .iPadPro11_cell   : ("A12X Bionic", "2.5GHz"),
            .iPadPro12_9_3g : ("A12X Bionic", "2.5GHz"),
            .iPadPro12_9_3g_cell: ("A12X Bionic", "2.5GHz"),
            .iPhone6          : ("A8", "1.4GHz"),
            .iPhone6plus      : ("A8", "1.4GHz"),
            .iPhone6S         : ("A8", "1.4GHz"),
            .iPhone6Splus     : ("A8", "1.4GHz"),
            .iPhoneSE         : ("A9", "1.84GHz"),
            .iPhone7          : ("A10", "2.37GHz"),
            .iPhone7plus      : ("A10", "2.37GHz"),
            .iPhone8          : ("A11 Bionic", "2.1GHz"),
            .iPhone8plus      : ("A11 Bionic", "2.1GHz"),
            .iPhoneX          : ("A11 Bionic", "2.39GHz"),
            .iPhoneXS         : ("A12 Bionic", "2.49GHz"),
            .iPhoneXSmax      : ("A12 Bionic", "2.49GHz"),
            .iPhoneXR         : ("A12 Bionic", "2.49GHz"),
            .iPadMini5        : ("A12 Bionic", "2.5GHz"),
            .iPadMini5_cell   : ("A12 Bionic", "2.5GHz"),
            .iPhone11         : ("A13 Bionic", "2.9GHZ"),
            .iPhone11Pro      : ("A13 Bionic", "2.9GHZ"),
            .iPhone11ProMax   : ("A13 Bionic", "2.9GHz"),
            .unrecognized     : ("?unrecognized?", "")
    ]
}

/// Enum of iPads and iPhones supported by this application. Each enum has as its value a human-readable
/// device name.
/// - Note See [How to determine the current iPhone model device](https://stackoverflow.com/questions/26028918/how-to-determine-the-current-iphone-device-model)
public enum Model : String
{
    case simulator   = "simulator/sandbox",
    iPad2            = "iPad 2",
    iPad3            = "iPad 3",
    iPad4            = "iPad 4",
    iPhone4          = "iPhone 4",
    iPhone4S         = "iPhone 4S",
    iPhone5          = "iPhone 5",
    iPhone5S         = "iPhone 5S",
    iPhone5C         = "iPhone 5C",
    iPadMini1        = "iPad Mini 1",
    iPadMini2        = "iPad Mini 2",
    iPadMini3        = "iPad Mini 3",
    iPadMini4        = "iPad Mini 4",
    iPadAir1         = "iPad Air 1",
    iPadAir2         = "iPad Air 2",
    iPadPro9_7       = "iPad Pro 9.7\"",
    iPadPro9_7_cell  = "iPad Pro 9.7\" cellular",
    iPadPro10_5      = "iPad Pro 10.5\"",
    iPadPro10_5_cell = "iPad Pro 10.5\" cellular",
    iPadPro12_9      = "iPad Pro 12.9\"",
    iPadPro12_9_cell = "iPad Pro 12.9\" cellular",
    iPadPro11        = "iPad Pro 11\"",
    iPadPro11_cell   = "iPad Pro 11\" cellular",
    iPadPro12_9_3g   = "iPad Pro 12.9\" 3rd gen",
    iPadPro12_9_3g_cell = "iPad Pro 12.9\" celular 3rd gen",
    iPhone6          = "iPhone 6",
    iPhone6plus      = "iPhone 6 Plus",
    iPhone6S         = "iPhone 6S",
    iPhone6Splus     = "iPhone 6S Plus",
    iPhoneSE         = "iPhone SE",
    iPhone7          = "iPhone 7",
    iPhone7plus      = "iPhone 7 Plus",
    iPhone8          = "iPhone 8",
    iPhone8plus      = "iPhone 8 Plus",
    iPhoneX          = "iPhone X",
    iPhoneXS         = "iPhone XS",
    iPhoneXSmax      = "iPhone XS Max",
    iPhoneXR         = "iPhone XR",
    iPadMini5_cell   = "iPad Mini 5\" cellular",
    iPadMini5        = "iPad Mini 5",
    iPhone11         = "iPhone 11",
    iPhone11Pro      = "iPhone 11 Pro",
    iPhone11ProMax   = "iPhone 11 Pro Max",
    iPad10_2         = "iPad 10.2",
    iPad10_2_cell    = "iPad 10.2\" cellular",
    unrecognized     = "?unrecognized?"
}

/// Extension to UIDevice that returns the model of the current device.
/// - Note See [How to determine the current iPhone model device](https://stackoverflow.com/questions/26028918/how-to-determine-the-current-iphone-device-model)
public extension UIDevice
{
    /// Returns an enum indicating which system we're running on.
    var SystemType: Model
    {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine)
        {
            $0.withMemoryRebound(to: CChar.self, capacity: 1)
            {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        let modelMap : [String : Model] =
            [
                "i386"       : .simulator,
                "x86_64"     : .simulator,
                "iPad2,1"    : .iPad2,
                "iPad2,2"    : .iPad2,
                "iPad2,3"    : .iPad2,
                "iPad2,4"    : .iPad2,
                "iPad2,5"    : .iPadMini1,
                "iPad2,6"    : .iPadMini1,
                "iPad2,7"    : .iPadMini1,
                "iPhone3,1"  : .iPhone4,
                "iPhone3,2"  : .iPhone4,
                "iPhone3,3"  : .iPhone4,
                "iPhone4,1"  : .iPhone4S,
                "iPhone5,1"  : .iPhone5,
                "iPhone5,2"  : .iPhone5,
                "iPhone5,3"  : .iPhone5C,
                "iPhone5,4"  : .iPhone5C,
                "iPad3,1"    : .iPad3,
                "iPad3,2"    : .iPad3,
                "iPad3,3"    : .iPad3,
                "iPad3,4"    : .iPad4,
                "iPad3,5"    : .iPad4,
                "iPad3,6"    : .iPad4,
                "iPhone6,1"  : .iPhone5S,
                "iPhone6,2"  : .iPhone5S,
                "iPad4,1"    : .iPadAir1,
                "iPad4,2"    : .iPadAir2,
                "iPad4,4"    : .iPadMini2,
                "iPad4,5"    : .iPadMini2,
                "iPad4,6"    : .iPadMini2,
                "iPad4,7"    : .iPadMini3,
                "iPad4,8"    : .iPadMini3,
                "iPad4,9"    : .iPadMini3,
                "iPad5,1"    : .iPadMini4,
                "iPad5,2"    : .iPadMini4,
                "iPad6,3"    : .iPadPro9_7,
                "iPad6,11"   : .iPadPro9_7,
                "iPad6,4"    : .iPadPro9_7_cell,
                "iPad6,12"   : .iPadPro9_7_cell,
                "iPad6,7"    : .iPadPro12_9,
                "iPad6,8"    : .iPadPro12_9_cell,
                "iPad7,3"    : .iPadPro10_5,
                "iPad7,4"    : .iPadPro10_5_cell,
                "iPad8,1"    : .iPadPro11,
                "iPad8,2"    : .iPadPro11,
                "iPad8,3"    : .iPadPro11_cell,
                "iPad8,4"    : .iPadPro11_cell,
                "iPad8,5"    : .iPadPro12_9_3g,
                "iPad8,6"    : .iPadPro12_9_3g,
                "iPad8,7"    : .iPadPro12_9_3g_cell,
                "iPad8,8"    : .iPadPro12_9_3g_cell,
                "iPhone7,1"  : .iPhone6plus,
                "iPhone7,2"  : .iPhone6,
                "iPhone8,1"  : .iPhone6S,
                "iPhone8,2"  : .iPhone6Splus,
                "iPhone8,4"  : .iPhoneSE,
                "iPhone9,1"  : .iPhone7,
                "iPhone9,2"  : .iPhone7plus,
                "iPhone9,3"  : .iPhone7,
                "iPhone9,4"  : .iPhone7plus,
                "iPhone10,1" : .iPhone8,
                "iPhone10,2" : .iPhone8plus,
                "iPhone10,3" : .iPhoneX,
                "iPhone10,6" : .iPhoneX,
                "iPhone11,2" : .iPhoneXS,
                "iPhone11,4" : .iPhoneXSmax,
                "iPhone11,6" : .iPhoneXSmax,
                "iPhone11,8" : .iPhoneXR,
                "iPad11,1"   : .iPadMini5,
                "iPad11,2"   : .iPadMini5_cell,
                "iPhone12,1" : .iPhone11,
                "iPhone12,3" : .iPhone11Pro,
                "iPhone12,5" : .iPhone11ProMax,
                "iPad7,11"   : .iPad10_2,
                "iPad7,12"   : .iPad10_2_cell,
        ]
        
        if let model = modelMap[String.init(validatingUTF8: modelCode!)!]
        {
            return model
        }
        return Model.unrecognized
    }
}

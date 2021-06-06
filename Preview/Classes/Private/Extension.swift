//
//  Extension.swift
//  Preview
//
//  Created by seeuli on 2021/5/31.
//

import Foundation

extension Int {
    /// `HH:MM:SS` time format, omit `HH` if less than an hour
    func format_HHMMSS() -> String {
        let hours = self / 60 / 60
        let mins = (self - hours * 3600) / 60
        let secs = self - hours * 60 * 60 - mins * 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, mins, secs)
        }
        else if mins > 0 {
            return String(format: "%02d:%02d", mins, secs)
        }
        return String(format: "00:%02d", secs)
    }
}

extension UIImage {
    /// load image form 3rd library
    ///
    /// if `use_frameworks!` is enable, `UIImage(named: "")` method is useless,
    /// cause image is not in main bundle
    ///
    public static func load(named: String, library: String = "Preview") -> UIImage? {
        assert(named.isEmpty == false && library.isEmpty == false)
        
        let image = UIImage(named: named)
        if image != nil { return image }
        
        let url = Bundle.main.url(forResource: "Frameworks", withExtension: nil)?.appendingPathComponent("\(library).framework")
        if url == nil { return nil }
        
        return UIImage(named: named, in: Bundle(url: url!), compatibleWith: nil)
    }
}

//
//  ImagePreviewProtocol.swift
//  Preview
//
//  Created by seeuli on 2021/5/17.
//

import Foundation
import UIKit

/// preview support type
public enum PreviewType {
    /// Preview text
    case Text(
            content: String? = nil,
            attributedText: NSAttributedString? = nil
         )
    
    /// Preview image
    case Image(
            image: UIImage? = nil,
            named: String? = nil,
            path: String? = nil,
            base64: String? = nil,
            url: URL? = nil
         )
    
    /// Preview video
    case Video(url: URL)
}



/// preview source
public protocol PreviewSource {
    func previewType() -> PreviewType
}

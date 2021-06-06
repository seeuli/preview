//
//  PreviewProtocol_internal.swift
//  Preview
//
//  Created by seeuli on 2021/5/28.
//

import Foundation
import UIKit

/// preview
protocol Previewable: UIViewController {
    var source: PreviewSource { set get }
    var index: Int { set get }
}

enum _PreviewType {
    case text, image, video
}

extension PreviewType {
    func description() -> _PreviewType {
        switch self {
        case .Text(content: _, attributedText: _):
            return .text
        case .Image(image: _, named: _, path: _, base64: _, url: _):
            return .image
        case .Video(url: _):
            return .video
        }
    }
}

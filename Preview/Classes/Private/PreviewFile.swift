//
//  PreviewFile.swift
//  Preview
//
//  Created by seeuli on 2021/5/25.
//

import Foundation
import MobileCoreServices

class PreviewFile {
    let path: String
    
    init(path: String) {
        self.path = path
    }
    
    func contentsOfFile() -> Data? {
        var value = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &value)
        if exists == false || value.boolValue == true {
            return nil
        }
        return FileManager.default.contents(atPath: path)
    }
    
    func isVideoFile() -> Bool {
        return UTTypeConformsTo(fileType() as CFString, kUTTypeVideo)
    }
    
    func isImageFile() -> Bool {
        return UTTypeConformsTo(fileType() as CFString, kUTTypeImage)
    }
    
    func isTextFile() -> Bool {
        return UTTypeConformsTo(fileType() as CFString, kUTTypeText)
    }
    
    private func fileType() -> String  {
        let url = URL(fileURLWithPath: path)
        guard url.isFileURL else { return "" }
        let ext = url.pathExtension
        let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)
        let value = uti?.takeUnretainedValue() as String? ?? ""
        uti?.release()
        return value
    }
}

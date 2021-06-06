//
//  PreviewConfiguration.swift
//  Preview
//
//  Created by seeuli on 2021/5/25.
//

import UIKit
import AVFoundation

public class PreviewConfiguration {
    
    public static let shared = PreviewConfiguration()
    
    init() {
        imageLoader = { (imageView, url) in
            assert(false, "")
        }
    }
    
    func clear() {
        infinite = false
        initialIndex = 0
        previewIndex = 0
        previewIndexChange = nil
        sources.removeAll()
        
        // clear Image Cache
        imageQueue.cancelAllOperations()
        imageCache.removeAll()
        
        // clear Video Cache
//        videoPlayer = nil
//        videoPlayerLayer = nil
//        currentPreviewVideo = nil
    }
    
    /// paging infinite
    public var infinite: Bool = false
    
    /// preview initial index
    var initialIndex: Int = 0
    
    /// current preview index
    var previewIndex = 0

    /// preview index change
    public var previewIndexChange: ((Int, Int) -> Void)? = nil
    
    /// preview sources
    var sources = [PreviewSource]()
    
    /// preview sources and initial Index
    public func setPreview(_ sources: [PreviewSource], initial index: Int) {
        guard sources.isEmpty == false else {
            assert(false, "`sources` can not be empty")
            return
        }
        
        guard self.sources.isEmpty else {
            assert(false, "`sources` can not support change")
            return
        }
        
        self.sources.removeAll()
        self.sources.append(contentsOf: sources)
        initialIndex = index
    }
    
    // MARK: Text
    /// prevew `text attributes`
    public var textAttributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.systemFont(ofSize: 14),
        .foregroundColor : UIColor.white,
    ]
    
    /// text alignment, default is `.left`
    public var textAlignment = NSTextAlignment.left
    
    // MARK: Image
    
    /// `imageLoader` method are required to implemention to avoid dependency 3rd library.
    ///
    /// when using `SDWebImage`, you can implemention like this.
    /// ```
    /// import SDWebImage
    ///
    /// PreviewImageLoader.shared.imageLoader = { (imageView, url) in
    ///     imageView?.sd_setImageWithURL(url)
    /// }
    /// ```
    ///
    public var imageLoader: ((UIImageView?, URL) -> Void)
    
    /// `imageQueue`
    ///
    /// load image async if `path`, `base64` is provider, or `url.isFileUrl`
    /// ```
    /// PreviewType.Image(image: _, named: _, path: path, base64: base64, url: url)
    /// ```
    ///
    private let imageQueue = OperationQueue()
    
    /// image content mode, default is .scaleAspectFit
    public var contentMode: UIView.ContentMode = .scaleAspectFit
    
    /// image cache
    private var imageCache = [Int : UIImage]()
    
    func imageWith(path: String, handler: @escaping (UIImage?) -> Void) {
        let key = path.hash
        if let result = imageCache[key] {
            handler(result)
            return
        }
        
        imageQueue.addOperation {
            guard let data = PreviewFile(path: path).contentsOfFile() else { return }
            DispatchQueue.main.async { [weak self] in
                let image = UIImage(data: data)
                self?.imageCache[key] = image
                handler(image)
            }
        }
    }
    
    func imageWith(base64: String, handler: @escaping (UIImage?) -> Void) {
        let key = base64.hash
        if let result = imageCache[key] {
            handler(result)
            return
        }
        
        imageQueue.addOperation { [weak self] in
            guard let data = base64.data(using: .utf8) else { return }
            DispatchQueue.main.async { [weak self] in
                let image = UIImage(data: data)
                self?.imageCache[key] = image
                handler(image)
            }
        }
    }
    
    // MARK: Video
//    var videoPlayer: AVPlayer? = nil
//    var videoPlayerLayer: AVPlayerLayer? = nil
//    private var currentPreviewVideo: URL? = nil
    
    /// replace current source with `source`
//    func videoPlayerWithSource(_ source: PreviewSource) {
//        let type = source.previewType()
//        switch type {
//        case let .Video(url: url):
//            if currentPreviewVideo == url { return }
//            if let _videoPlayer = videoPlayer {
//                _videoPlayer.pause()
//                let playerItem = AVPlayerItem(url: url)
//                _videoPlayer.replaceCurrentItem(with: playerItem)
//            }
//            else {
//                videoPlayer = AVPlayer(url: url)
//                videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
//            }
//            currentPreviewVideo = url
//            break
//        default:
//            assert(false)
//            return
//        }
//    }
}

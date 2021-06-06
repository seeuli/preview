//
//  ViewController.swift
//  demo
//
//  Created by liyf on 2021/5/17.
//

/**
 // MARK: Image
 http://e.hiphotos.baidu.com/image/pic/item/a1ec08fa513d2697e542494057fbb2fb4316d81e.jpg
 http://c.hiphotos.baidu.com/image/pic/item/30adcbef76094b36de8a2fe5a1cc7cd98d109d99.jpg
 http://h.hiphotos.baidu.com/image/pic/item/7c1ed21b0ef41bd5f2c2a9e953da81cb39db3d1d.jpg
 http://g.hiphotos.baidu.com/image/pic/item/55e736d12f2eb938d5277fd5d0628535e5dd6f4a.jpg
 http://e.hiphotos.baidu.com/image/pic/item/4e4a20a4462309f7e41f5cfe760e0cf3d6cad6ee.jpg
 http://b.hiphotos.baidu.com/image/pic/item/9d82d158ccbf6c81b94575cfb93eb13533fa40a2.jpg
 http://e.hiphotos.baidu.com/image/pic/item/4bed2e738bd4b31c1badd5a685d6277f9e2ff81e.jpg
 
 // MARK: Video
 http://vjs.zencdn.net/v/oceans.mp4
 http://vfx.mtime.cn/Video/2019/03/19/mp4/190319212559089721.mp4
 http://vfx.mtime.cn/Video/2019/03/18/mp4/190318214226685784.mp4
 
 */


import UIKit
import SDWebImage
import Preview

let screenWidth = UIScreen.main.bounds.width

struct PlainText : PreviewSource {
    let content: String
    
    public func previewType() -> PreviewType {
        return PreviewType.Text(content: content)
    }
}

struct BundleImage : PreviewSource {
    let name: String
    
    public func previewType() -> PreviewType {
        return PreviewType.Image(named: name)
    }
}

struct RemoteImage : PreviewSource {
    let url: URL
    
    public func previewType() -> PreviewType {
        return PreviewType.Image(url: url)
    }
}

struct RemoteVideo : PreviewSource {
    let url: URL
    
    func previewType() -> PreviewType {
        return .Video(url: url)
    }
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PreviewConfiguration.shared.imageLoader = { (imageView, url) in
            imageView?.sd_setImage(with: url, completed: nil)
        }
    }

    
    @IBAction func openPreviewController(_ sender: UIButton) {
        let sources : [PreviewSource] = [
            RemoteVideo(url: URL(string: "http://vjs.zencdn.net/v/oceans.mp4")!),
            PlainText(content: "文本预览"),
            RemoteImage(url: URL(string: "http://g.hiphotos.baidu.com/image/pic/item/6d81800a19d8bc3e770bd00d868ba61ea9d345f2.jpg")!),
            RemoteVideo(url: URL(string: "http://vfx.mtime.cn/Video/2019/03/19/mp4/190319212559089721.mp4")!),
            BundleImage(name: "wechat"),
            RemoteVideo(url: URL(string: "http://vfx.mtime.cn/Video/2019/03/18/mp4/190318214226685784.mp4")!),
            RemoteImage(url: URL(string: "http://c.hiphotos.baidu.com/image/pic/item/30adcbef76094b36de8a2fe5a1cc7cd98d109d99.jpg")!),
        ]
        
        PreviewConfiguration.shared.setPreview(sources, initial: 0)
        PreviewConfiguration.shared.infinite = false
        
        let preview = PreviewViewController()
        navigationController?.pushViewController(preview, animated: true)
//        preview.modalPresentationStyle = .popover
//        let nav = UINavigationController(rootViewController: preview)
//        present(nav, animated: true, completion: nil)
    }
}


//
//  PreviewImageViewController.swift
//  Preview
//
//  Created by seeuli on 2021/5/26.
//  Image Preview

import UIKit

class PreviewImageViewController: UIViewController {
    
    var _source: PreviewSource?
    var _index: Int = 0
    
    // Preview Image superview
    weak var containerView: UIScrollView?
    
    // Preview Image
    weak var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerView?.frame = view.bounds
        
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
        }
        let y = insets.top + 44.0
        let height = view.frame.height - y - insets.bottom - 44
        let frame = CGRect(x: 0, y: y, width: view.frame.width, height: height)
        imageView?.frame = frame
    }
    
    private func update() {
        assert(Thread.isMainThread)
        guard isViewLoaded else { return }
        guard _source != nil && imageView != nil else { return }
        
        switch source.previewType() {
        case let .Image(image: image, named: named, path: path, base64: base64, url: url):
            if let _image = image {
                imageView?.image = _image
            }
            else if let _named = named, _named.count > 0 {
                imageView?.image = UIImage(named: _named)
            }
            else if let _path = path?.trimmingCharacters(in: .whitespacesAndNewlines),
                    _path.count > 0 {
                PreviewConfiguration.shared.imageWith(path: _path) { [weak self] (image) in
                    self?.imageView?.image = image
                }
            }
            else if let _base64 = base64, _base64.count > 0 {
                PreviewConfiguration.shared.imageWith(base64: _base64) { [weak self] (image) in
                    self?.imageView?.image = image
                }
            }
            else if let _url = url, _url.absoluteString.count > 0 {
                if _url.isFileURL {
                    PreviewConfiguration.shared.imageWith(path: _url.path) { [weak self] (image) in
                        self?.imageView?.image = image
                    }
                }
                else if let _imageView = imageView {
                    PreviewConfiguration.shared.imageLoader(_imageView, _url)
                }
            }
            break
        default:
            assert(false)
        }
    }
    
    private func setupViews() {
        let containerView = UIScrollView()
        view.addSubview(containerView)
        self.containerView = containerView
        
        let imageView = UIImageView()
        imageView.contentMode = PreviewConfiguration.shared.contentMode
        containerView.addSubview(imageView)
        self.imageView = imageView
    }
}

extension PreviewImageViewController : Previewable {
    
    var source: PreviewSource {
        get { _source! }
        set {
            _source = newValue
            update()
        }
    }
    
    var index: Int {
        get { _index }
        set { _index = newValue }
    }
    
}

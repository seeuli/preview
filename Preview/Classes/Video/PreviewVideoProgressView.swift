//
//  PreviewVideoProgressView.swift
//  Preview
//
//  Created by liyf on 2021/5/23.
//

import UIKit

public class PreviewVideoProgressView: UIView {
    
    // MARK: style
    public var normalColor: UIColor = .gray {
        didSet {
            progressView.backgroundColor = normalColor
        }
    }
    
    public var progressTintColor: UIColor = .blue {
        didSet {
            progressTictView.backgroundColor = progressTintColor
        }
    }
    
    public var thumbColor: UIColor = .white {
        didSet {
            thumbView.backgroundColor = thumbColor
        }
    }
    
    public var thumbRadius: CGFloat = 3 {
        didSet {
            if thumbRadius == thumbView.layer.cornerRadius { return }
            thumbView.layer.cornerRadius = thumbRadius
            thumbView.layer.masksToBounds = true
        }
    }
    
    private var vertical: Bool = false
    
    // MARK: size
    public var progressBarHeight: CGFloat = 2.0
    public var thumbSize: CGSize = CGSize(width: 6, height: 6)
    public var padding: CGFloat = 0.0
    
    // MARK: progress
    public var progress: CGFloat { return _progress }
    private var _progress: CGFloat = 0.0
    public func setProgress(_ progress: CGFloat) {
        _progress = progress
        setNeedsLayout()
    }
    
    // MARK: progress handler
    public var progressBeginChange: ((CGFloat) -> Void)?
    public var progressDidChange: ((CGFloat) -> Void)?
    public var progressDidEndChange: ((CGFloat) -> Void)?
    
    // MARK: private
    private let progressView = UIView()
    private let progressTictView = UIView()
    private let thumbView = UIView()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        progressView.backgroundColor = normalColor
        addSubview(progressView)
        progressTictView.backgroundColor = progressTintColor
        addSubview(progressTictView)
        thumbView.backgroundColor = thumbColor
        thumbView.layer.cornerRadius = thumbRadius
        thumbView.layer.masksToBounds = true
        addSubview(thumbView)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didDragThumbView))
        thumbView.addGestureRecognizer(pan)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.isEmpty == false else { return }
        vertical = frame.height > frame.width + 1

        if vertical {
            let progressW = progressBarHeight
            let progressX = (frame.width - progressW) * 0.5
            let progressH = frame.height - padding * 2.0
            let progressY = padding
            progressView.frame = CGRect(x: progressX, y: progressY, width: progressW, height: progressH)
            
            let thumbH = thumbSize.height
            let thumbW = thumbSize.width
            let thumbX = (frame.width - thumbW) * 0.5
            let thumbY = frame.height - progressY - thumbH * 0.5 - progressH * _progress
            thumbView.frame = CGRect(x: thumbX, y: thumbY, width: thumbW, height: thumbH)

            let progressTictH = frame.height - thumbY - progressY
            progressTictView.frame = CGRect(x: progressX, y: thumbY, width: progressW, height: progressTictH)
        }
        else {
            let progressW = frame.width - padding * 2.0
            let progressX = padding
            let progressY = (frame.height - progressBarHeight) * 0.5
            let progressH = progressBarHeight
            progressView.frame = CGRect(x: progressX, y: progressY, width: progressW, height: progressH)

            let thumbX = progressX + progressW * _progress
            let thumbH = thumbSize.height
            let thumbY = (frame.height - thumbH) * 0.5
            let thumbW = thumbSize.width
            thumbView.frame = CGRect(x: thumbX, y: thumbY, width: thumbW, height: thumbH)

            let progressTictW = thumbX + thumbW * 0.5
            progressTictView.frame = CGRect(x: progressX, y: progressY, width: progressTictW, height: progressH)
        }
    }
    
    @objc private func didDragThumbView(_ gesture: UIPanGestureRecognizer) {
        guard gesture.isEnabled else { return }
        if gesture.state == .began {
            progressBeginChange?(_progress)
        }
        else if gesture.state == .changed {
            if vertical {
                let height = progressView.frame.height - padding * 2
                _progress = (height - gesture.location(in: self).y) / height
            }
            else {
                _progress = (gesture.location(in: self).x - padding) / progressView.frame.width
            }
            
            if _progress < 0 {
                _progress = 0
            }
            else if _progress > 1 {
                _progress = 1
            }
            progressDidChange?(_progress)
            setNeedsLayout()
        }
        else if gesture.state == .ended {
            progressDidEndChange?(_progress)
        }
    }
}

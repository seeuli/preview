//
//  PreviewVideoControlView.swift
//  Preview
//
//  Created by seeuli on 2021/5/31.
//

import UIKit
import SnapKit

class PreviewVideoControlView: UIView {
    
    private let playButton = UIButton(type: .custom)
    private let volumeButton = UIButton(type: .custom)
    private let currentTimeLabel = UILabel()
    private let progressView = PreviewVideoProgressView()
    private let timeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = timeLabel.frame.minX - currentTimeLabel.frame.maxX - 12
        let progressW = CGFloat.maximum(width, 90)
        progressView.snp.updateConstraints { maker in
            maker.width.equalTo(progressW)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let volumeMidX: CGFloat = 72
    
    var seekTo: ((Double) -> Void)? = nil
    var onPlay: ((Bool) -> Void)? = nil
    var onVolumeShow: ((Bool) -> Void)? = nil
    
    private var _seconds: Double = 0
    var seconds: Double {
        set {
            guard newValue.isNaN == false, _seconds != newValue else { return }
            _seconds = newValue
            let _value = Int(floor(newValue))
            timeLabel.text = _value.format_HHMMSS()
        }
        get {
            _seconds
        }
    }
    
    private var _currentTime: Double = 0
    var currentTime: Double {
        set {
            guard newValue.isNaN == false, _currentTime != newValue else { return }
            _currentTime = newValue
            let _value = Int(floor(newValue))
            currentTimeLabel.text = _value.format_HHMMSS()
            progressView.setProgress(CGFloat(newValue/_seconds))
        }
        get { _currentTime }
    }
    
    private var _isPlay = false
    var isPlay: Bool {
        set {
            guard _isPlay != newValue else { return }
            _isPlay = newValue
            playButton.isSelected = _isPlay
        }
        get { _isPlay }
    }
    
    @objc private func playAction(_ sender: UIButton) {
        isPlay = !_isPlay
        onPlay?(_isPlay)
    }
    
    @objc private func volumeAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        onVolumeShow?(sender.isSelected)
    }
    
    private func setupViews() {
        playButton.setImage(UIImage.load(named: "video_play"), for: .normal)
        playButton.setImage(UIImage.load(named: "video_pause"), for: .selected)
        playButton.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        addSubview(playButton)
        
        volumeButton.setImage(UIImage.load(named: "video_volume"), for: .normal)
        volumeButton.addTarget(self, action: #selector(volumeAction), for: .touchUpInside)
        addSubview(volumeButton)
        
        currentTimeLabel.text = "00:00"
        currentTimeLabel.font = UIFont.systemFont(ofSize: 14)
        currentTimeLabel.textColor = UIColor.white.withAlphaComponent(0.84)
        addSubview(currentTimeLabel)
        
        progressView.progressDidEndChange = { [weak self] (progress) in
            let _progress = Double(progress) * (self?._seconds ?? 0)
            let second = Double(Int(floor(_progress)))
            self?.seekTo?(second)
        }
        addSubview(progressView)

        timeLabel.text = "00:00"
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.84)
        addSubview(timeLabel)
    }
    
    private func setupConstraints() {
        playButton.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(12)
            maker.width.height.equalTo(36)
            maker.centerY.equalToSuperview()
        }
        
        volumeButton.snp.makeConstraints { maker in
            maker.left.equalTo(playButton.snp.right).offset(6)
            maker.width.height.equalTo(36)
            maker.centerY.equalToSuperview()
        }
        
        currentTimeLabel.snp.makeConstraints { maker in
            maker.left.equalTo(volumeButton.snp.right).offset(6)
            maker.top.height.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-12)
            maker.top.height.equalToSuperview()
        }
        
        progressView.snp.makeConstraints { maker in
            maker.left.equalTo(currentTimeLabel.snp.right).offset(6)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(16)
            maker.width.equalTo(90)
        }
    }
}

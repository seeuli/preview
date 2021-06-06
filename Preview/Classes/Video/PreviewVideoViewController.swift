//
//  PreviewVideoViewController.swift
//  Preview
//
//  Created by seeuli on 2021/5/26.
//  Video Preview

import UIKit
import AVFoundation

private let previewVideoStatus = "status"
private var previewVideoStatusContext = "previewVideoStatusContext"

private let previewVideoDuration = "currentItem.duration"
private var previewVideoDurationContext = "previewVideoDurationContext"


class PreviewVideoViewController: UIViewController {
    var _source: PreviewSource?
    var _index: Int = 0
    
    // Preview Video superview
    private weak var containerView: UIScrollView?
    
    // video play or progress control
    private weak var videoControlView: PreviewVideoControlView?
    // video volume control
    private var showVolumeView: Bool = false
    private weak var volumeView: PreviewVideoProgressView?
    
    // Preview Video
//   private  weak var videoPlayer: AVPlayer?
    private var videoPlayer: AVPlayer?
    private weak var playerLayer: AVPlayerLayer?
    private var videoTimeObserver: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerView?.frame = view.bounds
        let width = view.frame.width
        
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
        }
        let y = insets.top + 44.0
        let height = view.frame.height - y - insets.bottom - 44
        let frame = CGRect(x: 0, y: y, width: width, height: height)
        playerLayer?.frame = frame
        
        let controlH: CGFloat = 44
        let controlY = view.frame.height - controlH - insets.bottom
        videoControlView?.frame = CGRect(x: 0, y: controlY, width: width, height: controlH)
        
        let volumeH: CGFloat = showVolumeView ? 120 : 0
        let volumeW: CGFloat = 6
        let volumeX: CGFloat = videoControlView?.volumeMidX ?? 72 - volumeW * 0.5
        let volumeY = controlY - volumeH
        volumeView?.frame = CGRect(x: volumeX, y: volumeY, width: volumeW, height: volumeH)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _videoPlayer = videoPlayer {
            _videoPlayer.play()
        }
        else {
            DispatchQueue.main.async { [weak self] in
                self?.update()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayer?.pause()
    }
    
    deinit {
        videoPlayer?.removeObserver(self, forKeyPath: previewVideoStatus)
        videoPlayer?.removeObserver(self, forKeyPath: previewVideoDuration)
        if let _videoTimeObserver = videoTimeObserver {
            videoPlayer?.removeTimeObserver(_videoTimeObserver)
            videoTimeObserver = nil
        }
    }
    
    override var shouldAutorotate: Bool { true }
    
    private func update() {
        assert(Thread.isMainThread)
        guard isViewLoaded else { return }
        
//        PreviewConfiguration.shared.videoPlayerWithSource(source)
//        guard let videoPlayer = PreviewConfiguration.shared.videoPlayer,
//              let playerLayer = PreviewConfiguration.shared.videoPlayerLayer,
//              videoTimeObserver == nil
//            else { return }
        
        guard videoPlayer == nil,
              playerLayer == nil,
              videoTimeObserver == nil else {
            return
        }
        
        switch source.previewType() {
        case let .Video(url: url):
            let videoPlayer = AVPlayer(url: url)
            self.videoPlayer = videoPlayer
            
            let playerLayer = AVPlayerLayer(player: videoPlayer)
            containerView?.layer.addSublayer(playerLayer)
            self.playerLayer = playerLayer
            
            break
        default:
            assert(false)
        }
        
        // video player observer
        videoPlayer?.addObserver(self, forKeyPath: previewVideoStatus, options: .new, context: &previewVideoStatusContext)
        videoPlayer?.addObserver(self, forKeyPath: previewVideoDuration, options: .new, context: &previewVideoDurationContext)
        
        let interval = CMTime(value: 1, timescale: 1)
        videoTimeObserver = videoPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            let current = time.seconds
            let duration = self?.videoControlView?.seconds ?? 0
            debugPrint("PeriodicTime -- \(current), \(duration)")
            if Int(floor(current)) == Int(floor(duration)) {   // 播放完毕
                self?.videoControlView?.currentTime = 0
                self?.videoControlView?.isPlay = false
                self?.videoPlayer?.pause()
            }
            else {
                self?.videoControlView?.currentTime = current
            }
        }
    }
    
    private func setupViews() {
        let containerView = UIScrollView()
        view.addSubview(containerView)
        self.containerView = containerView
        
        let videoControlView = PreviewVideoControlView()
        videoControlView.seekTo = { [weak self] (second) in
            self?.videoPlayer?.pause()
            let time = CMTime(value: CMTimeValue(floor(second)), timescale: 1)
            self?.videoPlayer?.seek(to: time, completionHandler: { value in
                self?.videoPlayer?.play()
            })
        }
        videoControlView.onPlay = { [weak self] (play) in
            guard let videoPlayer = self?.videoPlayer, videoPlayer.status == .readyToPlay else { return }
            play ? videoPlayer.play() : videoPlayer.pause()
        }
        
        let volumeH : CGFloat = 120
        let volumeW : CGFloat = 6
        videoControlView.onVolumeShow = { [weak self] (show) in
            self?.showVolumeView = show
            let volumeY = self?.videoControlView?.frame.minY ?? (UIScreen.main.bounds.height - 44) - 6
            let volumeX = self?.volumeView?.frame.origin.x ?? 0
            if show {
                let volumeF = CGRect(x: volumeX, y: volumeY - volumeH, width: volumeW, height: volumeH)
                UIView.animate(withDuration: 0.25) {
                    self?.volumeView?.alpha = 1
                    self?.volumeView?.frame = volumeF
                }
            }
            else {
                let volumeF = CGRect(x: volumeX, y: volumeY, width: volumeW, height: 0)
                UIView.animate(withDuration: 0.25) {
                    self?.volumeView?.alpha = 0
                    self?.volumeView?.frame = volumeF
                }
            }
        }
        view.addSubview(videoControlView)
        self.videoControlView = videoControlView
        
        let volumeView = PreviewVideoProgressView()
        volumeView.progressDidChange = { [weak self] (progress) in
            self?.videoPlayer?.volume = Float(progress)
        }
        volumeView.alpha = 0
        view.addSubview(volumeView)
        self.volumeView = volumeView
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &previewVideoStatusContext {
            if change?[.newKey] as? Int ?? 0 == AVPlayer.Status.readyToPlay.rawValue {  // readyToPlay
                let after = DispatchTime(uptimeNanoseconds: UInt64(1.0 * Double(NSEC_PER_SEC)))
                DispatchQueue.main.asyncAfter(deadline: after) { [weak self] in
                    self?.videoPlayer?.play()
                    self?.videoControlView?.isPlay = true
                }
            }
            else {
                videoPlayer?.pause()
                videoControlView?.isPlay = false
            }
        }
        else if context == &previewVideoDurationContext {   // duration
            debugPrint("Video duration \((change?[.newKey] as? CMTime)?.seconds ?? 0)")
            if let time = change?[.newKey] as? CMTime, time.seconds.isNaN == false {
                videoControlView?.seconds = floor(time.seconds)
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}


extension PreviewVideoViewController : Previewable {
    
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

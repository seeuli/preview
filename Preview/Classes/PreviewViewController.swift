//
//  PreviewViewController.swift
//  Preview
//
//  Created by seeuli on 2021/5/17.
//

import UIKit

open class PreviewViewController: UIViewController {

    private var details = [Int : Previewable]()
    
    private weak var pageViewController : UIPageViewController?
    private var previousNavigationBarHidden = false
    
    private let configuration = PreviewConfiguration.shared
    
    var infinite: Bool { return configuration.infinite }
    
    var totalPages: Int { return configuration.sources.count }
    
    var currentIndex: Int { return configuration.previewIndex }
    
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        previousNavigationBarHidden = navigationController != nil && (navigationController?.navigationBar.isHidden ?? true)
//
//        if previousNavigationBarHidden == false {
//            navigationController?.setNavigationBarHidden(true, animated: animated)
//        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if previousNavigationBarHidden == false {
//            navigationController?.setNavigationBarHidden(false, animated: animated)
//        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        setupPageViewController()
    }
    
    deinit {
        pageViewController = nil
        details.removeAll()
        configuration.clear()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageViewController?.view.frame = view.bounds
    }
    
    func setupPageViewController() {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        let child = previewDetail(at: configuration.initialIndex)
        
        pageViewController.setViewControllers([child], direction: .forward, animated: false, completion: nil)
        pageViewController.dataSource = self
        addChild(pageViewController)
        pageViewController.view.backgroundColor = .clear
        
        view.addSubview(pageViewController.view)
        self.pageViewController = pageViewController
    }
    
    func previewDetail(at index: Int) -> Previewable {
        let vc = details[index]
        if let _vc = vc { return _vc }
        
        let source = configuration.sources[index]
        
        var child: Previewable
        switch source.previewType().description() {
        case .text:
            child = PreviewTextViewController()
        case .image:
            child = PreviewImageViewController()
        case .video:
            child = PreviewVideoViewController()
        }
        
        child.source = source
        child.index = index
        details[index] = child
        return child
    }
}

// MARK: Page Control
extension PreviewViewController : UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard viewController is Previewable else { assert(false) }
        let vc = viewController as! Previewable
        let index = vc.index
        configuration.previewIndexChange?(configuration.previewIndex, index)
        configuration.previewIndex = index
        
        if index == 0 { // First Page
            if infinite {
                return previewDetail(at: totalPages - 1)
            }
            return nil
        }
        return previewDetail(at: vc.index - 1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard viewController is Previewable else { assert(false) }
        let vc = viewController as! Previewable
        let index = vc.index
        configuration.previewIndexChange?(configuration.previewIndex, index)
        configuration.previewIndex = index
        
        if index == totalPages - 1 {   // Last Page
            if infinite {
                return previewDetail(at: 0)
            }
            return nil
        }
        return previewDetail(at: vc.index + 1)
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return configuration.sources.count
    }
    
}

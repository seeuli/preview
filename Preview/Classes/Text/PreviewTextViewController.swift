//
//  PreviewTextViewController.swift
//  Preview
//
//  Created by seeuli on 2021/5/25.
//  Text Preview

import UIKit

class PreviewTextViewController: UIViewController {
    
    var _source: PreviewSource?
    var _index: Int = 0
    
    weak var textView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        setupTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = view.safeAreaInsets
        }
        let y = insets.top + 44.0
        let height = view.frame.height - y - insets.bottom - 44
        
        let frame = CGRect(x: 0, y: y, width: view.frame.width, height: height)
        textView?.frame = frame
    }
    
    
    private func setupTextView() {
        let textView = UITextView(frame: .zero)
        textView.isEditable = false
        textView.textAlignment = PreviewConfiguration.shared.textAlignment
        textView.backgroundColor = .clear
        view.addSubview(textView)
        self.textView = textView
    }

    private func update() {
        assert(Thread.isMainThread)
        guard isViewLoaded else { return }
        guard _source != nil && textView != nil else { return }
        
        switch source.previewType() {
        case let .Text(content: content, attributedText: attributedText):
            if let _text = content {
                let attrs = PreviewConfiguration.shared.textAttributes
                textView?.attributedText = NSAttributedString(string: _text, attributes: attrs)
            }
            else if let _attributedText = attributedText {
                textView?.attributedText = _attributedText
            }
            else {
                assert(false)
            }
            break
        default:
            assert(false)
        }
    }
}

extension PreviewTextViewController : Previewable {
    
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



//
//  FLTextView.swift
//  MessageToolbar
//
//  Created by Gustavo Saume on 1/19/17.
//  Copyright © 2017 FieldLens. All rights reserved.
//

import UIKit

class CommentView: UITextView {

    // MARK: - Properties

    private let contentMargin: CGFloat = 8.0
    private let placeholderMargin: CGFloat = 12.0
    private let sendButtonVerticalMargin: CGFloat = 3.0

    var sendButtonIsHidden = true {
        didSet {
            sendButton.isHidden = sendButtonIsHidden
            setNeedsLayout()
            layoutIfNeeded()
        }
    }


    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            updatePlaceholderVisibility()
        }
    }
    
    // MARK: Components

    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        return button
    }()

    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 148.0/255.0, green: 154.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.isHidden = true
        return label
    }()


    // MARK: - Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    private func commonInit() {
        addSubview(sendButton)
        addSubview(placeholderLabel)

        font = UIFont.systemFont(ofSize: 15.0)
        textColor = UIColor(red: 68.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        textContainerInset = UIEdgeInsets(top: contentMargin, left: contentMargin, bottom: contentMargin, right: contentMargin)

        NotificationCenter.default.addObserver(self, selector: #selector(CommentView.didChangeText(notification:)), name: .UITextViewTextDidChange, object: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.frame = bounds.insetBy(dx: placeholderMargin, dy: placeholderMargin)
        sendButton.sizeToFit()

        let centerDelta = (frame.height - sendButton.bounds.height)
        sendButton.frame.origin.y = contentOffset.y + centerDelta - sendButtonVerticalMargin
        sendButton.frame.origin.x = sendButtonIsHidden ? bounds.width : bounds.width - sendButton.bounds.width - contentMargin
        textContainerInset.right = sendButton.bounds.width + contentMargin
    }

    // MARK: - Behavior

    private func updatePlaceholderVisibility() {
        let isPlaceholderTextEmpty = placeholder?.isEmpty ?? true
        placeholderLabel.isHidden = isPlaceholderTextEmpty || !text.isEmpty
    }

    // MARK: - Notifications

    @objc private func didChangeText(notification: NSNotification) {
        updatePlaceholderVisibility()
        sendButtonIsHidden = text.isEmpty
    }
}

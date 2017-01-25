//
//  FLTextView.swift
//  MessageToolbar
//
//  Created by Gustavo Saume on 1/19/17.
//  Copyright © 2017 FieldLens. All rights reserved.
//

import UIKit

@objc
protocol CommentViewDelegate: UITextViewDelegate {
    @objc optional func sendButtonTapped()
}

class CommentView: UITextView {

    // MARK: - Properties

    private let contentMargin: CGFloat = 8.0
    private let sendButtonVerticalMargin: CGFloat = 3.0

    var sendButtonIsHidden = true {
        didSet {
            sendButton.isHidden = sendButtonIsHidden
            setNeedsLayout()
        }
    }

    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            updatePlaceholderVisibility()
        }
    }

    var placeholderInset: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 12.0, bottom: 0.0, right: 0.0) {
        didSet {
            setNeedsLayout()
        }
    }

    // MARK: Components

    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(CommentView.sendButtonTapped), for: .touchUpInside)
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

        placeholderLabel.frame = UIEdgeInsetsInsetRect(bounds, placeholderInset)
        let actualSize = placeholderLabel.sizeThatFits(placeholderLabel.bounds.size)
        placeholderLabel.frame.size.height = actualSize.height

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

    // MARK: - Events

    @objc
    private func sendButtonTapped() {
        (delegate as? CommentViewDelegate)?.sendButtonTapped?()
    }

    // MARK: - Notifications

    @objc private func didChangeText(notification: NSNotification) {
        updatePlaceholderVisibility()
        sendButtonIsHidden = text.isEmpty
    }
}

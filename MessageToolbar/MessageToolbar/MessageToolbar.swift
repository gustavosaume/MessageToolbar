//
//  MessageToolbar.swift
//  MessageToolbar
//
//  Created by Gustavo Saume on 1/18/17.
//  Copyright © 2017 FieldLens. All rights reserved.
//

import UIKit

protocol MessageToolbarDelegate: class {
    func textDidChange()
    func sendButtonPressed()
}

extension MessageToolbarDelegate {
    func textDidChange() {}
    func sendButtonPressed() {}
}

class MessageToolbar: UIView {

    // MARK: - Properties

    weak var delegate: MessageToolbarDelegate?

    var minHeight: CGFloat = 44.0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    var maxHeight: CGFloat = 200.0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    var appropriateHeight: CGFloat {
        return max(min(intrinsicContentSize.height, maxHeight), minHeight)
    }

    var borderColor = UIColor(red: 197.0/255.0, green: 203.0/255.0, blue: 209.0/255.0, alpha: 1.0)

    var selectedBorderColor = UIColor(red: 0.0, green: 142.0/255.0, blue: 208.0/255.0, alpha: 1.0)


    var placeholder: String? {
        didSet {
            commentField.placeholder = placeholder
        }
    }

    // MARK: Components

    let topLine: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: -1.0, width: 0.0, height: 1.0))
        view.autoresizingMask = [.flexibleWidth]
        return view
    }()

    let commentField: CommentView = {
        let textView = CommentView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 6.0
        textView.layer.borderWidth = 1.0
        return textView
    }()

    let leftButtonsToggle: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(">", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(MessageToolbar.leftButtonsToggleTapped), for: .touchUpInside)
        return button
    }()

    var leftButtons = [UIButton]() {
        didSet {
            guard !commentField.isFirstResponder else { return }
            internalLeftButtons = leftButtons
        }
    }

    fileprivate var internalLeftButtons = [UIButton]() {
        didSet {
            oldValue.forEach({ $0.isHidden = true })
            oldValue.forEach({ leftButtonsContainer.removeArrangedSubview($0) })
            internalLeftButtons.forEach({ leftButtonsContainer.addArrangedSubview($0) })
            internalLeftButtons.forEach({ $0.isHidden = false })

            let fullWidth = internalLeftButtons.map({ $0.bounds.width }).reduce(0, +)
            leftButtonContainerWidthConstraint.constant = fullWidth

            layoutIfNeeded()
        }
    }

    private let leftButtonsContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.backgroundColor = .white
        return stackView
    }()

    private var leftButtonContainerWidthConstraint: NSLayoutConstraint!

    private var initialHeight: CGFloat = 44.0

    // MARK: Computed properties

    var hasLeftButtons: Bool {
        return leftButtons.count > 0
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        commentField.delegate = self
        commentField.layer.borderColor = borderColor.cgColor
        topLine.backgroundColor = borderColor

        addSubview(topLine)
        addSubview(commentField)
        addSubview(leftButtonsContainer)

        let verticalMargin: CGFloat = 4.0
        initialHeight = bounds.height
        let contentHeight = initialHeight - (verticalMargin * 2.0)
        let metrics = ["verticalMargin": verticalMargin, "buttonsHeight": contentHeight]
        let views: [String: UIView] = ["commentField": commentField, "buttonContainer": leftButtonsContainer]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[buttonContainer]-[commentField]-|", options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-verticalMargin-[commentField]-verticalMargin-|", options: [], metrics: metrics, views: views))

        leftButtonContainerWidthConstraint = NSLayoutConstraint(item: leftButtonsContainer, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        addConstraint(leftButtonContainerWidthConstraint)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[buttonContainer(==buttonsHeight)]-verticalMargin-|", options: [], metrics: metrics, views: views))
    }

    // MARK: - Layout

    override var intrinsicContentSize: CGSize {
        if commentField.isFirstResponder {
            let textSize = commentField.sizeThatFits(CGSize(width: commentField.bounds.width, height: maxHeight))
            let height = max(min(textSize.height, maxHeight), minHeight)
            return CGSize(width: UIViewNoIntrinsicMetric, height: height)
        } else {
            return CGSize(width: UIViewNoIntrinsicMetric, height: initialHeight)
        }
    }

    // MARK: - Events

    @objc private func leftButtonsToggleTapped() {
        becomeFirstResponder()

    }

    // MARK: - UIResponder

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var canResignFirstResponder: Bool {
        return true
    }
}

// MARK: - UIKeyInput

// UIKitInpuy allows us to become first responders while keeping the keyboard up
extension MessageToolbar: UIKeyInput {

    func insertText(_ text: String) {
        commentField.text.append(text)
    }

    func deleteBackward() {
        commentField.deleteBackward()
    }

    var hasText: Bool {
        return commentField.hasText
    }
}

// MARK: - UITextViewDelegate

extension MessageToolbar: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        invalidateIntrinsicContentSize()
        textView.layer.borderColor = selectedBorderColor.cgColor

        if hasLeftButtons {
            internalLeftButtons = [leftButtonsToggle]
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        invalidateIntrinsicContentSize()
        textView.layer.borderColor = borderColor.cgColor
        internalLeftButtons = leftButtons
    }

    func textViewDidChange(_ textView: UITextView) {
        invalidateIntrinsicContentSize()
        delegate?.textDidChange()
    }
}

//
//  MessageToolbar.swift
//  MessageToolbar
//
//  Created by Gustavo Saume on 1/18/17.
//  Copyright © 2017 FieldLens. All rights reserved.
//

import UIKit

@objc protocol MessageToolbarDelegate: class {
    @objc optional func textDidChange()
    @objc optional func sendButtonTapped()
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
        return intrinsicContentSize.height.clamped(to: minHeight...maxHeight)
    }

    var borderColor = UIColor(red: 197.0/255.0, green: 203.0/255.0, blue: 209.0/255.0, alpha: 1.0)

    var selectedBorderColor = UIColor(red: 0.0, green: 142.0/255.0, blue: 208.0/255.0, alpha: 1.0)

    var placeholder: String? {
        get {
            return commentField.placeholder
        }
        set {
            commentField.placeholder = newValue
        }
    }

    // MARK: Components

    let topLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
            let maxHeight = internalLeftButtons.map({ $0.bounds.height }).max() ?? 0.0
            leftButtonsContainer.frame.size = CGSize(width: fullWidth, height: maxHeight)

            layoutIfNeeded()
        }
    }

    private let leftButtonsContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()

    private var initialHeight: CGFloat = 44.0

    private var shouldBecomeFirstResponder = false

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
        backgroundColor = .white
        commentField.delegate = self
        commentField.layer.borderColor = borderColor.cgColor
        topLine.backgroundColor = borderColor
        initialHeight = bounds.height

        addSubview(topLine)
        addSubview(commentField)
        addSubview(leftButtonsContainer)
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

    override func layoutSubviews() {
        super.layoutSubviews()

        topLine.frame = CGRect(x: 0.0, y: -1.0, width: bounds.width, height: 1.0)

        let horizontalMargin: CGFloat = 8.0
        let verticalMargin: CGFloat = 4.0
        if hasLeftButtons {
            let vGap = (initialHeight - leftButtonsContainer.bounds.height) / 2.0
            let y = bounds.height - leftButtonsContainer.bounds.height - vGap
            leftButtonsContainer.frame.origin = CGPoint(x: horizontalMargin, y: y)
        }

        let inputX = leftButtonsContainer.frame.maxX + horizontalMargin
        let inputWidth = bounds.width - inputX - horizontalMargin
        let inputHeight = bounds.height - (verticalMargin * 2.0)
        commentField.frame = CGRect(x: inputX, y: verticalMargin, width: inputWidth, height: inputHeight)
    }

    // MARK: - Events
    @objc private func leftButtonsToggleTapped() {
        // we only need to become first responder if the toggle button is tapped
        // other than that we should avoid it because introduce weird behavior
        // when scrolling the tableview
        shouldBecomeFirstResponder = true
        becomeFirstResponder()
        shouldBecomeFirstResponder = false
    }

    // MARK: - UIResponder

    override var canBecomeFirstResponder: Bool {
        return shouldBecomeFirstResponder
    }
}

// MARK: - UIKeyInput

// UIKeyInput allows us to become first responders while keeping the keyboard up
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

extension MessageToolbar: CommentViewDelegate {
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
        delegate?.textDidChange?()
    }

    func sendButtonTapped() {
        delegate?.sendButtonTapped?()
    }
}

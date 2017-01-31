//
//  ViewController.swift
//  MessageToolbar
//
//  Created by Gustavo Saume on 1/18/17.
//  Copyright © 2017 FieldLens. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    fileprivate static let cellID = "cellID"

    // MARK: - Variables

    fileprivate lazy var table: UITableView = {
        $0.dataSource = self
        $0.delegate = self
        $0.frame = self.view.bounds
        $0.register(UITableViewCell.self, forCellReuseIdentifier: ViewController.cellID)
        $0.keyboardDismissMode = .onDrag
        return $0
    }(UITableView())

    fileprivate lazy var toolbar: MessageToolbar = {
        let toolbar = MessageToolbar(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 44.0))
        toolbar.placeholder = "w00t w00t"

        toolbar.register(mediaCellClass: BasicCell.self)
        toolbar.delegate = self
        toolbar.datasource = self
        return toolbar
    }()

    override var inputAccessoryView: UIView? {
        let shouldHideToolbar = presentedViewController == nil || presentedViewController?.isBeingDismissed ?? false
        return shouldHideToolbar ? toolbar : nil
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    //MARK: - Media

    let media = [Mediadata(title: "A"), Mediadata(title: "B"), Mediadata(title: "C"), Mediadata(title: "D"),]

    //MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        becomeFirstResponder()

        let btn1 = UIButton(type: .system)
        btn1.backgroundColor = .cyan
        btn1.setTitle("A", for: .normal)
        btn1.sizeToFit()

        let btn2 = UIButton(type: .system)
        btn2.backgroundColor = .yellow
        btn2.setTitle("B", for: .normal)
        btn2.sizeToFit()

        let btn3 = UIButton(type: .system)
        btn3.backgroundColor = .magenta
        btn3.setTitle("C", for: .normal)
        btn3.sizeToFit()

        toolbar.leftButtons = [btn1, btn2, btn3]
        toolbar.delegate = self

        view.addSubview(table)
    }
}

extension ViewController: MessageToolbarDataSource {
    func numberOfMedia(in messageToolbar: MessageToolbar) -> Int {
        return media.count
    }

    func messageToolbar(_ messageToolbar: MessageToolbar, cellForMediaAt indexPath: IndexPath) -> MessageMediaCell {
        guard let cell = messageToolbar.dequeueReusableMediaCell(for: indexPath) as? BasicCell else {
            fatalError("incorrect cell")
        }

        let mediaData = media[indexPath.row]
        cell.title.text = mediaData.title
        return cell
    }
}

extension ViewController: MessageToolbarDelegate {
    func sendButtonPressed() {
        print("pressed")
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1_000
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.cellID, for: indexPath)
        cell.textLabel?.text = String(indexPath.row)
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resignFirstResponder()
        _ = toolbar.resignFirstResponder()
        view.endEditing(true)

        let alert = UIAlertController(title: "Selected", message: String(indexPath.row), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

struct Mediadata {
    let title: String
}

class BasicCell: MessageMediaCell {
    let title = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(title)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .cyan
        title.backgroundColor = .cyan
        title.textAlignment = .center
        addSubview(title)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        title.frame.size = bounds.size
    }
}

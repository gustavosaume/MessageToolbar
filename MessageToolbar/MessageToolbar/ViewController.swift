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
        return toolbar
    }()

    override var inputAccessoryView: UIView? {
        let shouldHideToolbar = presentedViewController == nil || presentedViewController?.isBeingDismissed ?? false
        return shouldHideToolbar ? toolbar : nil
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

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
        toolbar.resignFirstResponder()
        view.endEditing(true)

        let alert = UIAlertController(title: "Selected", message: String(indexPath.row), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

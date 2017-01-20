//
//  ViewController.swift
//  MessageToolbar
//
//  Created by Gustavo Saume on 1/18/17.
//  Copyright © 2017 FieldLens. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Variables

    fileprivate lazy var toolbar: MessageToolbar = {
        let toolbar = MessageToolbar(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 44.0))
        toolbar.placeholder = "w00t w00t"
        return toolbar
    }()

    override var inputAccessoryView: UIView? {
        return toolbar
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

//        view.addSubview(toolbar)
//        toolbar.frame.size.width = UIScreen.main.bounds.width
//        toolbar.frame = toolbar.frame.offsetBy(dx: 0.0, dy: UIScreen.main.bounds.height - 44.0)
    }
}

//
//  SendBoard.swift
//  wordgames MessagesExtension
//
//  Created by Joshua Ochalek on 12/31/23.
//

import Foundation
import UIKit
import SnapKit
import Messages

class SendBoard: UIViewController {
    
    let sendButton = WordText()
    var tapRecognizer: UITapGestureRecognizer!
    var delegate: MessagesViewControllerDelegate!
    
    init(delegate: MessagesViewControllerDelegate) {
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButton()
    }
    
    func setupButton() {
        sendButton.text = "Send"
        sendButton.font = UIFont(name: "Rubik", size: 24)
        sendButton.textColor = .whiteTheme
        sendButton.backgroundColor = .darkTheme
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        
        sendButton.addGestureRecognizer(tapRecognizer)
        sendButton.isUserInteractionEnabled = true
        
        view.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        sendButton.snp.makeConstraints { im in
            im.centerX.centerY.equalToSuperview()
        }
    }
    
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate.sendBoard()
    }
    
    static func generateLetter() -> String {
        // Source: https://en.wikipedia.org/wiki/Letter_frequency
        // Note that the total percentage does not add up to 100 on the site
        let num = Double.random(in: 0..<100)
        if num < 7.8 {
            return "a"
        } else if num < 9.8 {
            return "b"
        } else if num < 13.8 {
            return "c"
        } else if num < 17.6 {
            return "d"
        } else if num < 28.6 {
            return "e"
        } else if num < 30 {
            return "f"
        } else if num < 33 {
            return "g"
        } else if num < 35.3 {
            return "h"
        } else if num < 43.9 {
            return "i"
        } else if num < 44.11 {
            return "j"
        } else if num < 45.08 {
            return "k"
        } else if num < 50.38 {
            return "l"
        } else if num < 53.08 {
            return "m"
        } else if num < 60.28 {
            return "n"
        } else if num < 66.38 {
            return "o"
        } else if num < 69.18 {
            return "p"
        } else if num < 69.37 {
            return "q"
        } else if num < 76.67 {
            return "r"
        } else if num < 85.37 {
            return "s"
        } else if num < 92.07 {
            return "t"
        } else if num < 95.37 {
            return "u"
        } else if num < 96.37 {
            return "v"
        } else if num < 97.28 {
            return "w"
        } else if num < 97.55 {
            return "x"
        } else if num < 99.15 {
            return "y"
        } else {
            return "z"
        }
    }
}

//
//  MessagesViewController.swift
//  wordgames MessagesExtension
//
//  Created by Joshua Ochalek on 12/25/23.
//

import UIKit
import Messages

// TODO: allow dynamic sizing, set max game size
// TODO: send message on game end with proper URL
// TODO: modify layouts on received based on status of game

class MessagesViewController: MSMessagesAppViewController {
    
    private var board: Board?
    private var boardId: String?
    private var endGame: EndGame?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dismisses the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
        
        Board.clear()
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
        
        let currentUser = conversation.localParticipantIdentifier.uuidString
        
        // Ensure it is from a remote device and has a query to parse
        if message.senderParticipantIdentifier.uuidString == currentUser || message.url?.query() == nil {
            return
        }
        
        let query = parseQuery(message.url!.query()!)
        
        let layout = MSMessageTemplateLayout()
        layout.image = UIImage(named: "question-board")
        layout.caption = "Word Hunt"
        
        if query["initUserWords"] != nil && query["otherUserWords"] != nil {
            if currentUser != query["initUserId"]! && currentUser != query["otherUserId"] {
                // TODO: user is not in game (already 2 players that played)
            } else if currentUser == query["initUserId"] {
                var youScore = 0
                var oppScore = 0
                
                let wordsFound = query["initUserWords"]!.components(separatedBy: "-")
                let oppWordsFound = query["otherUserWords"]!.components(separatedBy: "-")
                
                wordsFound.forEach { word in
                    youScore += Board.scoring[word.count] ?? 3000
                }
                oppWordsFound.forEach { word in
                    oppScore += Board.scoring[word.count] ?? 3000
                }
                if youScore > oppScore {
                    layout.subcaption = "You won!"
                } else if youScore < oppScore {
                    layout.subcaption = "You lost!"
                } else {
                    layout.subcaption = "Draw!"
                }
            } else {
                var youScore = 0
                var oppScore = 0
                
                let wordsFound = query["otherUserWords"]!.components(separatedBy: "-")
                let oppWordsFound = query["initUserWords"]!.components(separatedBy: "-")
                
                wordsFound.forEach { word in
                    youScore += Board.scoring[word.count] ?? 3000
                }
                oppWordsFound.forEach { word in
                    oppScore += Board.scoring[word.count] ?? 3000
                }
                if youScore > oppScore {
                    layout.subcaption = "You won!"
                } else if youScore < oppScore {
                    layout.subcaption = "You lost!"
                } else {
                    layout.subcaption = "Draw!"
                }
            }
            
            message.layout = layout
        } else if (query["initUserId"] == currentUser && query["initUserWords"] == nil) || (query["otherUserId"] == nil && query["initUserWords"] != nil) {
            layout.subcaption = "Your move"
            message.layout = layout
        }
        // This means that the message is the blank message to start a game.
        
        // Update game end screen if necessary.
        if children.count > 0 && endGame != nil && children.contains(endGame!) && endGame!.gameId == query["gameId"] {
            
        }
        // Update board variables if necessary
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
        super.didTransition(to: presentationStyle)
               
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
        var controller: UIViewController
        if self.activeConversation?.selectedMessage?.url?.query() != nil && presentationStyle == .expanded {
            let query = parseQuery(self.activeConversation!.selectedMessage!.url!.query()!)
            if board == nil && boardId == nil {
                board = Board(gameId: query["gameId"]!, board: query["board"]!, delegate: self)
                boardId = query["gameId"]!
            }
            controller = board!
        } else {
            controller = SendBoard(delegate: self)
        }
        
        // Test code just for viewing EndGame VC
        if presentationStyle == .expanded {
            controller = EndGame(gameId: "test", wordsFound: ["test", "hahaha", "strollers", "stroller", "dummy", "solution", "against", "tanning", "lifestyle", "watch", "air", "cot", "cod"], oppWordsFound: ["test", "hahaha", "strollers", "stroller", "dummy", "solution", "against", "tanning", "lifestyle", "watch", "air", "cot", "cod"])
        }
        
        controller.willMove(toParent: self)
        addChild(controller)
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
                
        controller.view.snp.makeConstraints { im in
            im.top.bottom.leading.trailing.equalToSuperview()
        }
        
        controller.didMove(toParent: self)
    }
    
    func parseQuery(_ query: String) -> [String: String] {
        var dict: [String: String] = [:]
        for pair in query.components(separatedBy: "&") {
            let innerList = pair.components(separatedBy: "=")
            dict[innerList[0]] = innerList[1]
        }
        return dict
    }
}

protocol MessagesViewControllerDelegate {
    func sendBoard()
    func endGame(gameId: String, wordsFound: [String], oppWordsFound: [String]?, oppUserId: String?)
}

extension MessagesViewController: MessagesViewControllerDelegate {
    func endGame(gameId: String, wordsFound: [String], oppWordsFound: [String]?, oppUserId: String?) {
        let newController = EndGame(gameId: gameId, wordsFound: wordsFound, oppWordsFound: oppWordsFound)
        newController.view.transform = CGAffineTransform(translationX: view.frame.width, y: 0)
        newController.willMove(toParent: self)
        addChild(newController)
        newController.view.frame = view.bounds
        newController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newController.view)
                
        newController.view.snp.makeConstraints { im in
            im.top.bottom.leading.trailing.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            newController.view.transform = .identity
        }
        newController.didMove(toParent: self)
        
        for child in children {
            if child != newController {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
        }
        
        let query = parseQuery(self.activeConversation!.selectedMessage!.url!.query()!)
        let message = MSMessage(session: self.activeConversation!.selectedMessage!.session!)
        let components = NSURLComponents()
        
        components.queryItems = [
            URLQueryItem(name: "board", value: query["board"]!),
            URLQueryItem(name: "gameId", value: gameId),
            URLQueryItem(name: "initUserId", value: query["initUserId"])
        ]
        
        let currentUserId = activeConversation!.localParticipantIdentifier.uuidString
        if currentUserId == query["initUserId"] {
            components.queryItems!.append(URLQueryItem(name: "initUserWords", value: wordsFound.joined(separator: "-")))
            if oppWordsFound != nil {
                components.queryItems!.append(URLQueryItem(name: "otherUserWords", value: oppWordsFound!.joined(separator: "-")))
                components.queryItems!.append(URLQueryItem(name: "otherUserId", value: oppUserId!))
            }
        } else if query["otherUserId"] == nil {
            components.queryItems!.append(URLQueryItem(name: "otherUserWords", value: wordsFound.joined(separator: "-")))
            components.queryItems!.append(URLQueryItem(name: "otherUserId", value: currentUserId))
            if oppWordsFound != nil {
                components.queryItems!.append(URLQueryItem(name: "initUserWords", value: oppWordsFound!.joined(separator: "-")))
            }
        } else {
            // TODO: when there are > 2 players
        }
        
        message.url = components.url!
        
        let layout = MSMessageTemplateLayout()
        layout.image = UIImage(named: "question-board")
        layout.caption = "Word Hunt"
        if oppWordsFound == nil {
            layout.subcaption = "Waiting for opponent"
        } else {
            var youScore = 0
            var oppScore = 0
            wordsFound.forEach { word in
                youScore += Board.scoring[word.count] ?? 3000
            }
            oppWordsFound!.forEach { word in
                oppScore += Board.scoring[word.count] ?? 3000
            }
            if youScore > oppScore {
                layout.subcaption = "You won!"
            } else if youScore < oppScore {
                layout.subcaption = "You lost!"
            } else {
                layout.subcaption = "Draw!"
            }
        }
        
        message.layout = layout
        
        self.activeConversation!.send(message)
    }
    
    func sendBoard() {
        let message = MSMessage(session: MSSession())
        let components = NSURLComponents()
        
        var board = ""
        
        for _ in 0...15 {
            board += SendBoard.generateLetter()
        }
        
        components.queryItems = [
            URLQueryItem(name: "board", value: board),
            URLQueryItem(name: "gameId", value: UUID().uuidString),
            URLQueryItem(name: "initUserId", value: activeConversation!.localParticipantIdentifier.uuidString)
        ]
        message.url = components.url!
        
        let layout = MSMessageTemplateLayout()
        layout.image = UIImage(named: "question-board")
        layout.caption = "Word Hunt"
        layout.subcaption = "Let's play Word Hunt!"
        
        message.layout = layout
        
        self.activeConversation!.insert(message)
    }
}

//
//  Board.swift
//  wordgames MessagesExtension
//
//  Created by Joshua Ochalek on 12/31/23.
//

import Foundation
import UIKit
import SnapKit
import UICountingLabel

class Board: UIViewController {
    static let size: Int = 4
    static let currentWordLabel = WordText()
    
    static var board: [[LetterImage]] = []
    private var canvas: Canvas!
    static var rect: CGRect!
    private var panRecognizer: UIPanGestureRecognizer!
    static var lineLayer: CAShapeLayer!
    static var draggedTiles: [CGPoint] = []
    static var path: UIBezierPath!
    private var words: [String] = []
    static var foundWords: [String] = []
    static var selectedWord: String = ""
    private var border = UIView()
    
    static var score: Int = 0
    static let scoreLabel = UICountingLabel()
    static let scoreText = UILabel()
    static var wordCount: Int = 0
    static let wordCountLabel = UILabel()
    static let wordCountText = UILabel()
    
    private let timerLabel = UILabel()
    private var timeRemaining: TimeInterval = 80
    static var timer: Timer?
    
    private var oppWordsFound: [String]?
    private var gameId: String
    private var boardString: String
    private var delegate: MessagesViewControllerDelegate!
    
    static let scoring: [Int: Int] = [
        3: 100,
        4: 400,
        5: 800,
        6: 1400,
        7: 1800,
        8: 2200,
        9: 2600
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBorder()
        setupBoard()
        setupCanvas()
        setupDict()
        setupWordText()
        setupTop()
    }
    
    init(gameId: String, board: String, delegate: MessagesViewControllerDelegate, oppWordsFound: [String]? = nil) {
        self.gameId = gameId
        self.oppWordsFound = oppWordsFound
        boardString = board
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func clear() {
        timer?.invalidate()
        board = []
        lineLayer = nil
        foundWords = []
        selectedWord = ""
        score = 0
        wordCount = 0
        scoreLabel.text = "0000"
    }
    
    func setupTop() {
        var textColor: UIColor
        
        if traitCollection.userInterfaceStyle == .light {
            textColor = UIColor.darkTheme
        } else {
            textColor = UIColor.whiteTheme
        }
        
        Board.scoreText.text = "Score"
        Board.scoreText.font = UIFont(name: "Rubik", size: 24)
        Board.scoreText.textColor = textColor
        
        view.addSubview(Board.scoreText)
        Board.scoreText.translatesAutoresizingMaskIntoConstraints = false
        
        Board.scoreText.snp.makeConstraints { im in
            im.centerX.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(view.frame.width / 6)
            im.top.equalToSuperview().offset(view.frame.width / 12)
        }
        
        Board.wordCountText.text = "Words"
        Board.wordCountText.font = UIFont(name: "Rubik", size: 24)
        Board.wordCountText.textColor = textColor
        
        view.addSubview(Board.wordCountText)
        Board.wordCountText.translatesAutoresizingMaskIntoConstraints = false
        
        Board.wordCountText.snp.makeConstraints { im in
            im.centerX.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(view.frame.width / 6 * 5)
            im.top.equalToSuperview().offset(view.frame.width / 12)
        }
        
        Board.scoreLabel.text = String(Board.score)
        Board.scoreLabel.font = UIFont(name: "Rubik", size: 28)
        Board.scoreLabel.textColor = textColor
        Board.scoreLabel.animationDuration = 0.6
        Board.scoreLabel.format = "%04d"
        
        view.addSubview(Board.scoreLabel)
        Board.scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        Board.scoreLabel.snp.makeConstraints { im in
            im.centerX.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(view.frame.width / 6)
            im.top.equalToSuperview().offset(view.frame.width / 12 + 24)
        }
        
        Board.wordCountLabel.text = String(Board.wordCount)
        Board.wordCountLabel.font = UIFont(name: "Rubik", size: 28)
        Board.wordCountLabel.textColor = textColor
        
        view.addSubview(Board.wordCountLabel)
        Board.wordCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        Board.wordCountLabel.snp.makeConstraints { im in
            im.centerX.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(view.frame.width / 6 * 5)
            im.top.equalToSuperview().offset(view.frame.width / 12 + 24)
        }
    
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute]
        formatter.zeroFormattingBehavior = .pad
        
        timerLabel.text = formatter.string(from: timeRemaining)!
        timerLabel.textColor = textColor
        timerLabel.font = UIFont(name: "Rubik", size: 28)
        
        view.addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timerLabel.snp.makeConstraints { im in
            im.centerX.equalToSuperview()
            im.top.equalToSuperview().offset(view.frame.width / 12 + 12)
        }
        
        Board.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.timeRemaining -= 1
            self.timerLabel.text = formatter.string(from: self.timeRemaining)!
            if self.timeRemaining < 0 {
                timer.invalidate()
                // TODO: end game
            }
        }
        
        let line = CAShapeLayer()
        if traitCollection.userInterfaceStyle == .light {
            line.strokeColor = UIColor.darkTheme.cgColor.copy(alpha: 0.5)
        } else {
            line.strokeColor = UIColor.whiteTheme.cgColor.copy(alpha: 0.5)
        }
        line.lineCap = .round
        line.lineJoin = .round
        line.fillColor = UIColor.clear.cgColor
        line.lineWidth = 4
        view.layer.addSublayer(line)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: view.frame.width / 3, y: view.frame.width / 12))
        path.addLine(to: CGPoint(x: view.frame.width / 3, y: view.frame.width / 12 + 54))
        line.path = path.cgPath
        
        path.move(to: CGPoint(x: view.frame.width / 3 * 2, y: view.frame.width / 12))
        path.addLine(to: CGPoint(x: view.frame.width / 3 * 2, y: view.frame.width / 12 + 54))
        line.path = path.cgPath
    }
    
    func setupBorder() {
        let xOffset: CGFloat = CGFloat((6 * (Board.size + 1)))
        let halfSize: CGFloat = CGFloat(Board.size / 2)
        let defaultOffset: CGFloat = (view.frame.width - xOffset) / halfSize * -1
        let multiplier: CGFloat = (view.frame.width - xOffset) / CGFloat(Board.size)
        border.backgroundColor = .whiteTheme
        border.layer.cornerRadius = 12
        border.layer.masksToBounds = true
        border.layer.borderWidth = 5
        border.layer.borderColor = UIColor.whiteTheme.cgColor
        
        view.addSubview(border)
        border.translatesAutoresizingMaskIntoConstraints = false
        
        border.snp.makeConstraints { im in
            im.top.equalTo(view.safeAreaLayoutGuide.snp.centerY).offset(defaultOffset - 7.5)
            im.centerX.equalToSuperview()
            im.size.equalTo(multiplier * CGFloat(Board.size) + 10)
        }
    }
    
    func setupWordText() {
        Board.currentWordLabel.text = ""
        Board.currentWordLabel.textColor = UIColor.white
        Board.currentWordLabel.font = UIFont(name: "Rubik", size: 20)
        Board.currentWordLabel.backgroundColor = UIColor.darkTheme
        Board.currentWordLabel.layer.cornerRadius = 4
        Board.currentWordLabel.layer.masksToBounds = true
        Board.currentWordLabel.isUserInteractionEnabled = false
        Board.currentWordLabel.alpha = 0
        
        view.addSubview(Board.currentWordLabel)
        Board.currentWordLabel.translatesAutoresizingMaskIntoConstraints = false
        
        Board.currentWordLabel.snp.makeConstraints { im in
            im.centerX.equalTo(view.snp.centerX)
            im.bottom.equalTo(canvas.snp.top).offset(view.frame.width / CGFloat(Board.size * -2))
        }
    }
    
    private func setupDict() {
        if let path = Bundle.main.path(forResource: "words_alpha", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path)
                data.enumerateLines { line, _ in
                    if (line.count > 2) {
                        self.words.append(line)
                    }
                }
            } catch {
                print("Error reading words: \(error)")
            }
        }
    }
    
    private func setupBoard() {
        for i in 0...(Board.size - 1) {
            Board.board.append([])
            for j in 0...(Board.size - 1) {
                let letter = boardString[i * Board.size + j]
                Board.board[i].append(LetterImage(image: UIImageView(), letter: letter))
                Board.board[i][j].image.image = UIImage(named: letter)
                Board.board[i][j].image.layer.cornerRadius = 12
                Board.board[i][j].image.layer.masksToBounds = true
                
                view.addSubview(Board.board[i][j].image)
                Board.board[i][j].image.translatesAutoresizingMaskIntoConstraints = false
                let xOffset: CGFloat = CGFloat((6 * (Board.size + 1)))
                let halfSize: CGFloat = CGFloat(Board.size / 2)
                let defaultOffset: CGFloat = (view.frame.width - xOffset) / halfSize * -1
                let multiplier: CGFloat = (view.frame.width - xOffset) / CGFloat(Board.size)
                let topOffset: CGFloat = defaultOffset + multiplier * CGFloat(i)
                let leadingOffset: CGFloat = defaultOffset + multiplier * CGFloat(j)
                
                Board.board[i][j].image.snp.makeConstraints { im in
                    im.top.equalTo(view.safeAreaLayoutGuide.snp.centerY).offset(topOffset)
                    im.leading.equalTo(view.safeAreaLayoutGuide.snp.centerX).offset(leadingOffset + 3)
                    im.size.equalTo(multiplier - 6)
                }
            }
        }
        
        view.layoutIfNeeded()
        
        let minX = Board.board.flatMap { $0 }.map { $0.image.frame.minX }.min() ?? 0
        let minY = Board.board.flatMap { $0 }.map { $0.image.frame.minY }.min() ?? 0
        let maxX = Board.board.flatMap { $0 }.map { $0.image.frame.maxX }.max() ?? 0
        let maxY = Board.board.flatMap { $0 }.map { $0.image.frame.maxY }.max() ?? 0

        Board.rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    private func setupCanvas() {
        let xOffset: CGFloat = CGFloat((6 * (Board.size + 1)))
        let halfSize: CGFloat = CGFloat(Board.size / 2)
        let defaultOffset: CGFloat = (view.frame.width - xOffset) / halfSize * -1
        canvas = Canvas(frame: Board.rect)
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(drag(_:)))
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        panRecognizer.cancelsTouchesInView = false
        canvas.addGestureRecognizer(panRecognizer)
        canvas.isUserInteractionEnabled = true
        view.addSubview(canvas)
        canvas.translatesAutoresizingMaskIntoConstraints = false
        
        canvas.snp.makeConstraints { im in
            im.top.equalTo(view.safeAreaLayoutGuide.snp.centerY).offset(defaultOffset)
            im.leading.equalTo(view.safeAreaLayoutGuide.snp.centerX).offset(defaultOffset + 3)
            im.width.equalTo(Board.rect.width)
            im.height.equalTo(Board.rect.height)
        }
        
        Board.lineLayer = CAShapeLayer()
        Board.lineLayer.strokeColor = UIColor.red.cgColor.copy(alpha: 0.8)
        Board.lineLayer.lineCap = .round
        Board.lineLayer.lineJoin = .round
        Board.lineLayer.fillColor = UIColor.clear.cgColor
        Board.lineLayer.lineWidth = 15
        canvas.layer.addSublayer(Board.lineLayer)
    }
    
    @objc func drag(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.location(in: canvas)
        let row = floor(point.x / Board.rect.width * CGFloat(Board.size))
        let col = floor(point.y / Board.rect.height * CGFloat(Board.size))
        
        if row < 0.0 || row >= CGFloat(Board.size) || col < 0.0 || col >= CGFloat(Board.size) {
            return
        }
        
        let squareSize = Board.rect.width / CGFloat(Board.size)
        
        if (gestureRecognizer.state == .changed || gestureRecognizer.state == .began) && !Board.draggedTiles.contains(CGPoint(x: row, y: col)) && abs(Board.draggedTiles.last!.x - row) <= 1 && abs(Board.draggedTiles.last!.y - col) <= 1 && abs(min(point.x.truncatingRemainder(dividingBy: squareSize), squareSize - point.x.truncatingRemainder(dividingBy: squareSize))) > 6 && abs(min(point.y.truncatingRemainder(dividingBy: squareSize), squareSize - point.y.truncatingRemainder(dividingBy: squareSize))) > 6 {
            let squareSize = Board.rect.width / CGFloat(Board.size)
            let x = squareSize * CGFloat(row + 0.5)
            let y = squareSize * CGFloat(col + 0.5)
            Board.path.addLine(to: CGPoint(x: x, y: y))
            Board.lineLayer.path = Board.path.cgPath
            Board.draggedTiles.append(CGPoint(x: row, y: col))
            let letterObj = Board.board[Int(col)][Int(row)]
            Board.selectedWord += letterObj.letter.uppercased()
            Board.currentWordLabel.text = Board.selectedWord
            letterObj.image.image = UIImage(named: "\(letterObj.letter)-white")
            let xOffset: CGFloat = CGFloat((6 * (Board.size + 1)))
            let halfSize: CGFloat = CGFloat(Board.size / 2)
            let defaultOffset: CGFloat = (view.frame.width - xOffset) / halfSize * -1
            let multiplier: CGFloat = (view.frame.width - xOffset) / CGFloat(Board.size)
            let topOffset: CGFloat = defaultOffset + multiplier * CGFloat(col)
            let leadingOffset: CGFloat = defaultOffset + multiplier * CGFloat(row)
            UIView.animate(withDuration: 0.2, delay: 0) {
                letterObj.image.snp.updateConstraints { im in
                    im.top.equalTo(self.view.safeAreaLayoutGuide.snp.centerY).offset(topOffset - 2)
                    im.leading.equalTo(self.view.safeAreaLayoutGuide.snp.centerX).offset(leadingOffset + 1)
                    im.size.equalTo(multiplier - 2)
                }
                self.view.layoutIfNeeded()
            }
            if Board.foundWords.contains(Board.selectedWord.lowercased()) {
                Board.lineLayer.strokeColor = UIColor.white.cgColor.copy(alpha: 0.8)
                Board.currentWordLabel.backgroundColor = UIColor.orangeTheme
                for square in Board.draggedTiles {
                    let letterObj = Board.board[Int(square.y)][Int(square.x)]
                    letterObj.image.image = UIImage(named: "\(letterObj.letter)-orange")
                }
            } else if words.contains(Board.selectedWord.lowercased()) {
                Board.currentWordLabel.text! += " (+\(Board.scoring[Board.selectedWord.count] ?? 3000))"
                Board.lineLayer.strokeColor = UIColor.white.cgColor.copy(alpha: 0.8)
                Board.currentWordLabel.backgroundColor = UIColor.greenTheme
                for square in Board.draggedTiles {
                    let letterObj = Board.board[Int(square.y)][Int(square.x)]
                    letterObj.image.image = UIImage(named: "\(letterObj.letter)-green")
                }
            } else {
                Board.lineLayer.strokeColor = UIColor.red.cgColor.copy(alpha: 0.8)
                Board.currentWordLabel.backgroundColor = UIColor.darkTheme
                for square in Board.draggedTiles {
                    let letterObj = Board.board[Int(square.y)][Int(square.x)]
                    letterObj.image.image = UIImage(named: "\(letterObj.letter)-white")
                }
            }
        }
        if gestureRecognizer.state == .ended {
            Board.lineLayer.path = nil
            let xOffset: CGFloat = CGFloat((6 * (Board.size + 1)))
            let halfSize: CGFloat = CGFloat(Board.size / 2)
            let defaultOffset: CGFloat = (view.frame.width - xOffset) / halfSize * -1
            let multiplier: CGFloat = (view.frame.width - xOffset) / CGFloat(Board.size)
            for square in Board.draggedTiles {
                let letterObj = Board.board[Int(square.y)][Int(square.x)]
                letterObj.image.image = UIImage(named: letterObj.letter)
                let topOffset: CGFloat = defaultOffset + multiplier * CGFloat(square.y)
                let leadingOffset: CGFloat = defaultOffset + multiplier * CGFloat(square.x)
                UIView.animate(withDuration: 0.2, delay: 0) {
                    letterObj.image.snp.updateConstraints { im in
                        im.top.equalTo(self.view.safeAreaLayoutGuide.snp.centerY).offset(topOffset)
                        im.leading.equalTo(self.view.safeAreaLayoutGuide.snp.centerX).offset(leadingOffset + 3)
                        im.size.equalTo(multiplier - 6)
                    }
                    self.view.layoutIfNeeded()
                }
            }
            
            if words.contains(Board.selectedWord.lowercased()) && !Board.foundWords.contains(Board.selectedWord.lowercased()) {
                Board.score += Board.scoring[Board.selectedWord.count] ?? 3000
                Board.scoreLabel.countFromCurrentValue(to: CGFloat(Board.score))
                Board.wordCount += 1
                Board.wordCountLabel.text = String(Board.wordCount)
                Board.foundWords.append(Board.selectedWord.lowercased())
            }
            
            Board.draggedTiles = []
            UIView.animate(withDuration: 0.2, delay: 0) {
                Board.currentWordLabel.alpha = 0
                self.view.layoutIfNeeded()
            }
            Board.selectedWord = ""
        }
    }
}

class Canvas: UIView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let point = touches.first!.location(in: self)
        let row = floor(point.x / Board.rect.width * CGFloat(Board.size))
        let col = floor(point.y / Board.rect.height * CGFloat(Board.size))
        
        if row < 0.0 || row >= CGFloat(Board.size) || col < 0.0 || col >= CGFloat(Board.size) {
            return
        }
        
        let squareSize = Board.rect.width / CGFloat(Board.size)
        
        if !Board.draggedTiles.isEmpty {
            return
        }
        
        Board.lineLayer.strokeColor = UIColor.red.cgColor.copy(alpha: 0.8)
        Board.path = UIBezierPath()
        let x = squareSize * CGFloat(row + 0.5)
        let y = squareSize * CGFloat(col + 0.5)
        Board.path.move(to: CGPoint(x: x, y: y))
        Board.path.addLine(to: CGPoint(x: x, y: y))
        Board.lineLayer.path = Board.path.cgPath
        Board.draggedTiles.append(CGPoint(x: row, y: col))
        let letterObj = Board.board[Int(col)][Int(row)]
        Board.selectedWord = letterObj.letter.uppercased()
        Board.currentWordLabel.text = Board.selectedWord
        Board.currentWordLabel.alpha = 1
        Board.currentWordLabel.backgroundColor = UIColor.darkTheme
        letterObj.image.image = UIImage(named: "\(letterObj.letter)-white")
        let xOffset: CGFloat = CGFloat((6 * (Board.size + 1)))
        let halfSize: CGFloat = CGFloat(Board.size / 2)
        let defaultOffset: CGFloat = (superview!.frame.width - xOffset) / halfSize * -1
        let multiplier: CGFloat = (superview!.frame.width - xOffset) / CGFloat(Board.size)
        let topOffset: CGFloat = defaultOffset + multiplier * CGFloat(col)
        let leadingOffset: CGFloat = defaultOffset + multiplier * CGFloat(row)
        
        UIView.animate(withDuration: 0.2, delay: 0) {
            letterObj.image.snp.updateConstraints { im in
                im.top.equalTo(self.superview!.safeAreaLayoutGuide.snp.centerY).offset(topOffset - 2)
                im.leading.equalTo(self.superview!.safeAreaLayoutGuide.snp.centerX).offset(leadingOffset + 1)
                im.size.equalTo(multiplier - 2)
            }
            self.superview!.layoutIfNeeded()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        Board.lineLayer.path = nil
        let xOffset: CGFloat = CGFloat((6 * (Board.size + 1)))
        let halfSize: CGFloat = CGFloat(Board.size / 2)
        let defaultOffset: CGFloat = (superview!.frame.width - xOffset) / halfSize * -1
        let multiplier: CGFloat = (superview!.frame.width - xOffset) / CGFloat(Board.size)
        for square in Board.draggedTiles {
            let letterObj = Board.board[Int(square.y)][Int(square.x)]
            letterObj.image.image = UIImage(named: letterObj.letter)
            let topOffset: CGFloat = defaultOffset + multiplier * CGFloat(square.y)
            let leadingOffset: CGFloat = defaultOffset + multiplier * CGFloat(square.x)
            UIView.animate(withDuration: 0.2, delay: 0) {
                letterObj.image.snp.updateConstraints { im in
                    im.top.equalTo(self.superview!.safeAreaLayoutGuide.snp.centerY).offset(topOffset)
                    im.leading.equalTo(self.superview!.safeAreaLayoutGuide.snp.centerX).offset(leadingOffset + 3)
                    im.size.equalTo(multiplier - 6)
                }
                self.superview!.layoutIfNeeded()
            }
        }
        Board.draggedTiles = []
        UIView.animate(withDuration: 0.2, delay: 0) {
            Board.currentWordLabel.alpha = 0
            self.superview!.layoutIfNeeded()
        }
        Board.selectedWord = ""
    }
}

struct LetterImage {
    var image: UIImageView
    var letter: String
}

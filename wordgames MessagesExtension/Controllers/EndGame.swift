//
//  EndGame.swift
//  wordgames MessagesExtension
//
//  Created by Joshua Ochalek on 12/31/23.
//

import Foundation
import UIKit
import SnapKit

class EndGame: UIViewController {
    
    private let youInfoBox = UIView()
    private let youScoreText = UILabel()
    private let youScoreLabel = UILabel()
    private let youWordsText = UILabel()
    private let youWordsLabel = UILabel()
    private var youCollectionView: UICollectionView!
    
    private let oppInfoBox = UIView()
    private let oppScoreText = UILabel()
    private let oppScoreLabel = UILabel()
    private let oppWordsText = UILabel()
    private let oppWordsLabel = UILabel()
    private var oppCollectionView: UICollectionView!
    
    private let waitingBackground = UIView()
    private let waitingLabel = WordText()
    private let resultsLabel = WordText()
    
    let gameId: String
    private let youWordsFound: [String]
    private var youScore = 0
    private var oppWordsFound: [String]
    private var oppScore = 0
    private var hasOppInfo: Bool
    private var cameFromGame: Bool
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupCollectionViews()
        setupYouInfoBox()
        setupOppInfoBox()
        
        if hasOppInfo {
            animateResults()
        } else {
            animateWait()
        }
    }
    
    init(gameId: String, wordsFound: [String], oppWordsFound: [String]? = nil, cameFromGame: Bool = true) {
        self.gameId = gameId
        
        self.hasOppInfo = oppWordsFound != nil
        
        self.youWordsFound = wordsFound.sorted {
            $0.count > $1.count
        }
        
        if hasOppInfo {
            self.oppWordsFound = oppWordsFound!.sorted {
                $0.count > $1.count
            }
        } else {
            self.oppWordsFound = []
        }
        
        self.cameFromGame = cameFromGame
        
        super.init(nibName: nil, bundle: nil)
        
        wordsFound.forEach { elem in
            self.youScore += Board.scoring[elem.count] ?? 3000
        }
        
        if hasOppInfo {
            self.oppWordsFound.forEach { elem in
                self.oppScore += Board.scoring[elem.count] ?? 3000
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupOppInfoBox() {
        var backgroundColor: UIColor
        var textColor: UIColor
        var secondarytextColor: UIColor
        if traitCollection.userInterfaceStyle == .light {
            backgroundColor = .darkTheme
            textColor = .whiteTheme
            secondarytextColor = .lightWhiteTheme
        } else {
            backgroundColor = .whiteTheme
            textColor = .darkTheme
            secondarytextColor = .lightWhiteTheme
        }
        
        oppInfoBox.backgroundColor = backgroundColor.withAlphaComponent(0.8)
        oppInfoBox.layer.cornerRadius = 8
        oppInfoBox.layer.masksToBounds = true
        
        view.addSubview(oppInfoBox)
        oppInfoBox.translatesAutoresizingMaskIntoConstraints = false
        
        
        oppInfoBox.snp.makeConstraints { im in
            im.centerX.equalTo(oppCollectionView.snp.centerX)
            im.bottom.equalTo(oppCollectionView.snp.top).inset(-8)
            im.height.equalTo(50)
            im.width.equalTo(oppCollectionView.snp.width)
        }
        
        oppScoreText.text = "Score"
        oppScoreText.textColor = secondarytextColor
        oppScoreText.font = UIFont(name: "Rubik", size: 12)
        
        oppInfoBox.addSubview(oppScoreText)
        oppScoreText.translatesAutoresizingMaskIntoConstraints = false
        
        oppScoreText.snp.makeConstraints { im in
            im.top.equalToSuperview().offset(3)
            im.trailing.equalToSuperview().inset(6)
        }
        
        oppScoreLabel.text = String(format: "%04d", oppScore)
        oppScoreLabel.textColor = textColor
        oppScoreLabel.font = UIFont(name: "Rubik", size: 28)
        
        oppInfoBox.addSubview(oppScoreLabel)
        oppScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        oppScoreLabel.snp.makeConstraints { im in
            im.bottom.equalToSuperview().inset(3)
            im.trailing.equalToSuperview().inset(6)
        }
        
        oppWordsText.text = "Words"
        oppWordsText.textColor = secondarytextColor
        oppWordsText.font = UIFont(name: "Rubik", size: 12)
        
        oppInfoBox.addSubview(oppWordsText)
        oppWordsText.translatesAutoresizingMaskIntoConstraints = false
        
        oppWordsText.snp.makeConstraints { im in
            im.top.equalToSuperview().offset(3)
            im.leading.equalToSuperview().offset(6)
        }
        
        oppWordsLabel.text = String(oppWordsFound.count)
        oppWordsLabel.textColor = textColor
        oppWordsLabel.font = UIFont(name: "Rubik", size: 28)
        
        oppInfoBox.addSubview(oppWordsLabel)
        oppWordsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        oppWordsLabel.snp.makeConstraints { im in
            im.bottom.equalToSuperview().inset(3)
            im.leading.equalToSuperview().offset(6)
        }
    }
    
    private func setupYouInfoBox() {
        var backgroundColor: UIColor
        var textColor: UIColor
        var secondarytextColor: UIColor
        if traitCollection.userInterfaceStyle == .light {
            backgroundColor = .darkTheme
            textColor = .whiteTheme
            secondarytextColor = .lightWhiteTheme
        } else {
            backgroundColor = .whiteTheme
            textColor = .darkTheme
            secondarytextColor = .lightWhiteTheme
        }
        
        youInfoBox.backgroundColor = backgroundColor.withAlphaComponent(0.8)
        youInfoBox.layer.cornerRadius = 8
        youInfoBox.layer.masksToBounds = true
        
        view.addSubview(youInfoBox)
        youInfoBox.translatesAutoresizingMaskIntoConstraints = false
        
        youInfoBox.snp.makeConstraints { im in
            im.centerX.equalTo(youCollectionView.snp.centerX)
            im.bottom.equalTo(youCollectionView.snp.top).inset(-8)
            im.height.equalTo(50)
            im.width.equalTo(youCollectionView.snp.width)
        }
        
        youScoreText.text = "Score"
        youScoreText.textColor = secondarytextColor
        youScoreText.font = UIFont(name: "Rubik", size: 12)
        
        youInfoBox.addSubview(youScoreText)
        youScoreText.translatesAutoresizingMaskIntoConstraints = false
        
        youScoreText.snp.makeConstraints { im in
            im.top.equalToSuperview().offset(3)
            im.leading.equalToSuperview().offset(6)
        }
        
        youScoreLabel.text = String(format: "%04d", youScore)
        youScoreLabel.textColor = textColor
        youScoreLabel.font = UIFont(name: "Rubik", size: 28)
        
        youInfoBox.addSubview(youScoreLabel)
        youScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        youScoreLabel.snp.makeConstraints { im in
            im.bottom.equalToSuperview().inset(3)
            im.leading.equalToSuperview().offset(6)
        }
        
        youWordsText.text = "Words"
        youWordsText.textColor = secondarytextColor
        youWordsText.font = UIFont(name: "Rubik", size: 12)
        
        youInfoBox.addSubview(youWordsText)
        youWordsText.translatesAutoresizingMaskIntoConstraints = false
        
        youWordsText.snp.makeConstraints { im in
            im.top.equalToSuperview().offset(3)
            im.trailing.equalToSuperview().inset(6)
        }
        
        youWordsLabel.text = String(youWordsFound.count)
        youWordsLabel.textColor = textColor
        youWordsLabel.font = UIFont(name: "Rubik", size: 28)
        
        youInfoBox.addSubview(youWordsLabel)
        youWordsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        youWordsLabel.snp.makeConstraints { im in
            im.bottom.equalToSuperview().inset(3)
            im.trailing.equalToSuperview().inset(6)
        }
    }
    
    private func setupCollectionViews() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        
        youCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        youCollectionView.register(WordCollectionViewCell.self, forCellWithReuseIdentifier: WordCollectionViewCell.reuse)
        youCollectionView.delegate = self
        youCollectionView.dataSource = self
        youCollectionView.backgroundColor = .lightDarkTheme
        youCollectionView.layer.cornerRadius = 8
        youCollectionView.layer.masksToBounds = true
        
        view.addSubview(youCollectionView)
        youCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        youCollectionView.snp.makeConstraints { im in
            im.centerX.equalTo(view.frame.width / 4)
            im.centerY.equalToSuperview()
            im.height.equalTo(view.frame.height / 3)
            im.width.equalTo(min(view.frame.width / 2 - 40, 150))
        }
        
        let layoutOpp = UICollectionViewFlowLayout()
        layoutOpp.scrollDirection = .vertical
        layoutOpp.minimumLineSpacing = 2
        layoutOpp.minimumInteritemSpacing = 2
        
        oppCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutOpp)
        oppCollectionView.register(WordCollectionViewCell.self, forCellWithReuseIdentifier: WordCollectionViewCell.reuse)
        oppCollectionView.delegate = self
        oppCollectionView.dataSource = self
        oppCollectionView.backgroundColor = .lightDarkTheme
        oppCollectionView.layer.cornerRadius = 8
        oppCollectionView.layer.masksToBounds = true
        
        view.addSubview(oppCollectionView)
        oppCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        oppCollectionView.snp.makeConstraints { im in
            im.centerX.equalTo(view.frame.width / 4 * 3)
            im.centerY.equalToSuperview()
            im.height.equalTo(view.frame.height / 3)
            im.width.equalTo(min(view.frame.width / 2 - 40, 150))
        }
    }
    
    func animateWait() {
        view.addSubview(waitingBackground)
        waitingBackground.translatesAutoresizingMaskIntoConstraints = false
        waitingBackground.snp.makeConstraints { im in
            im.top.bottom.leading.trailing.equalToSuperview()
        }
        
        waitingLabel.text = "SENT"
        waitingLabel.textColor = .whiteTheme
        waitingLabel.font = UIFont(name: "Rubik", size: 18)
        waitingLabel.backgroundColor = .darkTheme
        waitingLabel.layer.cornerRadius = 4
        waitingLabel.layer.masksToBounds = true
        
        view.addSubview(waitingLabel)
        waitingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if cameFromGame {
            waitingLabel.snp.makeConstraints { im in
                im.centerX.equalToSuperview()
                im.bottom.equalTo(view.snp.top)
            }
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if !self.waitingBackground.isHidden {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                        self.waitingBackground.backgroundColor = .darkTheme.withAlphaComponent(0.5)
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if !self.waitingBackground.isHidden {
                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
                        self.waitingLabel.snp.remakeConstraints { im in
                            im.bottom.equalToSuperview().inset(50)
                            im.centerX.equalToSuperview()
                        }
                        self.view.layoutIfNeeded()
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if !self.waitingBackground.isHidden {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve) {
                        self.waitingLabel.text = "Waiting for opponent"
                        self.view.layoutIfNeeded()
                    }
                    Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
                        if self.waitingLabel.text!.filter({ $0 == "." }).count == 3 {
                            self.waitingLabel.text = "Waiting for opponent"
                        } else {
                            self.waitingLabel.text! += "."
                        }
                        
                        if self.waitingBackground.isHidden {
                            timer.invalidate()
                        }
                    }
                }
            }
        } else {
            self.waitingLabel.snp.makeConstraints { im in
                im.bottom.equalToSuperview().inset(50)
                im.centerX.equalToSuperview()
            }
            waitingBackground.backgroundColor = .darkTheme.withAlphaComponent(0.5)
            UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve) {
                self.waitingLabel.text = "Waiting for opponent"
                self.view.layoutIfNeeded()
            }
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
                if self.waitingLabel.text!.filter({ $0 == "." }).count == 3 {
                    self.waitingLabel.text = "Waiting for opponent"
                } else {
                    self.waitingLabel.text! += "."
                }
                
                if self.waitingBackground.isHidden {
                    timer.invalidate()
                }
            }
        }
    }
    
    func updateOpp(oppWordsFound: [String]) {
        hasOppInfo = true
        self.oppWordsFound = oppWordsFound.sorted {
            $0.count > $1.count
        }
        self.oppWordsFound.forEach { elem in
            self.oppScore += Board.scoring[elem.count] ?? 3000
        }
        
        waitingBackground.isHidden = true
        waitingLabel.isHidden = true
        
        oppWordsLabel.text = String(oppWordsFound.count)
        oppScoreLabel.text = String(format: "%04d", oppScore)
        animateResults()
    }
    
    private func animateResults() {
        if youScore > oppScore {
            resultsLabel.text = "YOU WON!"
            resultsLabel.textColor = .darkTheme
            resultsLabel.backgroundColor = .orangeTheme
        } else if youScore < oppScore {
            resultsLabel.text = "YOU LOST!"
            resultsLabel.textColor = .red
            resultsLabel.backgroundColor = .black
        } else {
            resultsLabel.text = "DRAW!"
            resultsLabel.textColor = .orangeTheme
            resultsLabel.backgroundColor = .black
        }
        resultsLabel.font = UIFont(name: "Rubik-Bold", size: 18)
        resultsLabel.layer.cornerRadius = 4
        resultsLabel.layer.masksToBounds = true
        resultsLabel.topInset = 7
        resultsLabel.bottomInset = 7
        resultsLabel.leftInset = 28
        resultsLabel.rightInset = 28
        
        view.addSubview(resultsLabel)
        resultsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        resultsLabel.snp.makeConstraints { im in
            im.centerX.equalToSuperview()
            im.top.equalToSuperview().offset(50)
        }
    }
}

extension EndGame: UICollectionViewDelegate { }

extension EndGame: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == youCollectionView {
            return youWordsFound.count
        } else {
            return oppWordsFound.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WordCollectionViewCell.reuse, for: indexPath) as? WordCollectionViewCell else {
            return UICollectionViewCell()
        }
        if collectionView == youCollectionView {
            cell.configure(word: youWordsFound[indexPath.item], reversed: false)
        } else {
            cell.configure(word: oppWordsFound[indexPath.item], reversed: true)
        }
        return cell
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
    }
}

extension EndGame: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 24)
    }
}

//
//  WordCollectionViewCell.swift
//  wordgames MessagesExtension
//
//  Created by Joshua Ochalek on 12/31/23.
//

import Foundation
import UIKit

class WordCollectionViewCell: UICollectionViewCell {
    
    static let reuse = "WordCollectionViewCellReuse"
    
    private let wordLabel = WordText()
    private let scoreLabel = UILabel()
    
    private var word: String!
    private var reversed: Bool!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWordLabel() {
        wordLabel.bottomInset = 3
        wordLabel.topInset = 3
        wordLabel.leftInset = 6
        wordLabel.rightInset = 6
        wordLabel.text = word.uppercased()
        wordLabel.backgroundColor = .darkTheme
        wordLabel.textColor = .whiteTheme
        wordLabel.font = UIFont(name: "Rubik", size: 14)
        wordLabel.layer.cornerRadius = 4
        wordLabel.layer.masksToBounds = true
        
        contentView.addSubview(wordLabel)
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if reversed {
            wordLabel.snp.makeConstraints { im in
                im.centerY.equalToSuperview()
                im.trailing.equalToSuperview().inset(6)
            }
        } else {
            wordLabel.snp.makeConstraints { im in
                im.centerY.equalToSuperview()
                im.leading.equalToSuperview().offset(6)
            }
        }
    }
    
    private func setupScoreLabel() {
        scoreLabel.text = String(Board.scoring[word.count] ?? 3000)
        scoreLabel.textColor = .whiteTheme
        scoreLabel.font = UIFont(name: "Rubik", size: 14)
        
        contentView.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if reversed {
            scoreLabel.snp.makeConstraints { im in
                im.centerY.equalToSuperview()
                im.leading.equalToSuperview().offset(6)
            }
        } else {
            scoreLabel.snp.makeConstraints { im in
                im.centerY.equalToSuperview()
                im.trailing.equalToSuperview().inset(6)
            }
        }
    }
    
    func configure(word: String, reversed: Bool) {
        self.word = word
        self.reversed = reversed
        setupWordLabel()
        setupScoreLabel()
    }
}

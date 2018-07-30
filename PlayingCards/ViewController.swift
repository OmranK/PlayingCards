//
//  ViewController.swift
//  PlayingCards
//
//  Created by Omran Khoja on 7/9/18.
//  Copyright © 2018 AcronDesign. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var deck = Deck()

    @IBOutlet weak var playingCardView: PlayingCardView! {
        didSet {
            let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
            swipeGestureRecognizer.direction = [.left, .right]
            playingCardView.addGestureRecognizer(swipeGestureRecognizer)
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: playingCardView, action: #selector(playingCardView.adjustFaceCardScale(byHandlingGestureRecognizedBy:)))
            playingCardView.addGestureRecognizer(pinchGestureRecognizer)
        }
    }
    
    @objc func nextCard(){
        if let card = deck.draw() {
            playingCardView.rank = card.rank.order
            playingCardView.suit = card.suit.rawValue
        }
    }
    
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended: playingCardView.isFaceUp = !playingCardView.isFaceUp
        default: break
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 1...10 {
            if let card = deck.draw() {
                print(card)
            }
        }
    }


}


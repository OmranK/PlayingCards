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

    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 1...10 {
            if let card = deck.draw() {
                print(card)
            }
        }
    }


}


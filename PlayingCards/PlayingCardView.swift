//
//  PlayingCardView.swift
//  PlayingCards
//
//  Created by Omran Khoja on 7/13/18.
//  Copyright © 2018 AcronDesign. All rights reserved.
//

import UIKit

@IBDesignable class PlayingCardView: UIView {
    
    // @IBInspectable shows variables in Interface Builder.
    @IBInspectable var rank: Int = 13 { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable var suit: String = "♠️" { didSet { setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() } }
    
    
    // Create the two card face Labels. Lazy variables get initialized only when createCornerLabel() is called.
    private lazy var upperLeftCornerLabel = createCornerLabel()
    private lazy var lowerRightCornerLabel = createCornerLabel()
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        
        if isFaceUp {
            if let faceCardImage = UIImage(named: rankString+suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection){
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
            } else {
                drawPips()
            }
        }
    }
    
    // Gesture Recognizer handler to adjust the faceCard image's size.
    var faceCardScale: CGFloat = DisplayRatio.faceCardImageSizeToBounds { didSet { setNeedsDisplay() } }
    @objc func adjustFaceCardScale(byHandlingGestureRecognizedBy recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            faceCardScale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    // Redraws everything and resets the layout when DisplaySizes option in accessibility is changed.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    // System will call this when setNeedsLayout is called by caller. Where you set up all Subview layouts.
    override func layoutSubviews() {
        super.layoutSubviews()
        configureCornerLabel(upperLeftCornerLabel)
        upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
        
        configureCornerLabel(lowerRightCornerLabel)
        
        lowerRightCornerLabel.transform = CGAffineTransform.identity
            .translatedBy(x: lowerRightCornerLabel.frame.width, y: lowerRightCornerLabel.frame.height)
            .rotated(by: CGFloat.pi)
        
        lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY)
            .offsetBy(dx: -cornerOffset, dy: -cornerOffset)
            .offsetBy(dx: -lowerRightCornerLabel.frame.width, dy: -lowerRightCornerLabel.frame.height)
    }
}




// MARK: Extension sets up all Labels
extension PlayingCardView {
    // Function: Sets up Label
    private func createCornerLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    //
    private func configureCornerLabel(_ label: UILabel) {
        label.attributedText = cornerString
        label.frame.size = CGSize.zero // always call before sizeToFit()
        label.sizeToFit()
        label.isHidden = !isFaceUp
    }
    
    private func drawPips() {
        let pipsPerRowForRank = [[0], [1], [1,1], [1,1,1,], [2,2], [2,1,2], [2,2,2], [2,1,2,2], [2,2,2,2], [2,2,1,2,2,], [2,2,2,2,2] ]
        
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0) })
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0) })
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
            if probablyOkayPipString.size().width > (pipRect.size.width / maxHorizontalPipCount) {
                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize /
                    (probablyOkayPipString.size().width / (pipRect.size.width / maxVerticalPipCount)))
            } else {
                return probablyOkayPipString
            }
        }
        
        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                case 1: pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default: break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }
}


// MARK: Extension containing size, ratio, offset and rank variables.
extension PlayingCardView {
    private struct DisplayRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBounds: CGFloat = 0.75
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * DisplayRatio.cornerRadiusToBoundsHeight
    }
    
    private var cornerOffset: CGFloat {
        return cornerRadius * DisplayRatio.cornerOffsetToCornerRadius
    }
    
    private var cornerFontSize: CGFloat {
        return bounds.size.height * DisplayRatio.cornerFontSizeToBoundsHeight
    }
    
    private var rankString: String {
        switch rank {
        case 1 : return "A"
        case 2...10 : return String(rank)
        case 11 : return "J"
        case 12 : return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
    
    // Call centeredAttributedString(_) function using rankString(_) function to get the Card's suit and rank in an NSAttributedString format for display.
    private var cornerString: NSAttributedString {
        return centeredAttributedString(rankString + "\n" + suit, fontSize: cornerFontSize)
    }
    
    // Takes string and adds font and paragraph Styles.
    private func centeredAttributedString(_ string:String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .largeTitle).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: font)  //Always use for Display Size option in accessibility.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle : paragraphStyle, .font : font])
    }
    
}

// MARK: Ease of use extension on CGRect.
extension CGRect {
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    
    func inset(by size: CGRect) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth), dy: (height - newHeight))
    }
}

// MARK: Ease of use extension on CGPoint.
extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint{
        return CGPoint(x: x+dx, y: y+dy)
    }
}


// Using context
//        if let context = UIGraphicsGetCurrentContext() { // Cant draw in draw rect without context.
//            context.addArc(center: CGPoint(x: bounds.midX, y: bounds.midY), radius: 100, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
//            context.setLineWidth(5.0)
//            UIColor.green.setFill()
//            UIColor.red.setStroke()
//            context.strokePath()
//            context.fillPath()
//        }

// Using UIBezierPath
//        let path = UIBezierPath()
//        path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: 100, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
//        path.lineWidth = 0.5
//        UIColor.green.setFill()
//        UIColor.red.setStroke()
//        path.stroke()
//        path.fill()



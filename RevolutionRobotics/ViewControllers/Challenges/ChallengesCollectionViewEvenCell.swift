//
//  ChallengesCollectionViewCell.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 03..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

enum Progress {
    case unavailable
    case available
    case completed
}

final class ChallengesCollectionViewEvenCell: UICollectionViewCell {
    // MARK: - Constants
    enum Constants {
        static let inactiveAlpha: CGFloat = 0.4
        static let activeAlpha: CGFloat = 1
    }

    // MARK: - Outlets
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var lineImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var challengeNumberLabel: UILabel!

    // MARK: - Properties
    var isFirstItem: Bool = false {
        didSet {
            lineImageView.isHidden = isFirstItem
        }
    }
    var progress: Progress = .unavailable
}

// MARK: - Reuse
extension ChallengesCollectionViewEvenCell {
    override func prepareForReuse() {
        super.prepareForReuse()

        progress = .unavailable
        isFirstItem = false
    }
}

// MARK: - Setup
extension ChallengesCollectionViewEvenCell {
    func setup(with challenge: Challenge, index: Int) {
        nameLabel.text = challenge.name.text
        challengeNumberLabel.text = "\(index)."

        switch progress {
        case .unavailable:
            setUnavailable()
        case .available:
            setAvailable()
        case .completed:
            setCompleted()
        }
    }

    private func setUnavailable() {
        cardImageView.image = Image.Challenges.ChallengeInactiveCard
        lineImageView.image = Image.Challenges.ChallengeGreyLine
        challengeNumberLabel.textColor = .white
        lineImageView.alpha = Constants.inactiveAlpha
        nameLabel.alpha = Constants.inactiveAlpha
        challengeNumberLabel.alpha = Constants.inactiveAlpha
    }

    private func setAvailable() {
        cardImageView.image = Image.Challenges.ChallengeActiveCard
        lineImageView.image = Image.Challenges.ChallengeGreyLine
        challengeNumberLabel.textColor = .white
        lineImageView.alpha = Constants.activeAlpha
        nameLabel.alpha = Constants.activeAlpha
        challengeNumberLabel.alpha = Constants.activeAlpha
    }

    private func setCompleted() {
        cardImageView.image = Image.Challenges.ChallengeFinishedCard
        lineImageView.image = Image.Challenges.ChallengeGoldLine
        challengeNumberLabel.textColor = Color.blackTwo
        lineImageView.alpha = Constants.activeAlpha
        nameLabel.alpha = Constants.activeAlpha
        challengeNumberLabel.alpha = Constants.activeAlpha
    }
}

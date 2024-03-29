//
//  WhoToBuildCollectionViewCell.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class WhoToBuildCollectionViewCell: ResizableCell {
    // MARK: - Constants
    private enum Constants {
        static let clockIconLeadingConstraintRatio: CGFloat = 12.0 / 213.0
        static let clockIconBottomConstraintRatio: CGFloat = 16.0 / 224.0
        static let iPhoneSEScreenHeight: CGFloat = 320
        static let iPhone8ScreenHeight: CGFloat = 375
        static let iPhoneSEFontSizeMultiplier: CGFloat = 0.66
        static let iPhone8FontSizeMultiplier: CGFloat = 0.9
    }

    // MARK: - Outlets
    @IBOutlet private weak var baseHeight: NSLayoutConstraint!
    @IBOutlet private weak var baseWidth: NSLayoutConstraint!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var buildTimeLabel: UILabel!
    @IBOutlet private weak var robotImageView: UIImageView!
    @IBOutlet private weak var robotNameLabel: UILabel!
    @IBOutlet private weak var clockImageView: UIImageView!
    @IBOutlet private weak var clockImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var clockImageBottomConstraint: NSLayoutConstraint!

    // MARK: - Properties
    private var baseHeightMultiplier: CGFloat = 0
    private var baseWidthMultiplier: CGFloat = 0
    private var baseImageWidthMultiplier: CGFloat = 0
    private var baseNameFontSize: CGFloat = 0
    private var baseBuildTimeFontSize: CGFloat = 0

    override var isCentered: Bool {
        didSet {
            backgroundImageView.image = isCentered ? Image.BuildRobot.cellRedBorder : Image.BuildRobot.cellWhiteBorder
        }
    }
}

// MARK: - Public methods
extension WhoToBuildCollectionViewCell {
    func configure(with robot: Robot) {
        robotNameLabel.text = robot.name.text
        buildTimeLabel.text = robot.buildTime
        robotImageView.downloadImage(googleStorageURL: robot.coverImageGSURL)
    }

    func configureNew() {
        clockImageView.isHidden = true
        robotNameLabel.text = "Build your own"
        robotImageView.image = UIImage(named: "AddIcon")
        buildTimeLabel.text = nil

        NSLayoutConstraint.activate([
            robotImageView.heightAnchor.constraint(equalToConstant: 60.0),
            robotImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    override func set(multiplier: CGFloat) {
        baseWidth = baseWidth.setMultiplier(multiplier: multiplier * baseWidthMultiplier)
        baseHeight = baseHeight.setMultiplier(multiplier: multiplier * baseHeightMultiplier)
        robotNameLabel.font = robotNameLabel.font.withSize(baseNameFontSize * multiplier * multiplier)
        buildTimeLabel.font = buildTimeLabel.font.withSize(buildTimeLabelFontSize(multiplier: multiplier,
                                                                                  text: buildTimeLabel.text))
    }

    private func buildTimeLabelFontSize(multiplier: CGFloat, text: String?) -> CGFloat {
        guard let text = text, text.count > 3 else { return baseBuildTimeFontSize * multiplier * multiplier }

        if UIScreen.main.bounds.size.height == Constants.iPhoneSEScreenHeight {
            return baseBuildTimeFontSize * multiplier * multiplier * Constants.iPhoneSEFontSizeMultiplier
        } else if UIScreen.main.bounds.size.height == Constants.iPhone8ScreenHeight {
            return baseBuildTimeFontSize * multiplier * multiplier * Constants.iPhone8FontSizeMultiplier
        } else {
            return baseBuildTimeFontSize * multiplier * multiplier
        }
    }
}

// MARK: - View lifecycle
extension WhoToBuildCollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        baseHeightMultiplier = baseHeight.multiplier
        baseWidthMultiplier = baseWidth.multiplier
        baseNameFontSize = robotNameLabel.font.pointSize
        baseBuildTimeFontSize = buildTimeLabel.font.pointSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        clockImageLeadingConstraint.constant = Constants.clockIconLeadingConstraintRatio * frame.size.width
        clockImageBottomConstraint.constant = Constants.clockIconBottomConstraintRatio * frame.size.height
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        backgroundImageView.image = Image.BuildRobot.cellWhiteBorder
    }
}

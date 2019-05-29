//
//  MenuTutorialViewController.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class MenuTutorialViewController: BaseViewController {
    // MARK: - TutorialStep
    private enum TutorialStep: Int {
        case robot
        case programs
        case challenges
        case community
        case settings
    }

    // MARK: - Constants
    private enum Constants {
        static let titleFont = Font.barlow(size: 14.0, weight: .bold)
        static let descriptionFont = Font.barlow(size: 12.0, weight: .regular)
    }

    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var menuItemContainer: UIView!
    @IBOutlet private weak var robotContainer: UIView!
    @IBOutlet private weak var programsContainer: UIView!
    @IBOutlet private weak var challengesContainer: UIView!
    @IBOutlet private weak var communityButton: RRButton!
    @IBOutlet private weak var settingsButton: RRButton!
    @IBOutlet private weak var menuDimView: UIView!

    @IBOutlet private weak var robotDescriptionContainerView: UIView!
    @IBOutlet private weak var robotDescriptionContentView: UIView!
    @IBOutlet private weak var robotDescriptionTitleLabel: UILabel!
    @IBOutlet private weak var robotDescriptionLabel: UILabel!

    @IBOutlet private weak var programsDescriptionContainerView: UIView!
    @IBOutlet private weak var programsDescriptionContentView: UIView!
    @IBOutlet private weak var programsDescriptionTitleLabel: UILabel!
    @IBOutlet private weak var programsDescriptionLabel: UILabel!

    @IBOutlet private weak var challengesDescriptionContainerView: UIView!
    @IBOutlet private weak var challengesDescriptionContentView: UIView!
    @IBOutlet private weak var challengesDescriptionTitleLabel: UILabel!
    @IBOutlet private weak var challengesDescriptionLabel: UILabel!

    @IBOutlet private weak var communityDescriptionContainerView: UIView!
    @IBOutlet private weak var communityDescriptionContentView: UIView!
    @IBOutlet private weak var communityDescriptionTitleLabel: UILabel!
    @IBOutlet private weak var communityDescriptionLabel: UILabel!

    @IBOutlet private weak var settingsDescriptionContainerView: UIView!
    @IBOutlet private weak var settingsDescriptionContentView: UIView!
    @IBOutlet private weak var settingsDescriptionTitleLabel: UILabel!
    @IBOutlet private weak var settingsDescriptionLabel: UILabel!
}

// MARK: - View lifecycle
extension MenuTutorialViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLabels()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(step: .robot)
        setupCorners()
    }

    private func setupCorners() {
        setBorder(on: robotDescriptionContentView)
        setBorder(on: programsDescriptionContentView)
        setBorder(on: challengesDescriptionContentView)
        setBorder(on: communityDescriptionContentView)
        setBorder(on: settingsDescriptionContentView)
    }

    private func setBorder(on view: UIView) {
        view.setBorder(fillColor: Color.blackTwo, lineWidth: 0.0, croppedCorners: [.bottomLeft, .topRight])
    }
}

// MARK: - Setups
extension MenuTutorialViewController {
    private func setupLabels() {
        robotDescriptionTitleLabel.font = Constants.titleFont
        robotDescriptionTitleLabel.text = "Under robots, you can…"
        robotDescriptionLabel.font = Constants.descriptionFont
        robotDescriptionLabel.text = """
        - Lorem ipsum dolor sit amet, eu commodo numquam comprehensam vel. Quo cu alia placerat.
        - Per graece denique invidunt ei. Case ullum euripidis duo eu.
        - Eos meis quidam omnesque et. Essent blandit ius ut, no ius melius sanctus.
        """

        programsDescriptionTitleLabel.font = Constants.titleFont
        programsDescriptionTitleLabel.text = "Under programs, you can…"
        programsDescriptionLabel.font = Constants.descriptionFont
        programsDescriptionLabel.text = """
        - Lorem ipsum dolor sit amet, eu commodo numquam comprehensam vel. Quo cu alia placerat.
        - Per graece denique invidunt ei. Case ullum euripidis duo eu.
        - Eos meis quidam omnesque et. Essent blandit ius ut, no ius melius sanctus.
        """

        challengesDescriptionTitleLabel.font = Constants.titleFont
        challengesDescriptionTitleLabel.text = "Under challanges, you can…"
        challengesDescriptionLabel.font = Constants.descriptionFont
        challengesDescriptionLabel.text = """
        - Lorem ipsum dolor sit amet, eu commodo numquam comprehensam vel. Quo cu alia placerat.
        - Per graece denique invidunt ei. Case ullum euripidis duo eu.
        - Eos meis quidam omnesque et. Essent blandit ius ut, no ius melius sanctus.
        """

        communityDescriptionTitleLabel.font = Constants.titleFont
        communityDescriptionTitleLabel.text = "Under community..."
        communityDescriptionLabel.font = Constants.descriptionFont
        communityDescriptionLabel.text = """
        - Lorem ipsum dolor sit amet, eu commodo numquam comprehensam vel. Quo cu alia placerat.
        - Per graece denique invidunt ei. Case ullum euripidis duo eu.
        - Eos meis quidam omnesque et. Essent blandit ius ut, no ius melius sanctus.
        """

        settingsDescriptionTitleLabel.font = Constants.titleFont
        settingsDescriptionTitleLabel.text = "Under community..."
        settingsDescriptionLabel.font = Constants.descriptionFont
        settingsDescriptionLabel.text = """
        - Lorem ipsum dolor sit amet, eu commodo numquam comprehensam vel. Quo cu alia placerat.
        - Per graece denique invidunt ei. Case ullum euripidis duo eu.
        - Eos meis quidam omnesque et. Essent blandit ius ut, no ius melius sanctus.
        """
    }
}

// MARK: - Private methods
extension MenuTutorialViewController {
    private func show(step: TutorialStep) {
        hideAllDescriptionViews()
        sendAllViewsToBack()
        switch step {
        case .robot:
            showRobotTutorial()
        case .programs:
            showProgramsTutorial()
        case .challenges:
            showChallengesTutorial()
        case .community:
            showCommunityTutorial()
        case .settings:
            showSettingsTutorial()
        }
    }

    private func showRobotTutorial() {
        menuItemContainer.bringSubviewToFront(robotContainer)
        robotDescriptionContainerView.isHidden = false
    }
    private func showProgramsTutorial() {
        menuItemContainer.bringSubviewToFront(programsContainer)
        programsDescriptionContainerView.isHidden = false
    }

    private func showChallengesTutorial() {
        menuItemContainer.bringSubviewToFront(challengesContainer)
        challengesDescriptionContainerView.isHidden = false
    }

    private func showCommunityTutorial() {
        view.bringSubviewToFront(communityButton)
        communityDescriptionContainerView.isHidden = false
    }

    private func showSettingsTutorial() {
        view.bringSubviewToFront(settingsButton)
        settingsDescriptionContainerView.isHidden = false
    }

    private func sendAllViewsToBack() {
        menuItemContainer.sendSubviewToBack(robotContainer)
        menuItemContainer.sendSubviewToBack(programsContainer)
        menuItemContainer.sendSubviewToBack(challengesContainer)
        view.insertSubview(settingsButton, aboveSubview: navigationBar)
        view.insertSubview(communityButton, aboveSubview: navigationBar)
    }

    private func hideAllDescriptionViews() {
        robotDescriptionContainerView.isHidden = true
        programsDescriptionContainerView.isHidden = true
        challengesDescriptionContainerView.isHidden = true
        communityDescriptionContainerView.isHidden = true
        settingsDescriptionContainerView.isHidden = true
    }
}

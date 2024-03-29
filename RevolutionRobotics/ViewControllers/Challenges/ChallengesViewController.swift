//
//  ChallengesViewController.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 03..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ChallengesViewController: BaseViewController {
    // MARK: - Constants
    private enum Constants {
        static let fontSize: CGFloat = 14.0
    }

    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var challengeDescription: UILabel!
    @IBOutlet private weak var challengesCollectionView: UICollectionView!

    // MARK: - Properties
    var realmService: RealmServiceInterface!
    private var challengeCategory: ChallengeCategory?
    private var progress: Int = 0
    private var currentChallenge: Int = 0
}

// MARK: - View lifecycle
extension ChallengesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let category = challengeCategory else { return }
        navigationBar.bluetoothButtonState = bluetoothService.connectedDevice != nil ? .connected : .notConnected
        navigationBar.setup(title: category.name.text, delegate: self)
        challengeDescription.attributedText = NSAttributedString.attributedString(from: category.description.text,
                                                                                  fontSize: Constants.fontSize)
        challengesCollectionView.delegate = self
        challengesCollectionView.dataSource = self
        challengesCollectionView.register(ChallengesCollectionViewEvenCell.self)
        challengesCollectionView.register(ChallengesCollectionViewOddCell.self)
    }
}

// MARK: - Setup
extension ChallengesViewController {
    func setup(with challengeCategory: ChallengeCategory) {
        self.challengeCategory = challengeCategory
        if let category = realmService.getChallengeCategory(id: challengeCategory.id) {
            progress = category.progress
        } else {
            let category = ChallengeCategoryDataModel(id: challengeCategory.id, progress: 0)
            realmService.saveChallengeCategory(category)
        }
    }

    private func setupModal() {
        let modal = ChallengeFinishedModalView.instatiate()
        modal.homeCallback = { [weak self] in
            self?.updateProgress()
            self?.popToRootViewController(animated: true)
        }
        modal.listCallback = { [weak self] in
            self?.handleNavigateBack()
        }
        modal.nextCallback = { [weak self] in
            self?.handleNavigateBack()
            self?.showNextChallenge()
        }
        if currentChallenge + 1 == challengeCategory?.challenges.count {
            modal.isLastChallenge = true
        }
        presentModal(with: modal, closeHidden: true)
    }

    private func handleNavigateBack() {
        updateProgress()
        dismissModalViewController()
        navigationController?.popViewController(animated: false)
        challengesCollectionView.reloadData()
    }

    private func updateProgress() {
        if progress <= currentChallenge {
            progress = currentChallenge + 1
        }
        guard let challengeCategory = challengeCategory else {
            return
        }
        let category = ChallengeCategoryDataModel(id: challengeCategory.id, progress: progress)
        realmService.saveChallengeCategory(category)
    }

    private func showNextChallenge() {
        currentChallenge += 1
        guard let challenge = challengeCategory?.challenges[currentChallenge] else { return }
        let challengeDetailViewController =
            AppContainer.shared.container.unwrappedResolve(ChallengeDetailViewController.self)
        navigationController?.pushViewController(challengeDetailViewController, animated: true)
        challengeDetailViewController.setup(with: challenge, needsReload: true)
        challengeDetailViewController.challengeFinished = { [weak self] in
            self?.setupModal()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ChallengesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let challenge = challengeCategory?.challenges[indexPath.row], progress >= indexPath.row else { return }
        currentChallenge = indexPath.row
        let challengeDetailViewController =
            AppContainer.shared.container.unwrappedResolve(ChallengeDetailViewController.self)
        navigationController?.pushViewController(challengeDetailViewController, animated: true)
        challengeDetailViewController.setup(with: challenge)
        challengeDetailViewController.challengeFinished = { [weak self] in
            self?.setupModal()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ChallengesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let category = challengeCategory else { return 0 }
        return category.challenges.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row % 2 != 0 {
            let cell: ChallengesCollectionViewEvenCell =
                challengesCollectionView.dequeueReusableCell(forIndexPath: indexPath)
            if let category = challengeCategory {
                if progress == indexPath.row {
                    cell.progress = .available
                }
                if progress > indexPath.row {
                    cell.progress = .completed
                }
                cell.setup(with: category.challenges[indexPath.row],
                           index: indexPath.row + 1)
                cell.isFirstItem = indexPath.row == 0
            }
            return cell
        } else {
            let cell: ChallengesCollectionViewOddCell =
                challengesCollectionView.dequeueReusableCell(forIndexPath: indexPath)
            if let category = challengeCategory {
                if progress == indexPath.row {
                    cell.progress = .available
                }
                if progress > indexPath.row {
                    cell.progress = .completed
                }
                cell.setup(with: category.challenges[indexPath.row],
                           index: indexPath.row + 1)
                cell.isFirstItem = indexPath.row == 0
            }
            return cell
        }
    }
}

// MARK: - Bluetooth connection
extension ChallengesViewController {
    override func connected() {
        super.connected()
        navigationBar.bluetoothButtonState = .connected
    }

    override func disconnected() {
        super.disconnected()
        navigationBar.bluetoothButtonState = .notConnected
    }
}

//
//  BuildRobotViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 18..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

class BuildRobotViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var navigationBar: RRNavigationBar!
    @IBOutlet private weak var progressLabel: RRProgressLabel!
    @IBOutlet private weak var bluetoothButton: RRButton!
    @IBOutlet private weak var partStackView: UIStackView!
    @IBOutlet private weak var buildProgressBar: BuildProgressBar!
    @IBOutlet private weak var zoomableImageView: RRZoomableImageView!

    // MARK: - Properties
    var firebaseService: FirebaseServiceInterface!
    var realmService: RealmServiceInterface!
    var remoteRobotDataModel: Robot?
    var storedRobotDataModel: UserRobot?
    private var steps: [BuildStep] = [] {
        didSet {
            setupComponents()
        }
    }
    private var currentStep: BuildStep?
    private let partView = PartView.instatiate()
}

// MARK: - View lifecycle
extension BuildRobotViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setup(title: remoteRobotDataModel?.name, delegate: self)
        fetchBuildSteps()
        setupStackView()
    }
}

// MARK: - Setup
extension BuildRobotViewController {
    private func setupComponents() {
        setupProgressLabel()
        setupProgressBar()
    }

    private func setupProgressLabel() {
        progressLabel.currentStep = 1
        progressLabel.numberOfSteps = steps.count
    }

    private func setupProgressBar() {
        buildProgressBar.numberOfSteps = steps.count - 1
        buildProgressBar.markers = steps.filter({ $0.milestone != nil }).map({ steps.firstIndex(of: $0)! })
        buildProgressBar.valueDidChange = { [weak self] currentStepIndex in
            guard self?.currentStep != self?.steps[currentStepIndex] else { return }
            self?.currentStep = self?.steps[currentStepIndex]
            self?.progressLabel.currentStep = currentStepIndex + 1
            self?.zoomableImageView.imageView.downloadImage(googleStorageURL: self?.currentStep?.image)
            self?.setupPartsView()
            self?.updateStoredRobot(step: currentStepIndex)
        }
        buildProgressBar.buildFinished = { [weak self] in
            let buildFinishedModal = BuildFinishedModal.instatiate()
            buildFinishedModal.homeCallback = { [weak self] in
                self?.popToRootViewController(animated: true)
            }
            buildFinishedModal.driveCallback = { [weak self] in
                self?.dismissViewController()
                let driveMeScreen = AppContainer.shared.container.unwrappedResolve(DriveMeViewController.self)
                self?.navigationController?.pushViewController(driveMeScreen, animated: true)
            }
            self?.presentModal(with: buildFinishedModal)
        }
    }

    private func setupStackView() {
        partStackView.addArrangedSubview(partView)
        partStackView.setBorder(strokeColor: Color.brownishGrey,
                                showTopArrow: true,
                                croppedCorners: [.topRight, .bottomLeft])
        view.bringSubviewToFront(partStackView)
    }
}

// MARK: - Private methods
extension BuildRobotViewController {
    private func fetchBuildSteps() {
        firebaseService.getBuildSteps(for: remoteRobotDataModel?.id, completion: { [weak self] result in
            switch result {
            case .success(let steps):
                self?.steps = steps
                self?.currentStep = steps.first
                self?.zoomableImageView.imageView.downloadImage(googleStorageURL: steps.first?.image)
                self?.setupPartsView()
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }

    private func setupPartsView() {
        partView.setup(with: currentStep)
        partView.isLast = true
    }

    private func updateStoredRobot(step: Int) {
        realmService.updateObject { [weak self] in
            if let robot = self?.storedRobotDataModel {
                robot.actualBuildStep = step
                robot.lastModified = Date()
                robot.buildStatus = BuildStatus.inProgress.rawValue
            } else {
                self?.storedRobotDataModel = UserRobot(
                    id: "\(self?.remoteRobotDataModel!.id)",
                    buildStatus: .initial,
                    actualBuildStep: step,
                    lastModified: Date(),
                    configId: "\(self?.remoteRobotDataModel!.configurationId)",
                    customName: self?.remoteRobotDataModel?.name,
                    customImage: nil,
                    customDescription: nil)
            }
        }
    }
}

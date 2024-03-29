//
//  SensorViewController.swift
//  RevolutionRobotics
//
//  Created by Mate Papp on 2019. 04. 30..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import SideMenu
import os

final class SensorConfigViewController: BaseViewController {
    // MARK: - Constants
    private enum Constants {
        static let iPhoneSEScreenHeight: CGFloat = 320
        static let iPhoneSETopConstraintConstant: CGFloat = 8
    }

    // MARK: - Outlets
    @IBOutlet private weak var buttonContainer: UIStackView!
    @IBOutlet private weak var nameInputField: RRInputField!
    @IBOutlet private weak var testButton: RRButton!
    @IBOutlet private weak var doneButton: RRButton!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!

    // MARK: - Properties
    private let emptyButton = PortConfigurationItemView.instatiate()
    private let bumperButton = PortConfigurationItemView.instatiate()
    private let distanceButton = PortConfigurationItemView.instatiate()
    var selectedSensorType: SensorConfigViewModelType = .empty {
        didSet {
            if isViewLoaded {
                handleSelectionChange()
                validateActionButtons()
            }
        }
    }
    var portNumber = 0
    var bumperSensorCounts: Int!
    var distanceSensorCounts: Int!
    var name: String? {
        didSet {
            guard let name = name else { return }

            switch selectedSensorType {
            case .bumper:
                customBumperName = name
            case .distance:
                customDistanceName = name
            case .empty:
                customDistanceName = ""
                customBumperName = ""
            }
        }
    }
    var prohibitedNames: [String] = []
    var doneButtonTapped: CallbackType<SensorConfigViewModel>?
    var testButtonTapped: CallbackType<SensorConfigViewModel>?
    var screenDismissed: Callback?
    var testCodeService: PortTestCodeServiceInterface!
    private var customBumperName = ""
    private var customDistanceName = ""
    private var shouldCallDismiss = true
    private var shouldRunTestScriptOnConnection = false

    private var sensorPortNumber: Int {
        return portNumber - 6
    }

    private var nameInputFieldText: String? {
        switch selectedSensorType {
        case .bumper:
            if customBumperName.isEmpty {
                let bumperCountString = bumperSensorCounts == 0 ? "" : "\(bumperSensorCounts + 1)"
                return selectedSensorType.rawValue + bumperCountString
            } else {
                return customBumperName
            }
        case .distance:
            if customDistanceName.isEmpty {
                let distanceCountString = distanceSensorCounts == 0 ? "" : "\(distanceSensorCounts + 1)"
                return selectedSensorType.rawValue + distanceCountString
            } else {
                return customDistanceName
            }
        default:
            return nil
        }
    }
}

// MARK: - View lifecycle
extension SensorConfigViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtonRow()
        setupNameInputField()
        handleSelectionChange()
        validateActionButtons()
        nameInputField.text = name

        if UIScreen.main.bounds.size.height == Constants.iPhoneSEScreenHeight {
            topConstraint.constant = Constants.iPhoneSETopConstraintConstant
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupActionButtons()
    }
}

// MARK: - Setup
extension SensorConfigViewController {
    private func setupNameInputField() {
        nameInputField.setup(title: RobotsKeys.Configure.Motor.nameInputfield.translate(args: "S\(sensorPortNumber)"))
        nameInputField.textFieldResigned = { [weak self] _ in
            self?.validateActionButtons()
        }
    }

    private func setupButtonRow() {
        emptyButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Motor.emptyButton.translate(),
            selectedImage: Image.Configure.emptySelected,
            unselectedImage: Image.Configure.emptyUnselected) { [weak self] in
                self?.selectedSensorType = .empty
            }
        )
        buttonContainer.addArrangedSubview(emptyButton)

        bumperButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Sensor.bumperButton.translate(),
            selectedImage: Image.Configure.bumperSelected,
            unselectedImage: Image.Configure.bumperUnselected) { [weak self] in
                self?.selectedSensorType = .bumper
            }
        )
        buttonContainer.addArrangedSubview(bumperButton)

        distanceButton.configure(options: PortConfigurationItemView.Options(
            title: RobotsKeys.Configure.Sensor.distanceButton.translate(),
            selectedImage: Image.Configure.distanceSelected,
            unselectedImage: Image.Configure.distanceUnselected) { [weak self] in
                self?.selectedSensorType = .distance
            }
        )
        buttonContainer.addArrangedSubview(distanceButton)
    }

    private func setupActionButtons() {
        testButton.setBorder(fillColor: .clear, croppedCorners: [.bottomLeft])
        doneButton.setBorder(fillColor: .clear, strokeColor: .white, croppedCorners: [.topRight])
    }
}

// MARK: - Event handling
extension SensorConfigViewController {
    private func handleSelectionChange() {
        let typeIsEmpty = selectedSensorType == .empty

        nameInputField.isUserInteractionEnabled = !typeIsEmpty
        nameInputField.layer.opacity = typeIsEmpty ? 0.5 : 1.0
        nameInputField.text = nameInputFieldText

        emptyButton.set(selected: typeIsEmpty)
        bumperButton.set(selected: selectedSensorType == .bumper)
        distanceButton.set(selected: selectedSensorType == .distance)
    }

    private func validateActionButtons() {
        testButton.isEnabled = selectedSensorType != .empty
        guard let name = nameInputField.text else {
            doneButton.isEnabled = selectedSensorType == .empty
            return
        }

        doneButton.isEnabled = (selectedSensorType != .empty && !name.isEmpty) || selectedSensorType == .empty
    }

    private func presentTestingModal() {
        let modal = TestingModalView.instatiate()
        switch selectedSensorType {
        case .bumper:
            modal.setup(with: .bumper)
        case .distance:
            modal.setup(with: .distance)
        default: break
        }
        modal.positiveButtonTapped = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        modal.negativeButtonTapped = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            self?.presentTipsModal()
        }
        presentModal(with: modal)
    }

    private func presentTipsModal() {
        let tips = TipsModalView.instatiate()
        tips.title = ModalKeys.Tips.title.translate()
        tips.subtitle = ModalKeys.Tips.subtitle.translate()
        tips.tips = ModalKeys.Tips.tips.translate()
        tips.skipTitle = ModalKeys.Tips.reconfigure.translate()
        tips.communityTitle = ModalKeys.Tips.community.translate()
        tips.tryAgainTitle = ModalKeys.Tips.tryAgin.translate()
        tips.skipIcon = Image.Configure.reconfigure

        tips.communityCallback = { [weak self] in
            self?.openSafari(presentationFinished: nil)
        }
        tips.skipCallback = { [weak self] in
            self?.dismissModalViewController()
        }
        tips.tryAgainCallback = { [weak self] in
            self?.dismissModalViewController()
            self?.presentTestingModal()
            self?.startPortTest()
        }
        presentModal(with: tips)
    }

    private func startPortTest() {
        let isBumperType = selectedSensorType == .bumper
        let testCode = isBumperType ?
            testCodeService.bumperTestCode(for: sensorPortNumber) :
            testCodeService.distanceTestCode(for: sensorPortNumber)

        bluetoothService.testKit(data: testCode, onCompleted: nil)
    }
}

// MARK: - Actions
extension SensorConfigViewController {
    @IBAction private func testButtonTapped(_ sender: Any) {
        if bluetoothService.connectedDevice != nil {
            startPortTest()
            presentTestingModal()
        } else {
            shouldRunTestScriptOnConnection = true
            presentConnectModal()
        }
    }

    @IBAction private func doneButtonTapped(_ sender: Any) {
        guard selectedSensorType != .empty else {
            shouldCallDismiss = false
            doneButtonTapped?(SensorConfigViewModel(portName: nameInputField.text, type: selectedSensorType))
            return
        }
        guard let name = nameInputField.text, !name.isEmpty else {
            return
        }
        guard !prohibitedNames.contains(name) else {
            let alert = UIAlertController.errorAlert(type: .variableNameAlreadyInUse)
            present(alert, animated: true, completion: nil)
            return
        }
        shouldCallDismiss = false
        doneButtonTapped?(SensorConfigViewModel(portName: nameInputField.text, type: selectedSensorType))
    }
}

// MARK: - UISideMenuNavigationControllerDelegate
extension SensorConfigViewController: UISideMenuNavigationControllerDelegate {
    func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        if shouldCallDismiss {
            screenDismissed?()
        }
    }
}

// MARK: - Bluetooth connection
extension SensorConfigViewController {
    override func connected() {
        bluetoothService.stopDiscovery()
        dismiss(animated: true, completion: {
            self.presentConnectedModal(onCompleted: { [weak self] in
                guard let runTest = self?.shouldRunTestScriptOnConnection, runTest else { return }

                self?.shouldRunTestScriptOnConnection = false
                self?.startPortTest()
                self?.presentTestingModal()
            })
        })
    }

    private func presentConnectedModal(onCompleted callback: Callback?) {
        let connectionModal = ConnectionModalView.instatiate()
        presentModal(with: connectionModal.successful, closeHidden: true)

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.presentedViewController?.dismiss(animated: true, completion: {
                callback?()
            })
        }
    }
}

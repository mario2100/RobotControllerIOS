//
//  BluetoothConnectionModalPresenter.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 17..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import struct RevolutionRoboticsBluetooth.Device
import UIKit

final class BluetoothConnectionModalPresenter {
    // MARK: - Properties
    let availableRobotsView = AvailableRobotsView.instatiate()
    var discoveredDevices: [Device] = [] {
        didSet {
            availableRobotsView.discoveredDevices = discoveredDevices
        }
    }
    var shouldHideSkip = false
    private weak var presenter: BaseViewController!
    private var startDiscoveryHandler: Callback?
    private var deviceSelectionHandler: CallbackType<Device>?
    private var dismissHandler: Callback?
    private var isBluetoothPoweredOn: Bool = false
}

// MARK: - Public methods
extension BluetoothConnectionModalPresenter {
    func present(on viewController: BaseViewController,
                 isBluetoothPoweredOn: Bool,
                 startDiscoveryHandler: Callback?,
                 deviceSelectionHandler: CallbackType<Device>?,
                 onDismissed: Callback?) {
        self.presenter = viewController
        self.isBluetoothPoweredOn = isBluetoothPoweredOn
        self.startDiscoveryHandler = startDiscoveryHandler
        self.dismissHandler = onDismissed
        self.deviceSelectionHandler = deviceSelectionHandler

        showTurnOnTheBrain()
    }
}

// MARK: - Private methods
extension BluetoothConnectionModalPresenter {
    private func showTurnOnTheBrain() {
        let turnOnModal = TurnOnBrainView.instatiate()
        turnOnModal.setup()
        setupHandlers(on: turnOnModal)
        presenter.presentModal(with: turnOnModal)
    }

    private func setupHandlers(on modal: TurnOnBrainView) {
        setupLaterHandler(on: modal)
        setupTipsHandler(on: modal)
        setupStartDiscoveryHandler(on: modal)
    }

    private func setupLaterHandler(on modal: TurnOnBrainView) {
        modal.laterHandler = { [weak self] in
            self?.presenter.dismiss(animated: true, completion: nil)
        }
    }

    private func setupTipsHandler(on modal: TurnOnBrainView) {
        modal.tipsHandler = { [weak self] in
            self?.showTipsModal()
        }
    }

    private func showTipsModal() {
        presenter.dismiss(animated: true, completion: nil)
        let tips = TipsModalView.instatiate()
        tips.isSkipButtonHidden = shouldHideSkip
        tips.title = ModalKeys.Tips.title.translate()
        tips.subtitle = ModalKeys.Tips.subtitle.translate()
        tips.tips = "Lorem ipsum dolor sit amet, eu commodo numquam comprehensam vel. Quo cu alia placerat."
        tips.skipTitle = ModalKeys.Connection.failedConnectionSkipButton.translate()
        tips.communityTitle = ModalKeys.Tips.community.translate()
        tips.tryAgainTitle = ModalKeys.Tips.tryAgin.translate()
        tips.skipCallback = { [weak self] in
            self?.presenter.dismissModalViewController()
        }
        tips.tryAgainCallback = { [weak self] in
            self?.presenter.dismiss(animated: true, completion: nil)
            self?.showTurnOnTheBrain()
        }
        tips.communityCallback = { [weak self] in
            self?.presenter.openSafari(presentationFinished: {
                self?.showTurnOnTheBrain()
            })
        }
        presenter.presentModal(with: tips)
    }

    private func setupStartDiscoveryHandler(on modal: TurnOnBrainView) {
        modal.startHandler = { [weak self] in
            self?.presenter.dismiss(animated: true, completion: nil)
            self?.showBluetoothDiscovery()
        }
    }

    private func showBluetoothDiscovery() {
        if isBluetoothPoweredOn {
            availableRobotsView.selectionHandler = deviceSelectionHandler
            presenter.presentModal(with: availableRobotsView, onDismissed: { [weak self] in
                self?.dismissHandler?()
            })
            startDiscoveryHandler?()
        } else {
            presenter.present(UIAlertController.errorAlert(type: .bluetooth), animated: true)
        }
    }
}

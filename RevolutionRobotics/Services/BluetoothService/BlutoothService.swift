//
//  BlutoothService.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 05. 17..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import RevolutionRoboticsBluetooth
import CoreBluetooth

final class BluetoothService: BluetoothServiceInterface {
    // MARK: - Properties
    var connectedDevice: Device?
    var isBluetoothPoweredOn: Bool {
        return discoverer.bluetoothRadioState == .poweredOn
    }
    private var mostRecentlyConnectedDevice: Device?
    private var shouldReconnect = false

    private let discoverer: RoboticsDeviceDiscovererInterface = RoboticsDeviceDiscoverer()
    private let connector: RoboticsDeviceConnectorInterface = RoboticsDeviceConnector()
    private let deviceInfo: RoboticsDeviceServiceInterface = RoboticsDeviceService()
    private let batteryInfo: RoboticsBatteryServiceInterface = RoboticsBatteryService()
    private let liveController: RoboticsLiveControllerServiceInterface = RoboticsLiveControllerService()
    private let configuration: RoboticsConfigurationServiceInterface = RoboticsConfigurationService()

    // MARK: - Discovery
    func startDiscovery(onScanResult: CallbackType<Result<[Device], Error>>?) {
        discoverer.discoverRobots(onScanResult: { onScanResult?(.success($0)) },
                                  onError: { onScanResult?(.failure($0)) })
    }

    func stopDiscovery() {
        discoverer.stopDiscover()
    }

    // MARK: - Connection
    func connect(to device: Device) {
        connector.connect(
            to: device,
            onConnected: { [weak self] in
                NotificationCenter.default.post(name: .robotConnected, object: nil)
                self?.connectedDevice = device
                self?.mostRecentlyConnectedDevice = device
            },
            onDisconnected: { [weak self] in
                NotificationCenter.default.post(name: .robotDisconnected, object: nil)
                self?.connectedDevice = nil
            },
            onError: { error in
                NotificationCenter.default.post(name: .robotConnectionError, object: error)
        })
    }

    func reconnect() {
        guard let mostRecentlyConnectedDevice = mostRecentlyConnectedDevice, shouldReconnect else { return }
        connect(to: mostRecentlyConnectedDevice)
    }

    func disconnect(shouldReconnect: Bool) {
        guard connectedDevice != nil else { return }
        connector.disconnect()
        self.shouldReconnect = shouldReconnect
    }

    func sendConfigurationData(_ data: Data, onCompleted: CallbackType<Result<String, Error>>?) {
        configuration.sendConfiguration(
            with: data,
            onSuccess: {
                onCompleted?(.success("Success"))
        },
            onError: { error in
                onCompleted?(.failure(error))
        })
    }

    // MARK: - Device info
    func getPrimaryBatteryPercentage(onCompleted: CallbackType<Result<Int, Error>>?) {
        batteryInfo.getPrimaryBatteryPercentage(onComplete: { onCompleted?(.success($0)) },
                                                onError: { onCompleted?(.failure($0)) })
    }

    func getMotorBatteryPercentage(onCompleted: CallbackType<Result<Int, Error>>?) {
        batteryInfo.getMotorBatteryPercentage(onComplete: { onCompleted?(.success($0)) },
                                              onError: { onCompleted?(.failure($0)) })
    }

    func getSerialNumber(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getSerialNumber(onCompleted: { onCompleted?(.success($0)) },
                                   onError: { onCompleted?(.failure($0)) })
    }

    func getManufacturerName(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getManufacturerName(onCompleted: { onCompleted?(.success($0)) },
                                       onError: { onCompleted?(.failure($0)) })
    }

    func getHardwareRevision(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getHardwareRevision(onCompleted: { onCompleted?(.success($0)) },
                                       onError: { onCompleted?(.failure($0)) })
    }

    func getSoftwareRevision(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getSoftwareRevision(onCompleted: { onCompleted?(.success($0)) },
                                       onError: { onCompleted?(.failure($0)) })
    }

    func getFirmwareRevision(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getFirmwareRevision(onCompleted: { onCompleted?(.success($0)) },
                                       onError: { onCompleted?(.failure($0)) })
    }

    func getSystemId(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getSystemId(onCompleted: { onCompleted?(.success($0)) },
                               onError: { onCompleted?(.failure($0)) })
    }

    func getModelNumber(onCompleted: CallbackType<Result<String, Error>>?) {
        deviceInfo.getModelNumber(onCompleted: { onCompleted?(.success($0)) },
                                  onError: { onCompleted?(.failure($0)) })
    }

    func updateFramework(data: Data, version: String, onCompleted: CallbackType<Result<String, Error>>?) {
        configuration.updateFramework(with: data,
                                      onSuccess: { onCompleted?(.success("Success")) },
                                      onError: { error in
                                        onCompleted?(.failure(error))
        })
    }

    func stopWrite() {
        configuration.stopWrite()
    }

    // MARK: - Live controller
    func startKeepalive() {
        liveController.start()
    }

    func stopKeepalive() {
        liveController.stop()
    }

    func updateXDirection(_ xDirection: Int) {
        liveController.updateXDirection(x: xDirection)
    }

    func updateYDirection(_ yDirection: Int) {
        liveController.updateYDirection(y: yDirection)
    }

    func changeButtonState(index: Int) {
        liveController.changeButtonState(index: index, pressed: true)
    }

    func testKit(data: String, onCompleted: CallbackType<Result<String, Error>>?) {
        configuration.testKit(
            with: data.data(using: .utf8)!,
            onSuccess: {
                onCompleted?(.success("Success"))
        },
            onError: { error in
                onCompleted?(.failure(error))
        })
    }
}

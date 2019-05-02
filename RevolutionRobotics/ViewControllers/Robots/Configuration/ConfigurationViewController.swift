//
//  ConfigurationViewController.swift
//  RevolutionRobotics
//
//  Created by Csaba Vidó on 2019. 04. 29..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ConfigurationViewController: BaseViewController {
    @IBOutlet private weak var segmentedControl: SegmentedControl!
    // MARK: - Motor Port 1
    @IBOutlet private weak var motorPort1: PortButton!
    @IBOutlet private var motorPort1Lines: [DashedView]!
    @IBOutlet private weak var motorPort1Dot: UIImageView!

    // MARK: - Motor Port 2
    @IBOutlet private weak var motorPort2: PortButton!
    @IBOutlet private var motorPort2Lines: [DashedView]!
    @IBOutlet private weak var motorPort2Dot: UIImageView!

    // MARK: - Motor Port 3
    @IBOutlet private weak var motorPort3: PortButton!
    @IBOutlet private var motorPort3Lines: [DashedView]!
    @IBOutlet private weak var motorPort3Dot: UIImageView!

    // MARK: - Motor Port 4
    @IBOutlet private weak var motorPort4: PortButton!
    @IBOutlet private var motorPort4Lines: [DashedView]!
    @IBOutlet private weak var motorPort4Dot: UIImageView!

    // MARK: - Motor Port 5
    @IBOutlet private weak var motorPort5: PortButton!
    @IBOutlet private var motorPort5Lines: [DashedView]!
    @IBOutlet private weak var motorPort5Dot: UIImageView!

    // MARK: - Motor Port 6
    @IBOutlet private weak var motorPort6: PortButton!
    @IBOutlet private var motorPort6Lines: [DashedView]!
    @IBOutlet private weak var motorPort6Dot: UIImageView!

    // MARK: - Sensor Port 1
    @IBOutlet private weak var sensorPort1: PortButton!
    @IBOutlet private var sensorPort1Lines: [DashedView]!
    @IBOutlet private weak var sensorPort1Dot: UIImageView!

    // MARK: - Sensor Port 2
    @IBOutlet private weak var sensorPort2: PortButton!
    @IBOutlet private var sensorPort2Lines: [DashedView]!
    @IBOutlet private weak var sensorPort2Dot: UIImageView!

    // MARK: - Sensor Port 3
    @IBOutlet private weak var sensorPort3: PortButton!
    @IBOutlet private var sensorPort3Lines: [DashedView]!
    @IBOutlet private weak var sensorPort3Dot: UIImageView!

    // MARK: - Sensor Port 4
    @IBOutlet private weak var sensorPort4: PortButton!
    @IBOutlet private var sensorPort4Lines: [DashedView]!
    @IBOutlet private weak var sensorPort4Dot: UIImageView!
}

// MARK: - Life Cycle
extension ConfigurationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSegmentedControl()

        connectMotorPorts()
        connectSensorPorts()
    }
}

// MARK: - Setups
extension ConfigurationViewController {
    private func connectMotorPorts() {
        motorPort1.lines = motorPort1Lines
        motorPort1.dotImageView = motorPort1Dot

        motorPort2.lines = motorPort2Lines
        motorPort2.dotImageView = motorPort2Dot

        motorPort3.lines = motorPort3Lines
        motorPort3.dotImageView = motorPort3Dot

        motorPort4.lines = motorPort4Lines
        motorPort4.dotImageView = motorPort4Dot

        motorPort5.lines = motorPort5Lines
        motorPort5.dotImageView = motorPort5Dot

        motorPort6.lines = motorPort6Lines
        motorPort6.dotImageView = motorPort6Dot
    }

    private func connectSensorPorts() {
        sensorPort1.lines = sensorPort1Lines
        sensorPort1.dotImageView = sensorPort1Dot

        sensorPort2.lines = sensorPort2Lines
        sensorPort2.dotImageView = sensorPort2Dot

        sensorPort3.lines = sensorPort3Lines
        sensorPort3.dotImageView = sensorPort3Dot

        sensorPort4.lines = sensorPort4Lines
        sensorPort4.dotImageView = sensorPort4Dot
    }

    private func setupSegmentedControl() {
        segmentedControl.setup(with: ["Connections", "Controllers"])
        segmentedControl.setSelectedIndex(0)
        segmentedControl.itemSelectedAt = {
            print($0)
        }
    }
}

// MARK: - Actions
extension ConfigurationViewController {
    @IBAction private func portTapped(_ sender: PortButton) {
        print(sender.portType)
        print(sender.portNumber)
    }

    @IBAction private func takePhotoTapped(_ sender: Any) {

    }

    @IBAction private func saveTapped(_ sender: Any) {

    }

    @IBAction private func bluetoothTapped(_ sender: Any) {

    }
}

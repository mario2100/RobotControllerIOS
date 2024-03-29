//
//  ProgramListModalView.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 06. 17..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit

final class ProgramListModalView: UIView {
    // MARK: - Constants
    enum Constants {
        static let shadowHeight: CGFloat = 70
    }

    // MARK: - Outlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var programsTableView: UITableView!

    // MARK: - Variables
    var selectedProgramCallback: CallbackType<ProgramDataModel>?
    private var programs: [ProgramDataModel] = [] {
        didSet {
            programsTableView.reloadData()
        }
    }
}

// MARK: - View lifecycle
extension ProgramListModalView {
    override func awakeFromNib() {
        super.awakeFromNib()

        programsTableView.delegate = self
        programsTableView.dataSource = self
        programsTableView.register(ProgramSelectorTableViewCell.self)
        titleLabel.text = ProgramsKeys.Main.title.translate().uppercased()
        addShadow()
    }
}

// MARK: - Setup
extension ProgramListModalView {
    func setup(with programs: [ProgramDataModel]) {
        let asd = programs.sorted(by: { $0.lastModified > $1.lastModified })
        self.programs = asd
    }
}

// MARK: - Private functions
extension ProgramListModalView {
    private func addShadow() {
        let shadowLayer = CAGradientLayer()
        shadowLayer.frame = CGRect(x: 0,
                                   y: frame.height - Constants.shadowHeight,
                                   width: frame.width,
                                   height: Constants.shadowHeight)
        shadowLayer.colors = [Color.blackTwo.cgColor, UIColor.clear.cgColor]
        shadowLayer.startPoint = CGPoint(x: 0, y: 1)
        shadowLayer.endPoint = CGPoint(x: 0, y: 0)
        self.layer.addSublayer(shadowLayer)
    }
}

// MARK: - UITableViewDataSource
extension ProgramListModalView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return programs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProgramSelectorTableViewCell = programsTableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(program: programs[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ProgramListModalView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProgramCallback?(programs[indexPath.row])
    }
}

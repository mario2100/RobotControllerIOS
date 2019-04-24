//
//  Robot.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 04. 11..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct Robot: FirebaseData {
    // MARK: - Constants
    private enum Constants {
        static let id = "id"
        static let name = "name"
        static let description = "description"
        static let coverImage = "coverImage"
        static let buildTime = "buildTime"
        static let configurationId = "configurationId"
        static let defaultProgram = "defaultProgram"
    }

    // MARK: - Path
    static var firebasePath: String = "robot"

    // MARK: - Properties
    var id: Int
    var name: String
    var description: String
    var coverImageGSURL: String
    var buildTime: String
    var configurationId: Int
    var defaultProgram: String

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dic = snapshot.value as? NSDictionary else {
            return nil
        }

        guard let id = dic[Constants.id] as? Int,
            let name = dic[Constants.name] as? String,
            let description = dic[Constants.description] as? String,
            let coverImage = dic[Constants.coverImage] as? String,
            let buildTime = dic[Constants.buildTime] as? String,
            let configurationId = dic[Constants.configurationId] as? Int,
            let defaultProgram = dic[Constants.defaultProgram] as? String else {
                return nil
        }

        self.id = id
        self.name = name
        self.description = description
        self.coverImageGSURL = coverImage
        self.buildTime = buildTime
        self.configurationId = configurationId
        self.defaultProgram = defaultProgram
    }
}

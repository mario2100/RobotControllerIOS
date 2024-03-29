//
//  ChallengeStep.swift
//  RevolutionRobotics
//
//  Created by Robert Klacso on 2019. 05. 15..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import Foundation
import Firebase

struct ChallengeStep: FirebaseData, FirebaseOrderable {
    // MARK: - Constants
    private enum Constants {
        static let id = "id"
        static let title = "title"
        static let description = "description"
        static let image = "image"
        static let parts = "parts"
        static let order = "order"
        static let challengeType = "challengeType"
    }

    // MARK: - Path
    static var firebasePath: String = ""

    // MARK: - Properties
    var id: String
    var title: LocalizedText
    var description: LocalizedText
    var image: String
    var order: Int
    var parts: [Part]
    var challengeType: ChallengeType

    // MARK: - Initialization
    init?(snapshot: DataSnapshot) {
        guard let dictionary = snapshot.value as? NSDictionary,
            let id = dictionary[Constants.id] as? String,
            let order = dictionary[Constants.order] as? Int,
            let image = dictionary[Constants.image] as? String,
            let typeString = dictionary[Constants.challengeType] as? String,
            let challengeType = ChallengeType(rawValue: typeString) else {
                return nil
        }

        self.id = id
        self.title = LocalizedText(snapshot: snapshot.childSnapshot(forPath: Constants.title))!
        self.description = LocalizedText(snapshot: snapshot.childSnapshot(forPath: Constants.description))!
        self.image = image
        self.order = order
        self.challengeType = challengeType

        let parts = snapshot.childSnapshot(forPath: Constants.parts)
            .children.compactMap { $0 as? DataSnapshot }
            .map { (snapshot) -> Part in
                return Part(snapshot: snapshot)!
            }
            .sorted(by: { $0.order < $1.order })
        self.parts = parts
    }
}

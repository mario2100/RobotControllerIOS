//
//  RobotsKeys.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 24..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

enum RobotsKeys {
    enum YourRobots {
        static let title = "your_robots_screen_title"
        static let buildNewButtonTitle = "your_robots_build_new_button_title"
        static let play = "your_robots_play"
        static let continueBuilding = "your_robots_continue_building"
        static let underConstruction = "your_robots_under_construction"
    }

    enum WhoToBuild {
        static let title = "who_to_build_screen_title"
        static let buildNewButtonTitle = "who_to_build_build_new_button_title"
        static let searchingForRobotsTitle = "who_to_build_searching_title"
    }

    enum BuildRobot {
        static let testingTitle = "build_robot_testing_title"
        static let testingQuestion = "build_robot_testing_question"
        static let testingNegativeButtonTitle = "build_robot_testing_negative_button_title"
        static let testingPositiveButtonTitle = "build_robot_testing_positive_button_title"
        static let turnOnTheBrainInstruction = "build_robot_turn_on_the_brain_instruction"
        static let turnOnTheBrainTip = "build_robot_turn_on_the_brain_tip"

        enum ChapterFinished {
            static let title = "build_chapter_finish_dialog_title"
            static let description = "build_chapter_finish_dialog_description"
            static let homeButton = "build_chapter_finish_dialog_button_home"
            static let testLaterButton = "build_chapter_finish_dialog_button_next_chapter"
            static let testNowButton = "build_chapter_finish_dialog_button_test"
        }

        static let buildFinishedHome = "build_robot_finished_home"
        static let buildFinishedDrive = "build_robot_finished_drive"
        static let buildFinishedAllSet = "build_robot_finished_all_set"
        static let buildFinishedMessage = "build_robot_finished_message"
    }

    enum Configure {
        static let title = "configuration_new_screen_title"
        static let connectionTabTitle = "configure_connection_tab_title"
        static let controllerTabTitle = "configure_controller_tab_title"

        enum Motor {
            static let emptyButton = "configure_motor_empty_button_title"
            static let drivetrainButton = "configure_motor_drivetrain_button_title"
            static let motorButton = "configure_motor_motor_button_title"
            static let leftButton = "configure_motor_left_button_title"
            static let rightButton = "configure_motor_right_button_title"
            static let clockwiseButton = "configure_motor_clockwise_button_title"
            static let counterclockwiseButton = "configure_motor_counterclockwise_button_title"
            static let nameInputfield = "configure_motor_name_inputfield_title"
            static let testButton = "configure_motor_test_button_title"
            static let doneButton = "configure_motor_done_button_title"
        }

        enum Sensor {
            static let bumperButton = "configure_sensor_bumper_button_title"
            static let ultrasoundButton = "configure_sensor_ultrasound_button_title"
        }
    }

    enum Controllers {
        static let controllerChooseThis = "controller_choose_this"
        static let controllerSelected = "controller_selected"

        enum Play {
            static let screenTitle = "play_controller_screen_title"
        }
    }
}

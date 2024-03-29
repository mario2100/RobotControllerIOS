//
//  ProgramsViewController.swift
//  RevolutionRobotics
//
//  Created by Gabor Nagy Farkas on 2019. 04. 16..
//  Copyright © 2019. Revolution Robotics. All rights reserved.
//

import UIKit
import RevolutionRoboticsBlockly

final class ProgramsViewController: BaseViewController {
    private enum ProgramSaveReason {
        case edited
        case navigateBack
        case openProgram
        case showCode
    }

    // MARK: - Constants
    private enum Constants {
        static let defaultXMLCode = "<xml xmlns=\"http://www.w3.org/1999/xhtml\"></xml>"
        static let blocklyElementIdRegex = "id=\"[^\"]*\""
    }

    // MARK: - Outlets
    @IBOutlet private weak var programNameButton: RRButton!
    @IBOutlet private weak var programCodeButton: RRButton!
    @IBOutlet private weak var saveProgramButton: RRButton!
    @IBOutlet private weak var openProgramButton: RRButton!
    @IBOutlet private weak var containerView: UIView!

    // MARK: - Properties
    var realmService: RealmServiceInterface!
    var programCompatibilityValidator: ProgramCompatibilityValidator!
    var selectedProgram: ProgramDataModel?
    var shouldDismissAfterSave = false
    private let blocklyViewController = BlocklyViewController()
    private var programSaveReason = ProgramSaveReason.edited {
        didSet {
            blocklyViewController.saveProgram()
        }
    }

    var isPythonExported = false
    var isXMLExported = false
}

// MARK: - View lifecycle
extension ProgramsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        programCompatibilityValidator = ProgramCompatibilityValidator(realmService: realmService)
        setupBlocklyViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if selectedProgram != nil {
            prefillProgram()
        }

        setupButtons()
    }
}

// MARK: - Setup
extension ProgramsViewController {
    private func setupBlocklyViewController() {
        blocklyViewController.setup(blocklyBridgeDelegate: self)

        containerView.addSubview(blocklyViewController.view)
        blocklyViewController.view.anchorToSuperview()
        addChild(blocklyViewController)
        blocklyViewController.didMove(toParent: self)
    }

    private func setupButtons() {
        programNameButton.setBorder(fillColor: .clear)
        programCodeButton.setBorder(fillColor: .clear)
        saveProgramButton.setBorder(fillColor: .clear)
        openProgramButton.setBorder(fillColor: .clear)
    }

    private func prefillProgram() {
        guard let program = selectedProgram else { return }
        programNameButton.setTitle(program.name, for: .normal)
    }
}

// MARK: - Private functions
extension ProgramsViewController {
    private func saveProgram() {
        guard let program = selectedProgram else {
            return
        }

        if let programDataModel = realmService.getProgram(id: program.id) {
            realmService.updateObject {
                programDataModel.variableNames = program.variableNames
                programDataModel.lastModified = Date()
                programDataModel.customDescription = program.customDescription
                programDataModel.xml = program.xml
                programDataModel.python = program.python
            }
        } else {
            realmService.savePrograms(programs: [program])
        }

        prefillProgram()
        setupButtons()
    }

    private func save(description: String) {
        guard let program = selectedProgram else { return }

        if let programDataModel = realmService.getProgram(id: program.id) {
            realmService.updateObject {
                programDataModel.customDescription = description
            }
        } else {
            program.customDescription = description
            saveProgram()
        }
    }

    private func open(program: ProgramDataModel) {
        let descriptionModal = ProgramDescriptionModalView.instatiate()
        descriptionModal.setup(with: program)
        descriptionModal.loadCallback = { [weak self] in
            self?.dismissModalViewController()
            self?.selectedProgram = program
            self?.blocklyViewController.loadProgram(xml: program.xml.base64Decoded ?? "")
            self?.prefillProgram()
            self?.setupButtons()
        }
        descriptionModal.deleteCallback = { [weak self] in
            self?.dismissModalViewController()
            self?.realmService.deleteProgram(program)
        }
        presentModal(with: descriptionModal)
    }

    private func confirmLeave() {
        let confirmModal = ConfirmModalView.instatiate()

        switch programSaveReason {
        case .navigateBack:
            confirmModal.setup(title: ProgramsKeys.NavigateBack.title.translate(),
                               subtitle: nil,
                               negativeButtonTitle: ProgramsKeys.NavigateBack.programLeaveConfirmNegative.translate(),
                               positiveButtonTitle: ProgramsKeys.NavigateBack.programLeaveConfirmPositive.translate())

            confirmModal.confirmSelected = { [weak self] confirmed in
                self?.dismissModalViewController()
                if confirmed {
                    self?.initiateSave(shouldNavigateBack: true, shouldOpenPrograms: false)
                } else {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        case .openProgram:
            confirmModal.setup(title: ProgramsKeys.ConfirmOpen.title.translate(),
                               subtitle: nil,
                               negativeButtonTitle: ProgramsKeys.NavigateBack.programLeaveConfirmNegative.translate(),
                               positiveButtonTitle: ProgramsKeys.NavigateBack.programOpenConfirmPositive.translate())
            confirmModal.confirmSelected = { [weak self] confirmed in
                self?.dismissModalViewController()
                if confirmed {
                    self?.initiateSave(shouldNavigateBack: false, shouldOpenPrograms: true)
                } else {
                    self?.openProgramModal()
                }
            }
        default:
            return
        }

        presentModal(with: confirmModal)
    }

    private func openProgramModal() {
        let programsView = ProgramListModalView.instatiate()
        programsView.setup(with: realmService.getPrograms())
        programsView.selectedProgramCallback = { [weak self] program in
            self?.dismissModalViewController()
            self?.open(program: program)
        }
        presentModal(with: programsView)
    }
}

// MARK: - BlocklyBridgeDelegate
extension ProgramsViewController: BlocklyBridgeDelegate {
    func alert(message: String, callback: (() -> Void)?) {
        let alertView = AlertModalView.instatiate()

        alertView.setup(message: message) { [weak self] in
            callback?()
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: alertView, onDismissed: { callback?() })
    }

    func confirm(message: String, callback: ((Bool) -> Void)?) {
        let confirmView = ConfirmModalView.instatiate()

        confirmView.setup(title: message)
        confirmView.confirmSelected = { [weak self] confirmed in
            callback?(confirmed)
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: confirmView, onDismissed: { callback?(false) })
    }

    func optionSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let optionSelectorView = OptionSelectorModalView.instatiate()

        optionSelectorView.setup(optionSelector: optionSelector) { [weak self] option in
            callback?(option.key)
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: optionSelectorView, onDismissed: { callback?(nil) })
    }

    func driveDirectionSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let driveDirectionSelectorView = DriveDirectionSelectorModalView.instatiate()

        driveDirectionSelectorView.setup(optionSelector: optionSelector) { [weak self] option in
            callback?(option.key)
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: driveDirectionSelectorView, onDismissed: { callback?(nil) })
    }

    func sliderHandler(_ sliderHandler: SliderHandler, callback: ((String?) -> Void)?) {
        let sliderInputView = SliderInputModalView.instatiate()

        sliderInputView.setup(sliderHandler: sliderHandler) { [weak self] value in
            callback?(value)
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: sliderInputView, onDismissed: { callback?(nil) })
    }

    func singleLEDInput(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        let ledSelectorView = LEDSelectorModalView.instatiate()
        let defaultValues = Set([inputHandler.defaultInput])

        ledSelectorView.setup(selectionType: .single, defaultValues: defaultValues) { [weak self] led in
            callback?(led)
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: ledSelectorView, onDismissed: { callback?(nil) })
    }

    func multiLEDInput(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        let ledSelectorView = LEDSelectorModalView.instatiate()
        let defaultValues = Set(inputHandler.defaultInput.components(separatedBy: ","))

        ledSelectorView.setup(selectionType: .multi, defaultValues: defaultValues) { [weak self] leds in
            callback?(leds)
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: ledSelectorView, onDismissed: { callback?(nil) })
    }

    func colorSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let colorSelector = ColorSelectorModalView.instatiate()

        colorSelector.setup(optionSelector: optionSelector) { [weak self] color in
            callback?(color)
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: colorSelector, onDismissed: { callback?(nil) })
    }

    func audioSelector(_ optionSelector: OptionSelector, callback: ((String?) -> Void)?) {
        let soundPicker = SoundPickerModalView.instatiate()

        soundPicker.setup(optionSelector: optionSelector) { [weak self] sound in
            callback?(sound)
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: soundPicker, onDismissed: { callback?(nil) })
    }

    func numberInput(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        let dialpadInputViewController = AppContainer.shared.container.unwrappedResolve(DialpadInputViewController.self)

        presentViewControllerModally(
            dialpadInputViewController,
            transitionStyle: .crossDissolve,
            presentationStyle: .overFullScreen
        )

        dialpadInputViewController.setup(inputHandler: inputHandler) { [weak self] text in
            callback?(text)
            self?.dismiss(animated: true, completion: nil)
        }
    }

    func textInput(_ inputHandler: InputHandler, callback: ((String?) -> Void)?) {
        let textInput = TextInputModalView.instatiate()
        textInput.setup(inputHandler: inputHandler)
        textInput.doneCallback = { [weak self] name in
            callback?(name)
            self?.dismiss(animated: true, completion: nil)
        }
        textInput.cancelCallback = { [weak self] in
            callback?(nil)
            self?.dismiss(animated: true, completion: nil)
        }
        presentModal(with: textInput, onDismissed: { callback?(nil) })
    }

    func blockContext(_ contextHandler: BlockContextHandler, callback: ((BlockContextAction?) -> Void)?) {
        let blockContext = BlockContextMenuModalView.instatiate()
        blockContext.setup(with: contextHandler)
        blockContext.deleteCallback = { [weak self] in
           self?.dismiss(animated: true, completion: nil)
            callback?(DeleteBlockAction())
        }
        blockContext.duplicateCallback = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            callback?(DuplicateBlockAction())
        }
        blockContext.helpCallback = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            callback?(HelpAction())
        }

        presentModal(with: blockContext, onDismissed: {
            callback?(AddCommentAction(payload: blockContext.comment))
        })
    }

    func variableContext(_ optionSelector: OptionSelector, callback: ((VariableContextAction?) -> Void)?) {
        let variableContextView = VariableContextModalView.instatiate()

        variableContextView.setup(optionSelector: optionSelector) { [weak self] variableAction in
            callback?(variableAction)
            self?.dismiss(animated: true, completion: nil)
        }

        presentModal(with: variableContextView, onDismissed: { callback?(nil) })
    }

    func onBlocklyLoaded() {
        guard let program = selectedProgram, let xml = program.xml.base64Decoded else { return }

        blocklyViewController.loadProgram(xml: xml)
    }

    func onVariablesExported(variables: String) {
        guard let program = selectedProgram, programSaveReason == .edited else { return }
        let variableList = variables.components(separatedBy: ",").filter { !$0.isEmpty }
        if let programDataModel = realmService.getProgram(id: program.id) {
            realmService.updateObject {
                programDataModel.lastModified = Date()
                programDataModel.variableNames.removeAll()
                programDataModel.variableNames.append(objectsIn: variableList)
            }
            programCompatibilityValidator.validate(program: programDataModel)

        } else {
            program.variableNames.removeAll()
            program.variableNames.append(objectsIn: variableList)
            saveProgram()
            programCompatibilityValidator.validate(program: program)
        }

    }

    func onPythonProgramSaved(pythonCode: String) {
        switch programSaveReason {
        case .showCode:
            let codeView = CodePreviewModalView.instatiate()
            codeView.setup(with: pythonCode)
            codeView.doneCallback = { [weak self] in
                self?.dismissModalViewController()
            }
            presentModal(with: codeView)
        case .edited:
            guard let program = selectedProgram else { return }

            realmService.updateObject {
                program.lastModified = Date()
                program.python = pythonCode.base64Encoded ?? ""
            }
        default:
            return
        }

        isPythonExported = true
        if isXMLExported && isPythonExported && shouldDismissAfterSave {
            isXMLExported = false
            isPythonExported = false
            shouldDismissAfterSave = false
            navigationController?.popViewController(animated: true)
        }
    }

    func onXMLProgramSaved(xmlCode: String) {
        let isDefaulProgram = xmlCode == Constants.defaultXMLCode

        switch programSaveReason {
        case .navigateBack:
            guard let selectedProgram = selectedProgram else {
                isDefaulProgram ? navigateBack() : confirmLeave()
                return
            }

            let replaced =
                selectedProgram.xml.base64Decoded!.replacingPattern(regexPattern: Constants.blocklyElementIdRegex)
            let isXmlModified = replaced != xmlCode.replacingPattern(regexPattern: Constants.blocklyElementIdRegex)

            if isXmlModified {
                confirmLeave()
            } else {
                navigateBack()
            }
        case .openProgram:
            guard let selectedProgram = selectedProgram else {
                isDefaulProgram ? openProgramModal() : confirmLeave()
                return
            }

            let replaced =
                selectedProgram.xml.base64Decoded!.replacingPattern(regexPattern: Constants.blocklyElementIdRegex)
            let isXmlModified = replaced != xmlCode.replacingPattern(regexPattern: Constants.blocklyElementIdRegex)

            if isXmlModified {
                confirmLeave()
            } else {
                openProgramModal()
            }
        case .edited:
            guard let program = selectedProgram else { return }

            realmService.updateObject {
                program.lastModified = Date()
                program.xml = xmlCode.base64Encoded ?? ""
            }
        default:
            return
        }

        isXMLExported = true
        if isXMLExported && isPythonExported && shouldDismissAfterSave {
            isXMLExported = false
            isPythonExported = false
            shouldDismissAfterSave = false
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - Actions
extension ProgramsViewController {
    @IBAction private func backButtonTapped(_ sender: UIButton) {
        programSaveReason = .navigateBack
    }

    @IBAction private func programCodeButtonTapped(_ sender: UIButton) {
        programSaveReason = .showCode
    }

    @IBAction private func saveProgramButtonTapped(_ sender: UIButton) {
        initiateSave(shouldNavigateBack: false, shouldOpenPrograms: false)
    }

    private func initiateSave(shouldNavigateBack: Bool, shouldOpenPrograms: Bool) {
        let saveModal = SaveProgramModalView.instatiate()
        if let program = selectedProgram {
            saveModal.setup(with: program)
        }
        saveModal.doneCallback = { [weak self] saveData in
            self?.dismissModalViewController()
            guard (self?.canBeOverwritten(name: saveData.name))! else {
                self?.present(UIAlertController.errorAlert(type: .programAlreadyExists), animated: true)
                return
            }
            if self?.selectedProgram == nil {
                self?.selectedProgram = ProgramDataModel(id: UUID().uuidString)
                self?.selectedProgram?.name = saveData.name
            } else if self?.selectedProgram!.name != saveData.name {
                self?.selectedProgram = nil
                self?.selectedProgram = ProgramDataModel(id: UUID().uuidString)
                self?.selectedProgram?.name = saveData.name
            }
            if let description = saveData.description {
                self?.save(description: description)
            }
            self?.programSaveReason = .edited

            if shouldNavigateBack {
                self?.navigationController?.popViewController(animated: true)
            } else if shouldOpenPrograms {
                self?.openProgramModal()
            }
        }
        presentModal(with: saveModal)
    }

    @IBAction private func openProgramButtonTapped(_ sender: UIButton) {
        programSaveReason = .openProgram
    }
}

// MARK: - Private methods
extension ProgramsViewController {
    private func canBeOverwritten(name: String?) -> Bool {
        guard let name = name else { return true }

        return !realmService.getPrograms().contains(where: { $0.name == name && !$0.remoteId.isEmpty })
    }
}

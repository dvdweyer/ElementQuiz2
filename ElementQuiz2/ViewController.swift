//
//  ViewController.swift
//  ElementQuiz2
//
//  Created by Donald van de Weyer on 08/09/20.
//  Copyright © 2020 Donald van de Weyer. All rights reserved.
//

import UIKit

enum Mode {
    case flashcard
    case quiz
}

enum State {
    case question
    case answer
    case score
}

class ViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mode = .flashcard
    }
    
    let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    var elementList: [String] = []
    var currentElementIndex = 0
    var mode: Mode = .flashcard {
        didSet {
            switch mode {
            case .flashcard:
                setupFlashcards()
            case .quiz:
                setupQuiz()
            }
            updateUI()
        }
    }
    var state: State = .question
    var answerIsCorrect = false
    var correctAnswerCount = 0

    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBAction func switchMode(_ sender: Any) {
        if modeSelector.selectedSegmentIndex == 0 {
            mode = .flashcard
        } else {
            mode = .quiz
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBAction func showAnswer(_ sender: Any) {
        state = .answer
        updateUI()
    }
    
    @IBOutlet weak var nextElementButton: UIButton!
    @IBAction func nextElement(_ sender: Any) {
        currentElementIndex += 1
        if currentElementIndex >= elementList.count {
            currentElementIndex = 0
            if mode == .quiz {
                state = .score
                updateUI()
                return
            }
        }
        state = .question
        updateUI()
    }
    
    func setupFlashcards() {
        elementList = fixedElementList
        state = .question
        currentElementIndex = 0
    }
    
    func setupQuiz() {
        elementList = fixedElementList.shuffled()
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
    }
    
    func updateFlashcardUI(elementName: String) {
        modeSelector.selectedSegmentIndex = 0
        textField.isHidden = true
        textField.resignFirstResponder()
        showAnswerButton.isHidden = false
        nextElementButton.isEnabled = true
        nextElementButton.setTitle("Next Element", for: .normal)
        if state == .answer {
            answerLabel.text = elementName
        } else {
            answerLabel.text = "?"
        }
    }
    
    func updateQuizUI(elementName: String) {
        modeSelector.selectedSegmentIndex = 1
        textField.isHidden = false
        showAnswerButton.isHidden = true
        if currentElementIndex == elementList.count - 1 {
            nextElementButton.setTitle("Show Score", for: .normal)
        } else {
            nextElementButton.setTitle("Next Question", for: .normal)
        }
        switch state {
        case .question:
            answerLabel.text = ""
            nextElementButton.isEnabled = false
            textField.text = ""
            textField.isEnabled = true
            textField.becomeFirstResponder()
        case .answer:
            textField.resignFirstResponder()
            textField.isEnabled = false
            if answerIsCorrect {
                answerLabel.text = "Correct!"
            } else {
                answerLabel.text = "WRONG!!!\nCorrect Answer: " + elementName
            }
            nextElementButton.isEnabled = true
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
            answerLabel.text = ""
            nextElementButton.isEnabled = false
            displayScoreAlert()
        }
    }
    
    func updateUI() {
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        switch mode {
        case .flashcard:
            updateFlashcardUI(elementName: elementName)
        case .quiz:
            updateQuizUI(elementName: elementName)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFieldContents = textField.text!
        if textFieldContents.lowercased() == elementList[currentElementIndex].lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }
        state = .answer
        updateUI()
        return true
    }
    
    func displayScoreAlert() {
        let alert = UIAlertController(title: "Quiz Score", message: "Your quiz score is \(correctAnswerCount) out of \(elementList.count).", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:))
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    
    func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashcard
        correctAnswerCount = 0
        updateUI()
    }
}

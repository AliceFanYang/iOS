//
//  ViewController.swift
//  Calculator
//
//  Created by Alice Yang on 5/13/15.
//  Copyright (c) 2015 Alice Yang. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var displayHistory: UILabel!
    
    var userIsInTheMiddleOfTypingANumber: Bool = false
    
    var brain = CalculatorBrain()
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            if (newValue == nil) {
                display.text = " "
                userIsInTheMiddleOfTypingANumber = false
            } else {
                display.text = "\(newValue!)"
            }
        }
    }


    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            switch digit {
            case ".":
                if display.text!.rangeOfString(".") == nil {
                    // no decimal yet
                    display.text = display.text! + "."
                }
            case "0":
                if (display.text != "0") {
                    display.text = display.text! + "0"
                }
            default:
                if display.text == "0" {
                    display.text = digit
                } else {
                    display.text = display.text! + digit
                }
            }
        } else {
            switch digit {
            case ".":
                display.text = "0."
            default:
                display.text = digit
            }
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
        }
        displayHistory.text = brain.description + "="
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if displayValue != nil {
            displayValue = brain.pushOperand(displayValue!)
            displayHistory.text = brain.description
        }
    }
    
    @IBAction func clear() {
        // clear stack/history
        brain = CalculatorBrain()
        
        // clear display
        displayValue = nil
        
        // clear display history
        displayHistory.text = " "
    }

    @IBAction func backspace() {
        if userIsInTheMiddleOfTypingANumber{
            if (countElements(display.text!) == 1) || (countElements(display.text!) == 2 && display.text!.rangeOfString("-") != nil) {
                display.text = "0"
            } else {
                display.text = dropLast(display.text!)
            }
        } else {    // undo the last thing that was done in the CalculatorBrain
            displayValue = brain.popOperand()
            displayHistory.text = brain.description
        }
    }
    
    @IBAction func changeSign() {
        if (userIsInTheMiddleOfTypingANumber && display.text! != "0" && display.text! != "0.") {
            if (display.text!.rangeOfString("-") == nil) {
                display.text = "-" + display.text!
            } else {
                display.text = dropFirst(display.text!)
            }
        }
    }
    
    @IBAction func setVariableM(sender: UIButton) {
        // sets the value of the variable M in the brain to the current value of the display (if any)
        // should not perform an automatic ↲ (though it should reset “user is in the middle of typing a number”)
        // show the evaluation of the brain (i.e. the result of evaluate()) in the display
        if displayValue != nil {
            brain.variableValues["M"] = displayValue!
            if let result = brain.evaluate() {
                displayValue = result
            } else {
                displayValue = nil
            }
        }
        displayHistory.text = brain.description + "="
        userIsInTheMiddleOfTypingANumber = true
    }
    
    @IBAction func pushVariableM(sender: UIButton) {
        // push an M variable (not the value of M) onto the CalculatorBrain
        // show the evaluation of the brain (i.e. the result of evaluate()) in the display
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand("M") {
            displayValue = result
        } else {
            displayValue = nil
        }
        displayHistory.text = brain.description + "="
        
    }
    
    
}


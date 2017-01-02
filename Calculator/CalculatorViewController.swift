//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Hatim Rehman on 2016-05-02.
//  Copyright © 2016 Hatim Rehman. All rights reserved.
//

import UIKit



class CalculatorViewController: UIViewController {
    
    @IBOutlet fileprivate weak var display: UILabel! //can be used synonymously with ! to declare optional during instantiation
    
    @IBOutlet var Buttons: [UIButton]!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let gvc = (segue.destination as? UITabBarController)?.viewControllers![0] as? GraphViewController {
                gvc.program = brain.program
            }
        
    }
    
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        if let nav = self.navigationController?.navigationBar {
            nav.barStyle = UIBarStyle.black
            nav.tintColor = UIColor.white
            nav.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orange]
            nav.topItem?.title = "Graphing Interface"
        }
        
    }
    
    @IBAction func retrieveProgram(_ sender: UIButton) {
        
        userIsInTheMiddleOfTyping = false
        
        if savedProgram != nil {
            
            brain.program = savedProgram!
            var delayTime = 0.0
            let incrementor = 0.25
            if let arrayOfOps = savedProgram as? [AnyObject] {
                
                for op in arrayOfOps {
                    
                    if let operation = op as? String , operation == "＝" {
                            continue
                    }
                    
                    delay(delayTime){
                        if let operand = op as? Double {
                            self.displayValue = operand
                        } else if let operation = op as? String {
                            self.display.text = operation
                        } else if let variable = op as? Variable {
                            self.display.text = variable.name
                        }
                    }
                    
                    delayTime += incrementor
                }
            }
            
            delay(delayTime){
                self.display.text = "＝"
            }
            delayTime += incrementor
            delay(delayTime){
                self.displayValue = self.brain.result.0
            }
        }

        
        
    }

    override func viewDidLoad() {
        
        for button in Buttons {
            button.layer.borderWidth = 0.25
            button.layer.borderColor = UIColor.black.cgColor
        }
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        let statusBar = UIApplication.shared.value(forKey: "statusBar") as! UIView
        
        statusBar.backgroundColor = display.backgroundColor
        
        // create custom tap gestures
        let tapDisplay = UITapGestureRecognizer(target: self, action: #selector(CalculatorViewController.tapDisplay(_:)))
        
        let slideLeftOnDisplay = UISwipeGestureRecognizer(target: self, action: #selector(CalculatorViewController.swipeLeftOnDisplay))
        slideLeftOnDisplay.direction = UISwipeGestureRecognizerDirection.right
        
        let tapRestore = UITapGestureRecognizer(target: self, action: #selector(CalculatorViewController.restore))
        let longHoldSave = UILongPressGestureRecognizer(target: self, action: #selector(CalculatorViewController.longTapSave(_:)))
        let longHoldRestore = UILongPressGestureRecognizer(target: self, action: #selector(CalculatorViewController.longTapRestore(_:)))
        
        // add to outlets
        display.addGestureRecognizer(tapDisplay)
        display.addGestureRecognizer(slideLeftOnDisplay)
        
        restoreButton.addGestureRecognizer(tapRestore)
        restoreButton.addGestureRecognizer(longHoldRestore)
        saveButton.addGestureRecognizer(longHoldSave)
        
        // resize when contents of display cannot fit screen
        display.adjustsFontSizeToFitWidth = true
        
    }
    
    @IBAction func swipeLeftOnDisplay() {
        
        if userIsInTheMiddleOfTyping {
            
            let withLastDigitDropped = String(display.text!.characters.dropLast())
            
            if withLastDigitDropped == "" {
                
                displayValue = 0
                userIsInTheMiddleOfTyping = false
                
            } else {
                display.text = withLastDigitDropped
            }
        }
    }
    
    fileprivate struct savedOperand {
        
        static var Restore = 0.0
        static var Display = 0.0
        
    }
    
    func tapDisplay(_ recognizer: UITapGestureRecognizer) {
        
        if showingDescription() { // if showing description
            
            displayValue = savedOperand.Display // switch from saved value
            
        }
            
        else {
            
            savedOperand.Display = displayValue// save prior to changing display
            display.text = brain.result.1 // switch to description
        }
        
    }
    
    fileprivate func showingDescription() -> Bool {
        
        return Double(String(display.text!)) == nil
    }
    
    fileprivate var userIsInTheMiddleOfTyping = false
    
    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle! //unwrap optional
        
        if userIsInTheMiddleOfTyping {
            
            if showingDescription() { displayValue = savedOperand.Display }

            let textCurrentlyInDisplay = display.text!
            
            display.text = textCurrentlyInDisplay + digit
            
        } else{
            display.text = digit
        }
        
        userIsInTheMiddleOfTyping = true
        
    }
    
    
    fileprivate var displayValue: Double {
        get {
            
            if showingDescription() {
                self.displayValue = savedOperand.Display
            }
            
            return Double(display.text!)!
        }
        set {
            if isInt(newValue) { display.text = String(Int(newValue)) } // format to int when possible
            else { display.text = String(newValue) }
        }
    }
    
    fileprivate var savedProgram: CalculatorBrain.PropertyList?
    
    fileprivate var delayIsActive = false
    
    @IBAction func save() {
        
        if delayIsActive { return }
        
        savedOperand.Restore = displayValue
        
        brain.setVariable(savedOperand.Restore)
        
        display.text = variable.name + " = " + String(display.text!)
        
        
        delayIsActive = true
        
        delay(0.75){ [weak weakSelf = self] in
            weakSelf?.displayValue = savedOperand.Restore
            weakSelf?.delayIsActive = false
        }
        
        
    }
    
    lazy var tempBrain = CalculatorBrain()
    
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    func longTapRestore(_ sender : UIGestureRecognizer){
        
        if sender.state == .began {
        }
    }
    
    func longTapSave(_ sender : UIGestureRecognizer){
        
        if sender.state == .ended {
            displayValue = savedOperand.Display
        }
        else if sender.state == .began {
            
            if savedProgram != nil {
                savedOperand.Display = displayValue
                displayValue = savedOperand.Restore
                display.text = variable.name + " = " + display.text!
            }
            
        }
    }
    
    fileprivate var variable: Variable = Variable()
    
    @IBAction func restore() {
    
        if savedProgram != nil { variable.value = savedOperand.Restore }
        
        display.text = variable.name
        brain.setOperand(variable)
    }
    
    fileprivate var brain = CalculatorBrain()
    
    //connect Model (brain) to Controller (this class)
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            
            brain.setOperand(displayValue as AnyObject)
            userIsInTheMiddleOfTyping = false
            
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            
            
            brain.performOperation(mathematicalSymbol)
            
            if mathematicalSymbol == "＝" {//&& brain.result.1.characters.contains(Character(variable.name)) {
                // in a different queue, send a different program to the graphing view
                savedProgram = brain.program
                if let bool = self.splitViewController?.isCollapsed , bool == false {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "sendToGraph", sender: nil)
                    }
                }
                
                displayValue = brain.result.0
            }
            
        }
        
        // to not switch to variable's value between operations (i.e keep displaying as "x")
        if display.text != variable.name { displayValue = brain.result.0 }// update display
    }
    
    
    @IBAction func floatingPoint(_ sender: UIButton) {
        
        if  isInt(displayValue) {
            display.text = String(Int(displayValue)) + "."
            userIsInTheMiddleOfTyping = true
        }
        
    }
    
    
}

func delay(_ delay: Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
        execute: closure
    )
}



//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Hatim Rehman on 2016-05-03.
//  Copyright © 2016 Hatim Rehman. All rights reserved.
//

import Foundation

func isInt(_ x:Double) -> Bool {
    
    return Double(Int(x)) == x
    
}

class Variable {
    
    var name: String = "x"
    var value: Double = 0.0
    
}

class CalculatorBrain
{
    fileprivate var accumulator = 0.0
    fileprivate var internalProgram = [AnyObject]()
    fileprivate var description = "0"
    fileprivate var bracketsAdder = 1
    
    
    fileprivate var variable: Variable = Variable()
    
    func setVariable(_ value: Double) {
        variable.value = value
    }
    
    func setOperand(_ operand: AnyObject){
        
        if let _ = operand as? Variable {
            addToDescription(variable.name as AnyObject)
            internalProgram.append(variable)
            accumulator = variable.value
        }
        
        else if let operand = operand as? Double {              
            addToDescription(operand as AnyObject)
            internalProgram.append(operand as AnyObject)
            accumulator = operand
        }
        
    }
    
    fileprivate func addToDescription(_ object: AnyObject) {
        
        if let operand = object as? Double {
            if supposedToAddToDescription(){
                
                if isInt(operand) { description = description + " " + String(Int(operand)) }
                    
                else { description = description + " " + String(operand) }
                
            } else {
                
                if isInt(operand) { description = String(Int(operand)) }
                    
                else { description = String(operand) }
                
                bracketsAdder = 1; // reset value back to 1
                
            }

        }
        
        else if let operand = object as? String {
            
            if supposedToAddToDescription(){ description = description + " " + operand }
            
            else { description = operand; bracketsAdder = 1 } // reset value back to 1

        }
        
    }
    // True when last char in description is not a number or a closing bracket ")"
    fileprivate func supposedToAddToDescription() -> Bool {
        
        let lastChar = String(description.characters.last!)
        return Double(lastChar) == nil && lastChar != ")" && lastChar != variable.name
        
    }
    
    fileprivate var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(M_PI),
        "e": Operation.constant(M_E),
        "±": Operation.unaryOperation({ -$0 }),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
        "tan": Operation.unaryOperation(tan),
        "ln": Operation.unaryOperation(log),
        "xⁿ": Operation.binaryOperation({pow($0,$1)}),
        "×": Operation.binaryOperation({$0 * $1}),
        "÷": Operation.binaryOperation({$0 / $1}),
        "+": Operation.binaryOperation({$0 + $1}),
        "–": Operation.binaryOperation({$0 - $1}),
        "＝": Operation.equals,
        "c": Operation.cancel
    ]
    
    fileprivate enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double)-> Double)
        case equals
        case cancel
        
    }
    
    func performOperation(_ symbol: String) {
        internalProgram.append(symbol as AnyObject)
        executePendingBinaryOperation()
        if let operation = operations[symbol]{
            
            switch operation {
            
            case .constant(let value):
                setOperand(value as AnyObject)
            
            case .unaryOperation(let function):
                
                // case 1: operation performed on constant number
                if pending == nil { description = symbol + "(" + description + ")" }
                
                // case 2: operation performed on first operand in binary function
                    /*  TODO have a way to check if unaryoperation(accumulator) is equal to accumulator
                     to fix bug */
                else if accumulator == Double(String(description.characters.dropLast(2)))  {
                    
                    description = symbol + "(" + String(description.characters.dropLast(2)) + ")"
                    
                    bracketsAdder = 1
                
                } else { // case 3: operation performed on second operand in binary function
                    
                    let lengthOfLastNumberEntered = Int(String(describing: accumulator.description.characters.endIndex))!
                    
                    var withoutLastNumberEntered = ""
                    var lastNumberEntered = ""
                    
                    if isInt(accumulator) {
                        withoutLastNumberEntered = String(description.characters.dropLast(lengthOfLastNumberEntered-2))
                        lastNumberEntered = String(description.characters.dropFirst(Int(String(describing: description.characters.endIndex))!-(lengthOfLastNumberEntered-2)))
                    } else {
                        withoutLastNumberEntered = String(description.characters.dropLast(lengthOfLastNumberEntered))
                        lastNumberEntered = String(description.characters.dropFirst(Int(String(describing: description.characters.endIndex))!-lengthOfLastNumberEntered))
                    }
                    
                    
                    description = withoutLastNumberEntered + symbol + "(" +
                                    lastNumberEntered + ")"
                }
            
                accumulator = function(accumulator)
            
            case .binaryOperation(let function):
                
                if supposedToAddToDescription() {
                    
                    description = String(description.characters.dropLast()) + symbol
                    pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                    break
                }
                
                if symbol == "+" || symbol == "–" { bracketsAdder = 1 }
                
                if bracketsAdder % 2 == 0 {
                    description = "(" + description + ")"
                    bracketsAdder = 1
                }
                
                bracketsAdder += 1
                
                description = description + " " + symbol
                
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                
            case .equals:
                if supposedToAddToDescription() { break }
                executePendingBinaryOperation()
                
            case .cancel:
                reset()
                
            }
            
        }
    }
    
    fileprivate func reset(){
        
        accumulator = 0.0
        description = "0"
        pending = nil
        bracketsAdder = 1
        internalProgram.removeAll()
        
    }
    
    fileprivate func executePendingBinaryOperation(){
        
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
            
        }
    }
    fileprivate var pending: PendingBinaryOperationInfo?
    
    // structs/enums are passed by value.
    // in comparsion, classes are passed by reference
    fileprivate struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        
        set {
            
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand((operand as AnyObject))
                    } else if let operation = op as? String {
                        performOperation(operation)
                    } else if let variable = op as? Variable {
                        setOperand((variable))
                    }
                }

            }
        }
        
    }
    

    var result: (Double, String) {
        get {
            
            if pending != nil {return (accumulator, description + " ...") }
            if accumulator.isNaN || accumulator.isInfinite{ reset() }
            return (accumulator, description)
            
        }
    }
    
    
}


//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Alice Yang on 6/24/15.
//  Copyright (c) 2015 Alice Yang. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: Printable
    {
        case Operand(Double)
        case Constant(String, () -> Double)
        case Variable(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Constant(let constant, _):
                    return constant
                case .Variable(let symbol):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = Dictionary<String,Op>()
    
    internal var variableValues = Dictionary<String,Double>()
    
    internal var description: String {
        get {
            var totalExpression: String = ""
            var expression: String? = ""
            var remainingOps = opStack
            while(!remainingOps.isEmpty) {
                (expression, remainingOps) = describeOneOperation(remainingOps)
                if !totalExpression.isEmpty {
                    totalExpression = expression! + "," + totalExpression
                } else {
                    totalExpression = expression!
                }
            }
            if (totalExpression == "") {
                totalExpression = " "
            }
            return totalExpression
        }
    }
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.Constant("π") { M_PI } )
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("-/+") { -$0 })
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return opStack.map({ $0.description })
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return(operand, remainingOps)
            case .Constant(_, let constant):
                return(constant(), remainingOps)
            case .Variable(let symbol):
                if let operand = variableValues[symbol] {
                    return(operand, remainingOps)
                }
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return(operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return(operation(operand1, operand2),op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        var remainingOps = opStack
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    /*
    func setVariable(symbol: String, value: Double) -> Double? {
        variableValues[symbol] = value
        return evaluate()
    } 
    */
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func popOperand() -> Double? {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
        return evaluate()
    }
    
    private func describeOneOperation(ops: [Op]) -> (expression: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            var expression: String? = nil
            
            switch op {
            case .Operand, .Constant, .Variable:
                return (op.description, remainingOps)
            case .UnaryOperation(let operation, _):
                let (result, remainingOps) = describeOneOperation(remainingOps)
                if (result != nil) {
                    expression = operation + "(" + result! + ")"
                } else {
                    expression = operation + "(" + "?" + ")"
                }
                return (expression, remainingOps)
            case .BinaryOperation(let operation, _):
                let (operand2, remainingOps) = describeOneOperation(remainingOps)
                if (operand2 != nil) {
                    let (operand1, remainingOps) = describeOneOperation(remainingOps)
                    if (operand1 != nil) {
                        expression = "(" + operand1! + operation + operand2! + ")"
                    } else {
                        expression = "(" + "?" + operation + operand2! + ")"
                    }
                    return (expression, remainingOps)
                } else {
                    expression = "(" + "?" + operation + "?" + ")"
                }
                return (expression, remainingOps)
            }
        }
        return (nil,[])
        
    }
    
    
    
}

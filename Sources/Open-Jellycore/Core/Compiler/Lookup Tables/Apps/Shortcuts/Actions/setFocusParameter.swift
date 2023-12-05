
//
//  GetCurrentFocusParameter.swift
//  Open-Jellycore
//
//  Created by Albion Fung on 5 Dec 2023.
//
struct SetFocusParameter: ParameterProtocol, Codable {
    var WFInput: JellyVariableReference?
    var WFToggle: JellyBoolean?
    var WFFocusMode: JellyString?
    var WFSetFocusOff: JellyBoolean?
    var WFSetUntil: JellyDate?

    static func build(call: [FunctionCallParameterItem], scopedVariables: [Variable]) -> ParameterProtocol {
        var parameters = SetFocusParameter()

        if let variableCall = call.first(where: { node in return node.slotName == "toggle" })?.item {
            if let variable = Scope.find(variableCall.content, in: scopedVariables) {
                parameters.WFToggle = JellyVariableReference(variable, scopedVariables: scopedVariables)
            } else {
                EventReporter.shared.reportError(error: .variableDoesNotExist(variable: variableCall.content), node: nil)
            }
        } else {
            EventReporter.shared.reportError(error: .missingParameter(function: "setFocus", name: "toggle"), node: nil)
        }

        if let variableCall = call.first(where: { node in return node.slotName == "focus" })?.item {
            if let variable = Scope.find(variableCall.content, in: scopedVariables) {
                parameters.WFFocusMode = JellyVariableReference(variable, scopedVariables: scopedVariables)
            } else {
                EventReporter.shared.reportError(error: .variableDoesNotExist(variable: variableCall.content), node: nil)
            }
        } else {
            EventReporter.shared.reportError(error: .missingParameter(function: "setFocus", name: "focus"), node: nil)
        }

        if let variableCall = call.first(where: { node in return node.slotName == "setAsOff" })?.item {
            if let variable = Scope.find(variableCall.content, in: scopedVariables) {
                parameters.WFSetFocusOff = JellyVariableReference(variable, scopedVariables: scopedVariables)
            } else {
                EventReporter.shared.reportError(error: .variableDoesNotExist(variable: variableCall.content), node: nil)
            }
        } else {
            EventReporter.shared.reportError(error: .missingParameter(function: "setFocus", name: "setAsOff"), node: nil)
        }

        if let variableCall = call.first(where: { node in return node.slotName == "setUntil" })?.item {
            if let variable = Scope.find(variableCall.content, in: scopedVariables) {
                parameters.WFSetFocusOff = JellyVariableReference(variable, scopedVariables: scopedVariables)
            } else {
                EventReporter.shared.reportError(error: .variableDoesNotExist(variable: variableCall.content), node: nil)
            }
        } else {
            EventReporter.shared.reportError(error: .missingParameter(function: "setFocus", name: "setUntil"), node: nil)
        }

        return parameter
    }

    static func getDefaultValues() -> [String: String] {
        return [
            "": ""
        ]
    }
}
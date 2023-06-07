//
//  JellyVariableReference.swift
//  Open-Jellycore
//
//  Created by Taylor Lineman on 10/28/22.
//

import Foundation

/// A reference to a Shortcuts variable. JellyVariableReferences require a valid Jelly ``Variable`` in the scope.
struct JellyVariableReference: JellyAny, Codable {
    /// These types directly correlate to the different types available to shortcuts variables.
    enum VariableType: String, Codable {
        /// A variable that has been declared using `var {NAME} = {VALUE}`
        case variable = "Variable"
        /// A variable that is equal to the Shortcut Input
        case shortcutInput = "ExtensionInput"
        /// A variable that is equal to the clipboard contents
        case clipboard = "Clipboard"
        /// A variable that is equal to the current date.
        case currentDate = "CurrentDate"
        /// A variable that requests user input for the value,
        case ask = "Ask"
        /// A variable that represents the device details.
        case deviceDetails = "DeviceDetails"
        /// A variable that's value is equal to the output of a function AKA a magic variable declared with the syntax `>> {NAME}
        case magicVariable = "ActionOutput"
        
        /// Potentially initializes a type using the Jelly syntax for the corresponding variable type.
        /// - Parameter jellyValue: The Jelly syntax to be converted.
        init(jellyValue: String) {
            switch jellyValue {
            case "ShortcutInput":
                self = .shortcutInput
            case "Clipboard":
                self = .clipboard
            case "CurrentDate":
                self = .currentDate
            case "Ask":
                self = .ask
            case "DeviceDetails":
                self = .deviceDetails
            default:
                self = .variable
            }
        }
    }
    
    /// The name of the variable.
    var name: String
    /// The variable's UUID used for identification.
    var uuid: String

    /// The aggrandizements that that modify the value of the variable.
    var aggrandizements: [Aggrandizement] = []
    /// This is true if the variable requires the inclusion of the `Value` key when encoding.
    var needsValueKey: Bool = true
    /// This is true if the variable requires the serialization type when encoded.
    var needsSerialization: Bool = true
    /// This is the type of the variable.
    var variableType: VariableType = .variable
    
    /// The coding keys used to convert a variable into a format Shortcuts recognizes,.
    private enum EncodingKey: String, CodingKey {
        case value = "Value"
        case serializationType = "WFSerializationType"
        case type = "Type"
        case variableName = "VariableName"
        case aggrandizements = "Aggrandizements"
        
        case outputName = "OutputName"
        case outputUUID = "OutputUUID"
    }
    
    /// Initializes a ``JellyVariableReference`` using a ``Variable`` to initialize all of the required values.
    /// - Parameters:
    ///   - value: The variable to initialize with.
    ///   - scopedVariables: The scoped variables accessible by the variable.
    init(_ value: Variable, scopedVariables: [Variable]) {
        self.name = value.name
        self.uuid = value.uuid
    }
    
    /// This initializer creates a ``JellyVariableReference`` type taking in a ``CoreNode`` and the scope's variables.
    /// - Parameters:
    ///   - value: the core node to convert to a ``JellyVariableReference``.
    ///   - scopedVariables: the variables that are in the scope of the ``JellyVariableReference``.
    init?(_ value: CoreNode, scopedVariables: [Variable]) {
        self.name = value.content
        self.uuid = ""
        
        if let variable = scopedVariables.first(where: { variableNameFilter(variable: $0, name: name) }) {
            self.name = variable.name
            self.uuid = variable.uuid
            
            if variable.valueType == .magicVariable {
                variableType = .magicVariable
            }
        } else if let globalVariable = Transpiler.globalVariables.first(where: { variableNameFilter(variable: $0, name: name) }) {
            self.variableType = VariableType(jellyValue: globalVariable.name)
        } else {
            ErrorReporter.shared.reportError(error: .variableDoesNotExist(variable: self.name), node: value)
            return nil
        }
    }
    
    /// Initializes a variable using the an ``IdentifierNode``. This initialization requires for the variable contained within the ``IdentifierNode`` to be a valid variable located in the `scopedVariables`
    /// - Parameters:
    ///   - identifierNode: The ``IdentifierNode`` to use during initialization.
    ///   - scopedVariables: The scoped variables that are available to the variable.
    init?(identifierNode: IdentifierNode, scopedVariables: [Variable]) {
        self.name = identifierNode.content
        self.uuid = ""
        
        if let variable = scopedVariables.first(where: { variableNameFilter(variable: $0, name: name) }) {
            self.name = variable.name
            self.uuid = variable.uuid
            self.aggrandizements = identifierNode.aggrandizements
            
            if variable.valueType == .magicVariable {
                variableType = .magicVariable
            }
        } else if let globalVariable = Transpiler.globalVariables.first(where: { variableNameFilter(variable: $0, name: name) }) {
            self.variableType = VariableType(jellyValue: globalVariable.name)
        } else {
            ErrorReporter.shared.reportError(error: .variableDoesNotExist(variable: self.name), node: identifierNode)
            return nil
        }
    }

    /// Initializes a variable using the an ``StringNode/InterpolationNode``. This initialization requires for the variable contained within the ``StringNode/InterpolationNode`` to be a valid variable located in the `scopedVariables`
    /// - Parameters:
    ///   - interpolationNode: The ``StringNode/InterpolationNode`` to use during initialization.
    ///   - scopedVariables: The scoped variables that are available to the variable.
    init?(interpolationNode: StringNode.InterpolationNode, scopedVariables: [Variable]) {
        self.name = ""
        self.uuid = ""
        let name = interpolationNode.identifierNode?.content ?? interpolationNode.content

        if let variable = scopedVariables.first(where: { variableNameFilter(variable: $0, name: name) }) {
            self.name = variable.name
            self.uuid = variable.uuid
            self.aggrandizements = interpolationNode.identifierNode?.aggrandizements ?? []
            
            if variable.valueType == .magicVariable {
                variableType = .magicVariable
            }
        } else if let globalVariable = Transpiler.globalVariables.first(where: { variableNameFilter(variable: $0, name: name) }) {
            self.variableType = VariableType(jellyValue: globalVariable.name)
        } else {
            ErrorReporter.shared.reportError(error: .variableDoesNotExist(variable: self.name), node: interpolationNode)
            return nil
        }
    }
    
    /// The filter used to check to see if a variable's name is equal to the given name.
    /// - Parameters:
    ///   - variable: The variable to check.
    ///   - name: The name to check against.
    /// - Returns: A boolean indicating whether or not the names match.
    private func variableNameFilter(variable: Variable, name: String) -> Bool {
        return variable.name == name
    }
    
    /// Encodes the ``JellyVariableReference`` to the given `encoder`.
    /// - Parameter encoder: the encoder to encode into.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKey.self)

        if needsValueKey {
            if variableType == .magicVariable {
                let variableDictioanry: [String: QuantumValue] = [
                    EncodingKey.type.rawValue : QuantumValue(variableType),
                    EncodingKey.outputName.rawValue : QuantumValue(name),
                    EncodingKey.outputUUID.rawValue: QuantumValue(uuid),
                    EncodingKey.aggrandizements.rawValue : QuantumValue(aggrandizements)
                ]

                try container.encode(variableDictioanry, forKey: .value)
            } else {
                let variableDictioanry: [String: QuantumValue] = [
                    EncodingKey.type.rawValue : QuantumValue(variableType),
                    EncodingKey.variableName.rawValue : QuantumValue(name),
                    EncodingKey.aggrandizements.rawValue : QuantumValue(aggrandizements)
                ]

                try container.encode(variableDictioanry, forKey: .value)
            }
        } else {
            if variableType == .magicVariable {
                try container.encode(name, forKey: .outputName)
                try container.encode(uuid, forKey: .outputUUID)
            } else {
                try container.encode(name, forKey: .variableName)
            }

            try container.encode(variableType, forKey: .type)
            try container.encode(aggrandizements, forKey: .aggrandizements)
        }

        if needsSerialization {
            try container.encode("WFTextTokenAttachment", forKey: .serializationType)
        }
    }
}

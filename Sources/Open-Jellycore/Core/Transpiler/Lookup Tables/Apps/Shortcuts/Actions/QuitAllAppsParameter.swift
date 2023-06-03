//
//  QuitAllAppsParameter.swift
//  Open-Jellycore
//
//  Created by Taylor Lineman on 6/02/23.
//

struct QuitAllAppsParameter: ParameterProtocol, Codable {
	var WFAppsExcept: JellyArray<ShortcutsApp>?
	var WFAskToSaveChanges: JellyBoolean?


    static func build(call: [FunctionCallParameterItem], scopedVariables: [Variable]) -> ParameterProtocol {
        var parameters = QuitAllAppsParameter()

        if let value = call.first(where: { node in return node.slotName == "except" }) {
            parameters.WFAppsExcept = JellyArray<ShortcutsApp>(value, scopedVariables: scopedVariables)
        } else {
            ErrorReporter.shared.reportError(error: .missingParameter(function: "quitAllApps", name: "except"), node: nil)
        }
        if let value = call.first(where: { node in return node.slotName == "askToSave" }) {
            parameters.WFAskToSaveChanges = JellyBoolean(value, scopedVariables: scopedVariables)
        } else {
            ErrorReporter.shared.reportError(error: .missingParameter(function: "quitAllApps", name: "askToSave"), node: nil)
        }

        return parameters
    }
     
    // Need to loop through all properties to build the documentation.
    static func getDefaultValues() -> [String: String] {
        return [
			"except": "com.zlineman.jellyfish",
			"askToSave": "true",

        ]
    }
}
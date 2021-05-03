//
//  AppInformation.swift
//  uAppsLibrary
//
//  Created by Matthew Jagiela on 1/14/21.
//

public class AppInformation {
    public init() { }
    /**
     Get the app version that is used for App Store Connect
     */
    public func getAppVersion() -> String {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") else {
            return "Internal Error..."
        }
        return "Running Version: \(version)"
    }
    /**
     Get the text from changes.txt
     */
    public func getChanges() -> String {
        if let path = Bundle.main.path(forResource: "Changes", ofType: "txt") {

            if let contents = try? String(contentsOfFile: path) {

                return contents

            } else {

                print("Error! - This file doesn't contain any text.")
            }

        } else {

            print("Error! - This file doesn't exist.")
        }

        return ""

    }
}

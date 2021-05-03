//
//  FeedbackModel.swift
//  uAppsLibrary
//
//  Created by Matthew Jagiela on 2/10/21.
//

import CloudKit

class FeedbackModel {
    public init() {}
    
    var feedbackMessage: NSString = ""
    let version: NSString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? NSString ?? "X"
    let ticketOpen: NSNumber = 0 //0 = open 1 = closed
    func submitBugReport(name: String, type: String, crash: Bool, details: String, emailAddress: String, completion: @escaping(Error?) -> Void) {
        let publicDB  = CKContainer.default().publicCloudDatabase
        let bug = CKRecord(recordType: "Bug")
        let bugName = name as NSString
        let bugType = type as NSString
        var bugCrash = 0
        if crash {
            bugCrash = 1
        }
        let bugDetails = details as NSString
        if emailAddress.isEmpty {
            let email = emailAddress as NSString
            bug.setObject(email, forKey: "email")
        }
        bug.setObject(bugName, forKey: "name")
        bug.setObject(bugType, forKey: "type")
        bug.setObject(bugCrash as __CKRecordObjCValue, forKey: "crash")
        bug.setObject(bugDetails, forKey: "details")
        bug.setObject(0 as __CKRecordObjCValue, forKey: "open")
        bug.setObject(version, forKey: "version")
        publicDB.save(bug) { (_, error) in
            if let error = error {
                print("Error submitting bug report, erorr: \(error.localizedDescription)")
                completion(error)
            } else {
                completion(nil)
            }
        }
        
    }
    func submitFeedback(name: String, type: String, feedback: String, emailAddress: String, completion: @escaping(Error?) -> Void) {
        let publicDB = CKContainer.default().publicCloudDatabase
        let feedbackRecord = CKRecord(recordType: "Feedback")
        let nameDB = name as NSString
        let feedbackDB = feedback as NSString
        if emailAddress.isEmpty {
            let email = emailAddress as NSString
            feedbackRecord.setObject(email, forKey: "email")
        }
        feedbackRecord.setObject(nameDB, forKey: "feedbackName")
        feedbackRecord.setObject(feedbackDB, forKey: "feedbackMessage")
        feedbackRecord.setObject(version, forKey: "appVersion")
        feedbackRecord.setObject(ticketOpen, forKey: "openTicket")
        publicDB.save(feedbackRecord) { (_, error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}

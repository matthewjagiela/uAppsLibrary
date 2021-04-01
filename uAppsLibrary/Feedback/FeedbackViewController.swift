//
//  FeedbackViewController.swift
//  uAppsLibrary
//
//  Created by Matthew Jagiela on 4/2/20.
//  Copyright © 2020 Matthew Jagiela. All rights reserved.
//swiftlint:disable unused_optional_binding

import UIKit
import CloudKit
import IQKeyboardManagerSwift
class FeedbackViewController: UIViewController {
    
    @IBOutlet weak var typePicker: UISegmentedControl!
    @IBOutlet weak var feedbackNameLabel: UILabel!
    @IBOutlet weak var feedbackNameField: UITextField!
    @IBOutlet weak var feedbackTypePicker: UISegmentedControl!
    @IBOutlet weak var crashPicker: UISegmentedControl?
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var feedbackBody: UITextView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var feedbackBar: UINavigationBar!
    @IBOutlet weak var submitProgress: UIActivityIndicatorView!
    let feedbackHandler = FeedbackModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        typePicker.addTarget(self, action: #selector(typeChanged), for: .valueChanged)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var feedbackBorderColor: CGColor
        if #available(iOS 13.0, *) {
            feedbackBorderColor =  UIColor.label.withAlphaComponent(0.15).cgColor
        } else {
            feedbackBorderColor = UIColor.black.cgColor
        }
        feedbackBody.layer.borderWidth = 1
        feedbackBody.layer.borderColor = feedbackBorderColor
        feedbackBody.layer.cornerRadius = 5.0
        
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        var feedbackBorderColor: CGColor
        if #available(iOS 13.0, *) {
            feedbackBorderColor =  UIColor.label.withAlphaComponent(0.15).cgColor
        } else {
            feedbackBorderColor = UIColor.black.cgColor
        }
        feedbackBody.layer.borderWidth = 1
        feedbackBody.layer.borderColor = feedbackBorderColor
        feedbackBody.layer.cornerRadius = 5.0
    }
    @IBAction func submitFeedback(_ sender: Any) {
        submitProgress.startAnimating()
        guard let name = feedbackNameField.text else {
            return
        }
        guard let email = emailField.text else {
            return
        }
        var crash = false
        if let crashPicker = crashPicker {
            if crashPicker.selectedSegmentIndex == 1 {
                crash = true
            }
        }
        if typePicker.selectedSegmentIndex == 0 {
            feedbackHandler.submitBugReport(name: name, type: determineFeedbackType(), crash: crash, details: feedbackBody.text, emailAddress: email) { (error) in
                if let _ = error {
                    let alert = UIAlertController(title: "Error Submitting Bug Report", message: "There was an error submitting the report. Please make sure you have access to the internet and are signed into iCloud to submit.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true) {
                            self.submitProgress.stopAnimating()
                            print("Alert")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            }
        } else { //Feedback
            feedbackHandler.submitFeedback(name: name, type: determineFeedbackType(), feedback: feedbackBody.text, emailAddress: email) { error in
                if let _ = error {
                    let alert = UIAlertController(title: "Error Submitting Bug Report", message: "There was an error submitting the report. Please make sure you have access to the internet and are signed into iCloud to submit.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
                    DispatchQueue.main.async {
                        self.submitProgress.stopAnimating()
                        self.present(alert, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    func determineFeedbackType() -> String {
        let selectedIndex  = feedbackTypePicker.selectedSegmentIndex
        if selectedIndex == 0 {
            return "Interface"
        } else if selectedIndex == 1 {
            return "Usability"
        } else if selectedIndex == 2 {
            return "Data"
        } else {
            return "Other"
        }
    }
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @objc func typeChanged() {
        print("CHANGED")
        if typePicker.selectedSegmentIndex == 1 {
            crashPicker?.isHidden = true
        } else {
            crashPicker?.isHidden = false
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        FeedbackViewController.feedbackPresented = false
    }

}
extension FeedbackViewController: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
    }
}
extension FeedbackViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
extension UIViewController {
    static var feedbackPresented = false
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            //Vibrate on iPhone only:
            if !UIViewController.feedbackPresented {
                if #available(iOS 10.0, *) {
                    let generator  = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
                presentFeedback()
            }
        }
    }
    public func presentFeedback() {
        var iCloudEnabled = false
        CKContainer.default().accountStatus { (status, error) in
            DispatchQueue.main.async {
                var alert = UIAlertController()
                if let error = error {
                    alert = UIAlertController(title: "Cannot Submit Feedback", message: "Something has gone wrong... Please try again. later", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    print("iCloud Account Error = \(error)")
                    self.present(alert, animated: true) {
                        return
                    }
                }
                switch status {
                case .available:
                    print("iCloud Enabled")
                    iCloudEnabled = true
                default:
                    print("iCloud Has Error")
                    iCloudEnabled = false
                }
                if iCloudEnabled == false {
                    alert = UIAlertController(title: "iCloud Is Not Available", message: "Please make sure you are signed into iCloud to submit feedback (submitting is still anonymous).", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    
                } else {
                    if !UIViewController.feedbackPresented {
                        if #available(iOS 10.0, *) {
                            let generator  = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        }
                        let bundle = Bundle(for: FeedbackViewController.self)
                        let storyboard = UIStoryboard(name: "Feedback", bundle: bundle)
                        var feedbackController: FeedbackViewController = FeedbackViewController()
                        if #available(iOS 13.0, *) {
                            feedbackController = storyboard.instantiateViewController(identifier: "feedbackView") as FeedbackViewController
                        } else {
                            //swiftlint:disable force_cast
                            feedbackController = storyboard.instantiateViewController(withIdentifier: "feedbackView") as! FeedbackViewController
                        }
                        UIViewController.feedbackPresented = true
                        
                        self.present(feedbackController, animated: true) {
                            IQKeyboardManager.shared.enable = true
                            print("Presented Feedback VC")
                            
                        }
                    }
                }
            }
        }
    }
}

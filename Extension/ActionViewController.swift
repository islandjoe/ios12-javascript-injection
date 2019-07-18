//
//  ActionViewController.swift
//  Extension
//
//  Created by Arthur Kho on 18/07/2019.
//  Copyright © 2019 Arthur Kho. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

  var pageTitle = ""
  var pageURL   = ""

  @IBOutlet weak var script: UITextView!

  override func viewDidLoad() {
    super.viewDidLoad()

    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(
        self,
        selector: #selector( adjustForKeyboard ),
        name: UIResponder.keyboardWillHideNotification,
        object: nil )
    notificationCenter.addObserver(
      self,
      selector: #selector( adjustForKeyboard ),
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil )

    navigationItem.rightBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .done,
        target: self,
        action: #selector( done ) )

    if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem
    {
      if let itemProvider = inputItem.attachments?.first
      {
        itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String )
        {[weak self] (dict, error) in

          guard let itemDict = dict as? NSDictionary else { return }
          guard let jsValues = itemDict[ NSExtensionJavaScriptPreprocessingResultsKey ] as? NSDictionary else { return }

          self?.pageTitle = jsValues["title"] as? String ?? ""
          self?.pageURL   = jsValues["URL"]   as? String ?? ""

          DispatchQueue.main.async { self?.title = self?.pageTitle }

        }
      }
    }

  }


  @objc func adjustForKeyboard(notification: Notification) {

    guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

    let keyboardScreenEndFrame = keyboardValue.cgRectValue
    let keyboardViewEndFrame   = view.convert(keyboardScreenEndFrame, from: view.window)

    if notification.name == UIResponder.keyboardWillHideNotification
    {
      script.contentInset = .zero
    }
    else
    {
      script.contentInset = UIEdgeInsets(
          top:    0,
          left:   0,
          bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom,
          right:  0 )
    }

    script.scrollIndicatorInsets = script.contentInset

    let selectedRange = script.selectedRange
    script.scrollRangeToVisible( selectedRange )

  }


  @IBAction func done() {

    let item = NSExtensionItem()
    let arg:NSDictionary = ["customJavaScript": script.text!]
    let webDict: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: arg]
    let customJavaScript = NSItemProvider(item: webDict, typeIdentifier: kUTTypePropertyList as String)

    item.attachments = [customJavaScript]

    extensionContext?.completeRequest(returningItems: [item])

  }

}

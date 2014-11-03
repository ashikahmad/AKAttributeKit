//
//  ViewController.swift
//  AKAttributeKitDemo
//
//  Created by Ashik Ahmad on 11/2/14.
//  Copyright (c) 2014 WNeeds. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var hideKeyboard: UIButton!
    
    var demoString:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var str = ["This is a <fg #f00>demo</fg> \nwhere ",
            "<bg 0xaabbccdd><fg #ff0> you </fg></bg> can see ",
            "<u \(NSUnderlineStyle.StyleDouble.rawValue|NSUnderlineStyle.PatternDot.rawValue)>",
            "how <font HelveticaNeue-ultralight|28>Easy</font> it is</u>.",
            "\n<font Arial|12>Edit text above and see it attributed below ",
            "</font><font Arial|22>immediately!</font>"].reduce("", +)
        demoString = str
        
        self.resetToDemoText(self)
        
        self.textArea.layer.cornerRadius = 5
        self.textArea.layer.masksToBounds = true
        self.hideKeyboard.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doHideKeyboard(sender: AnyObject) {
        self.view.endEditing(false)
    }

    func textViewDidChange(textView: UITextView) {
        self.label.attributedText = AKAttributeKit.parseString(textView.text)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        // Show cancel button
        self.hideKeyboard.hidden = false
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        // Hide cancel button
        self.hideKeyboard.hidden = true
    }
    
    @IBAction func resetToDemoText(sender: AnyObject) {
        self.textArea.text = demoString
        self.label.attributedText = AKAttributeKit.parseString(demoString)
    }
    
    
    
}


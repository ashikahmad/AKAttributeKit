//
//  ViewController.swift
//  AKAttributeKit
//
//  Created by Ashik uddin Ahmad on 09/24/2015.
//  Copyright (c) 2015 Ashik uddin Ahmad. All rights reserved.
//

import UIKit
import AKAttributeKit

class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var previewText: UITextView!
    @IBOutlet weak var hideKeyboard: UIButton!
    
    var demoString:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let str = ["This is a <fg #f00>demo</fg> \nwhere ",
            "<bg 0xaabbccdd><fg #ff0)> you </fg></bg> can see ",
            "<u \(NSUnderlineStyle.styleDouble.rawValue|NSUnderlineStyle.patternDot.rawValue)>",
            "how <font HelveticaNeue-ultralight|28>Easy</font> it is</u>.",
            "\n<font Arial|12>Edit text above and see it attributed below ",
            "</font><font Arial|22>immediately!</font>\n",
            "By the way, it supports <a http://google.com>link</a> too"].reduce("", +)
        demoString = str
        
        self.resetToDemoText(self)
        
        self.textArea.layer.cornerRadius = 5
        self.textArea.layer.masksToBounds = true
        self.hideKeyboard.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doHideKeyboard(_ sender: AnyObject) {
        self.view.endEditing(false)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.previewText.attributedText = AKAttributeKit.parseString(textView.text)
        self.previewText.textAlignment = NSTextAlignment.center
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Show cancel button
        self.hideKeyboard.isHidden = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // Hide cancel button
        self.hideKeyboard.isHidden = true
    }
    
    @IBAction func resetToDemoText(_ sender: AnyObject) {
        self.textArea.text = demoString
        self.previewText.attributedText = AKAttributeKit.parseString(demoString)
        self.previewText.textAlignment = NSTextAlignment.center
    }
    
}


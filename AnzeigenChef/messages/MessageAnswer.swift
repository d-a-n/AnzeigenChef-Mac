//
//  MessageAnswer.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 15.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Cocoa

class MessageAnswer: NSWindowController {

    
    @IBOutlet var messageField: NSTextView!
   
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    convenience init(){
        self.init(windowNibName: "MessageAnswer")
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseCancel)
    }
    
    @IBAction func okAction(sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseOK)
    }
}

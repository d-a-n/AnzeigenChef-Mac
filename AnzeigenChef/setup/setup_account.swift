//
//  setup_account.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 02.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Cocoa

class setup_account: NSWindowController,NSTextFieldDelegate {

    @IBOutlet var txt_username: NSTextField!
    @IBOutlet var txt_password: NSSecureTextField!
    @IBOutlet var txt_accounttype: NSPopUpButton!
    @IBOutlet var saveButton: NSButton!
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    convenience init(){
        self.init(windowNibName: "setup_account")
    }
    
    
    @IBAction func okaction(sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseOK)
    }
    
    @IBAction func cancelaction(sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseCancel)
    }
    
    /* Check for empty username or password to disable save button... */
    override func controlTextDidChange(obj: NSNotification){
        if (txt_username.stringValue=="" || txt_password.stringValue==""){
            saveButton.enabled = false
        } else {
            saveButton.enabled = true
        }
    }
    
    
    @IBAction func selectType(sender: AnyObject) {
        // println(txt_accounttype.selectedItem?.tag);
    }
}

//
//  foldercontroller.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 04.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Cocoa

class foldercontroller: NSWindowController,NSTextFieldDelegate {

    @IBOutlet var cancelButton: NSButton!
    @IBOutlet var saveButton: NSButton!
    @IBOutlet var folderNameEdit: NSTextField!
    @IBOutlet var labelParent: NSTextField!
    
    var currentData : String!
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    convenience init(){
        self.init(windowNibName: "foldercontroller");
    }
    
    override func awakeFromNib() {
        self.folderNameEdit.stringValue = currentData
    }
    
    @IBAction func savebuttonaction(sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseOK)
    }
    
    @IBAction func cancelbuttonaction(sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseCancel)
    }
    
    /* Check for empty foldername to disable save button... */
    override func controlTextDidChange(obj: NSNotification){
        if (folderNameEdit.stringValue==""){
            saveButton.enabled = false
        } else {
            saveButton.enabled = true
        }
    }
}

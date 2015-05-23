//
//  picselect.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 23.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Cocoa

class picselect: NSWindowController {

    
    @IBOutlet var pic1: myimageview!
    @IBOutlet var pic2: myimageview!
    @IBOutlet var pic3: myimageview!
    @IBOutlet var pic4: myimageview!
    @IBOutlet var pic5: myimageview!
    @IBOutlet var pic6: myimageview!
    @IBOutlet var pic7: myimageview!
    @IBOutlet var pic8: myimageview!
    @IBOutlet var pic9: myimageview!
    @IBOutlet var pic10: myimageview!
    @IBOutlet var pic11: myimageview!
    @IBOutlet var pic12: myimageview!
    @IBOutlet var pic13: myimageview!
    @IBOutlet var pic14: myimageview!
    @IBOutlet var pic15: myimageview!
    @IBOutlet var pic16: myimageview!
    @IBOutlet var pic17: myimageview!
    @IBOutlet var pic18: myimageview!
    @IBOutlet var pic19: myimageview!
    @IBOutlet var pic20: myimageview!
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    convenience init(){
        self.init(windowNibName: "picselect")
    }

    
    @IBAction func okButtonAction(sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseOK)
    }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseCancel)
    }
}

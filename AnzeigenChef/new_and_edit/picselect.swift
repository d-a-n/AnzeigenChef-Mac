//
//  picselect.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 23.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Cocoa

class picselect: NSWindowController {

    var picload : NSMutableArray = []
    
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
    
    override func awakeFromNib() {
        self.loadPics()
    }
    
    

    func loadPics(){
        for var i = 0; i < self.picload.count; ++i {
            let fname : String = self.picload[i] as! String
            if i == 0 {
                self.pic1.loadPicFromFile(fname)
            }
            if i == 1 {
                self.pic2.loadPicFromFile(fname)
            }
            if i == 2 {
                self.pic3.loadPicFromFile(fname)
            }
            if i == 3 {
                self.pic4.loadPicFromFile(fname)
            }
            if i == 4 {
                self.pic5.loadPicFromFile(fname)
            }
            if i == 5 {
                self.pic6.loadPicFromFile(fname)
            }
            if i == 6 {
                self.pic7.loadPicFromFile(fname)
            }
            if i == 7 {
                self.pic8.loadPicFromFile(fname)
            }
            if i == 8 {
                self.pic9.loadPicFromFile(fname)
            }
            if i == 9 {
                self.pic10.loadPicFromFile(fname)
            }
            if i == 10 {
                self.pic11.loadPicFromFile(fname)
            }
            if i == 11 {
                self.pic12.loadPicFromFile(fname)
            }
            if i == 12 {
                self.pic13.loadPicFromFile(fname)
            }
            if i == 13 {
                self.pic14.loadPicFromFile(fname)
            }
            if i == 14 {
                self.pic15.loadPicFromFile(fname)
            }
            if i == 15 {
                self.pic16.loadPicFromFile(fname)
            }
            if i == 16 {
                self.pic17.loadPicFromFile(fname)
            }
            if i == 17 {
                self.pic18.loadPicFromFile(fname)
            }
            if i == 18 {
                self.pic19.loadPicFromFile(fname)
            }
            if i == 19 {
                self.pic20.loadPicFromFile(fname)
            }
        }
    }
    
    
    @IBAction func okButtonAction(sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseOK)
        self.window?.close()
    }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseCancel)
        self.window?.close()
    }
}

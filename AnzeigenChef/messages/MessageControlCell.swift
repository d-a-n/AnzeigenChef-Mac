//
//  MessageControlCell.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 12.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Cocoa

class MessageControlCell: NSTableCellView {
    
    @IBOutlet var l1 : NSTextField!
    @IBOutlet var l1_right : NSTextField!
    @IBOutlet var l2 : NSTextField!
    @IBOutlet var rbimage : NSImageView!
    
    var defaultText_l1_color = NSColor.selectedMenuItemColor()
    var defaultText_l1_right_color = NSColor.grayColor()
    var defaultText_l2_color = NSColor.blackColor()
 
    
    override var backgroundStyle: NSBackgroundStyle {
        
        set {
            if let rowView = self.superview as? NSTableRowView {
                
                var focus = false
                if let tableView = self.superview?.superview as? NSTableView {
                    focus = (tableView.isEqual(tableView.window?.firstResponder))
                }
                
                if rowView.selected && focus {
                    self.l1.textColor = NSColor.highlightColor()
                    self.l1_right.textColor = NSColor.highlightColor()
                    self.l2.textColor = NSColor.highlightColor()
                } else {
                    self.l1.textColor = defaultText_l1_color
                    self.l1_right.textColor = defaultText_l1_right_color
                    self.l2.textColor = defaultText_l2_color
                }
            }
        }
        get {
            return super.backgroundStyle;
        }
    }
     
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        
    }
    

    
    
    
}

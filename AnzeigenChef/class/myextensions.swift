//
//  myextensions.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 07.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Foundation
import Cocoa

extension String
{
    func html_decode() -> String {
        let encodedData = self.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]
        let attributedString = NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil, error: nil)!
        let decodedString = attributedString.string
        return decodedString
    }
    
    func contains(s: String) -> Bool
    {
        return (self.rangeOfString(s) != nil) ? true : false
    }
    
    func indexOf(target: String) -> Int
    {
        var range = self.rangeOfString(target)
        if let range = range {
            return distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    func indexOf(target: String, startIndex: Int) -> Int
    {
        var startRange = advance(self.startIndex, startIndex)
        
        var range = self.rangeOfString(target, options: NSStringCompareOptions.LiteralSearch, range: Range<String.Index>(start: startRange, end: self.endIndex))
        
        if let range = range {
            return distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    func subString(startIndex: Int, length: Int) -> String
    {
        var start = advance(self.startIndex, startIndex)
        var end = advance(self.startIndex, startIndex + length)
        return self.substringWithRange(Range<String.Index>(start: start, end: end))
    }
    
    func getstring(beginStr : String, endStr : String) -> String{
        var sindex = self.indexOf(beginStr)
        if (sindex > -1){
            var sindex = sindex + count(beginStr)
            if (endStr == ""){
                return self.subString(sindex, length: count(self)-sindex)
            }
            let eindex = self.indexOf(endStr, startIndex: sindex)
            if (eindex > -1){
                return self.subString(sindex, length: eindex-sindex)
            }
        }
        return ""
    }
    
    func quotedstring() -> String{
        var escapedString = self.stringByReplacingOccurrencesOfString("'",
            withString: "''",
            options: .LiteralSearch,
            range: nil)
        return "'\(escapedString)\'"
    }
    
    func encodeURL() -> String{
        var escapedString = self.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        return escapedString!
    }
    
    func cleanToInt() -> String {
        var buffer = ""
        let intarray : NSArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        
        for character in self {
            if intarray.containsObject("\(character)"){
                buffer.append(character)
            }
        }
        
        if buffer == "" {
            buffer = "0"
        }
        return buffer
    }
    
    func cleanToPhone() -> String {
        var buffer = ""
        let intarray : NSArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "+", "/", "-", "(", ")"]
        
        for character in self {
            if intarray.containsObject("\(character)"){
                buffer.append(character)
            }
        }
        
        
        return buffer
    }
    
    
}


extension NSIndexSet {
    func toArray() -> [Int] {
        var indexes:[Int] = [];
        self.enumerateIndexesUsingBlock { (index:Int, _) in
            indexes.append(index);
        }
        return indexes;
    }
}
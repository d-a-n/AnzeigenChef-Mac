//
//  myextensions.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 07.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Foundation

/* https://gist.github.com/albertbori/0faf7de867d96eb83591 */
extension String
{
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
            let eindex = self.indexOf(endStr, startIndex: sindex)
            if (eindex > -1){
                return self.subString(sindex, length: eindex-sindex)
            }
        }
        return ""
    }
}

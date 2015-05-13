//
//  httpcl.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 06.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Foundation



class httpcl{
    
    
    func check_ebay_account(username : String, password : String)->Bool {
        
        var reponseError: NSError?
        var response: NSURLResponse?
        
        var ebayUrl = NSURL(string: "https://kleinanzeigen.ebay.de/anzeigen/m-einloggen.html")
        
        var request = NSMutableURLRequest(URL: ebayUrl! )
        
        var urlData2: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData2 != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData2!, encoding:NSUTF8StringEncoding)!
            } else {
                return false
            }
        }
        
        
        var targetURI = NSString(string: "/m-meine-anzeigen.html?vl=6066").stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        
        var stringPost="targetUrl="+targetURI!
        stringPost+="&loginMail="+username
        stringPost+="&password="+password
        let data = stringPost.dataUsingEncoding(NSASCIIStringEncoding)
        
        request.HTTPMethod = "POST"
        request.timeoutInterval = 60
        request.HTTPBody=data
        request.HTTPShouldHandleCookies=true
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                if responseData.containsString("m-abmelden.html"){
                    return true
                }
            }
        }
        
        return false
    }
    
    func shortlist_ebay_account(username : String, password : String)->NSArray {
        var reponseError: NSError?
        var response: NSURLResponse?
        var emptyarray : NSArray = []
        
        var ebayUrl = NSURL(string: "http://kleinanzeigen.ebay.de/anzeigen/m-meine-anzeigen-verwalten.json")
        var request = NSMutableURLRequest(URL: ebayUrl! )
        
        var urlData2: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData2 != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData2!, encoding:NSUTF8StringEncoding)!
                var xdata: NSData = responseData.dataUsingEncoding(NSUTF8StringEncoding)!
                var err: NSError?
                if let jsonobj : AnyObject = NSJSONSerialization.JSONObjectWithData(xdata, options: .MutableLeaves, error: &err) {
                    if let json : NSDictionary = jsonobj as? NSDictionary {
                        
                        if ((json["ads"]) != nil){
                            let ads : NSArray = json["ads"] as! NSArray
                            return ads
                        }
                    }
                } else {
                    println("Could not parse JSON: \(err!)" + "<br/><br/>" + (responseData as String))
                    return emptyarray
                }
                
            } else {
                return emptyarray
            }
        }
        return emptyarray
    }
    
    func conversation_ebay(username : String, password : String) ->NSArray{
        var reponseError: NSError?
        var response: NSURLResponse?
        var emptyarray : NSArray = []
       
        var ebayUrl = NSURL(string: "http://kleinanzeigen.ebay.de/anzeigen/m-konversationen-uebersicht.json?vl=9526")
        var request = NSMutableURLRequest(URL: ebayUrl! )
 
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                var xdata: NSData = responseData.dataUsingEncoding(NSUTF8StringEncoding)!
                var err: NSError?
                
                if let jsonobj : AnyObject = NSJSONSerialization.JSONObjectWithData(xdata, options: .MutableLeaves, error: &err) {
                    if let json : NSDictionary = jsonobj as? NSDictionary {
                        if ((json["conversations"]) != nil){
                            let messages : NSArray = json["conversations"] as! NSArray
                            return messages
                        }
                    }
                } else {
                    println("Could not parse JSON: \(err!)" + "<br/><br/>" + (responseData as String))
                    return emptyarray
                }
            }
        }
        return emptyarray
    }
    
    
    
    func conversation_detail_ebay(username : String, password : String, cid : String) ->NSArray{
        var reponseError: NSError?
        var response: NSURLResponse?
        var emptyarray : NSArray = []
        
        var ebayUrl = NSURL(string: "http://kleinanzeigen.ebay.de/anzeigen/m-konversation.json?id=" + cid)
        var request = NSMutableURLRequest(URL: ebayUrl! )

        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                var xdata: NSData = responseData.dataUsingEncoding(NSUTF8StringEncoding)!
                var err: NSError?
                if let jsonobj : AnyObject = NSJSONSerialization.JSONObjectWithData(xdata, options: .MutableLeaves, error: &err) {
                    if let json : NSDictionary = jsonobj as? NSDictionary {
                        
                        if ((json["messages"]) != nil){
                            let messages : NSArray = json["messages"] as! NSArray
                            return messages
                        }
                    }
                } else {
                    println("Could not parse JSON: \(err!)" + "<br/><br/>" + (responseData as String))
                    return emptyarray
                }
            }
        }
        return emptyarray
    }
    
 
    
    func logout_ebay_account() -> Bool{
        var reponseError: NSError?
        var response: NSURLResponse?
        var ebayUrl = NSURL(string: "https://kleinanzeigen.ebay.de/anzeigen/m-abmelden.html")
        var request = NSMutableURLRequest(URL: ebayUrl! )
        
        var urlData2: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData2 != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData2!, encoding:NSUTF8StringEncoding)!
            } else {
                return false
            }
        }
        
        return true
    }
}
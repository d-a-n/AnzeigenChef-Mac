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
                    self.logout_ebay_account()
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
        
        var ebayUrl = NSURL(string: "https://kleinanzeigen.ebay.de/anzeigen/m-einloggen.html")
        
        var request = NSMutableURLRequest(URL: ebayUrl! )
        
        var urlData2: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData2 != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData2!, encoding:NSUTF8StringEncoding)!
            } else {
                return emptyarray
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
                // println(responseData)
                if responseData.containsString("m-abmelden.html"){
                    let jsonstr = (responseData as String).getstring("var adsAsJson = ",endStr: "Belen.My.ManageAdsView")
                    var xdata: NSData = jsonstr.dataUsingEncoding(NSUTF8StringEncoding)!
                    var err: NSError?
                    var json : NSDictionary = (NSJSONSerialization.JSONObjectWithData(xdata, options: .MutableLeaves, error: &err) as? NSDictionary)!
                    if ((json["ads"]) != nil){
                        let ads : NSArray = json["ads"] as! NSArray
                        self.logout_ebay_account()
                        return ads
                        /*
                        for var i=0; i<ads.count; ++i{
                            if (ads[i] is NSDictionary){
                                println(ads[i]["title"])
                            }
                        }
                        */
                    }
                }
            }
        }
        
        return emptyarray
        
        
        /*
        var session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler:
        { data, response, error -> Void in
        if((error) != nil) {
        println(error.localizedDescription)
        }
        var strData = NSString(data: data, encoding: NSASCIIStringEncoding)
        
        println(strData)
        }
        )
        task.resume()
        */
        
        
    }
    
    func conversation_ebay(username : String, password : String) ->NSArray{
        /* http://kleinanzeigen.ebay.de/anzeigen/m-konversationen-uebersicht.json?vl=9526 */
        
        var reponseError: NSError?
        var response: NSURLResponse?
        var emptyarray : NSArray = []
        
        var ebayUrl = NSURL(string: "https://kleinanzeigen.ebay.de/anzeigen/m-einloggen.html")
        
        var request = NSMutableURLRequest(URL: ebayUrl! )
        
        var urlData2: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData2 != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData2!, encoding:NSUTF8StringEncoding)!
            } else {
                return emptyarray
            }
        }
        
        
        var targetURI = NSString(string: "/m-konversationen-uebersicht.json?vl=9526").stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        
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
                var xdata: NSData = responseData.dataUsingEncoding(NSUTF8StringEncoding)!
                var err: NSError?
                var json : NSDictionary = (NSJSONSerialization.JSONObjectWithData(xdata, options: .MutableLeaves, error: &err) as? NSDictionary)!
                if ((json["conversations"]) != nil){
                    let ads : NSArray = json["conversations"] as! NSArray
                    self.logout_ebay_account()
                    return ads
                }
            }
        }
        
        return emptyarray
    }
    
    
    
    func conversation_detail_ebay_html(username : String, password : String, cid : String) ->String{
        var reponseError: NSError?
        var response: NSURLResponse?
        var emptyarray : NSArray = []
        
        var ebayUrl = NSURL(string: "https://kleinanzeigen.ebay.de/anzeigen/m-einloggen.html")
        
        var request = NSMutableURLRequest(URL: ebayUrl! )
        
        var urlData2: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData2 != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData2!, encoding:NSUTF8StringEncoding)!
            } else {
                return ""
            }
        }
        
        
        var targetURI = NSString(string: "/m-konversation.json?id="+cid).stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        
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
            self.logout_ebay_account()
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                var xdata: NSData = responseData.dataUsingEncoding(NSUTF8StringEncoding)!
                var err: NSError?
                if let jsonobj : AnyObject = NSJSONSerialization.JSONObjectWithData(xdata, options: .MutableLeaves, error: &err) {
                    if let json : NSDictionary = jsonobj as? NSDictionary {
                        var htmlstring : String = "<html>\n<head>\n<style>\n"
                        htmlstring += "body{ background-color: #F0F0F0; }\n"
                        htmlstring += ".div1{ font-family: Arial, Helvetica, sans-serif; font-size: 12px; -webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale; background-color: #87b919; padding: 5; color: #FFFFFF; width: 90%; border-radius: 3px; box-sizing: border-box; -moz-box-sizing: border-box; -webkit-box-sizing: border-box; margin-left: 30px}\n"
                        htmlstring += ".div2{ font-family: Arial, Helvetica, sans-serif; font-size: 12px; -webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale; background-color: #FFFFFF; padding: 5; color: #000000; width: 90%; border-radius: 3px; box-sizing: border-box; -moz-box-sizing: border-box; -webkit-box-sizing: border-box;}\n"
                        htmlstring += "</style>\n</head>\n"
                        htmlstring += "<body>"
                        
                        if ((json["messages"]) != nil){
                            let messages : NSArray = json["messages"] as! NSArray
                            var currentcolor = ""
                            for var i=0; i<messages.count; ++i{
                                if ((messages[i]["boundness"] as! String) == "OUTBOUND"){
                                    htmlstring += "<div class=\"div1\">"
                                } else {
                                    htmlstring += "<div class=\"div2\">"
                                }
                                
                                if (messages[i]["receivedDate"] != nil){
                                    var date = NSDate(timeIntervalSince1970:(NSString(string: (messages[i]["receivedDate"] as AnyObject?)!.stringValue)).doubleValue/1000)
                                    var dateFormatter = NSDateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    var receivedDate = dateFormatter.stringFromDate(date)
                                    htmlstring += receivedDate + "<br/>"
                                }
                                
                                htmlstring += (messages[i]["textShort"] as! String).stringByReplacingOccurrencesOfString("\n", withString: "<br/>", options: nil, range: nil)
                                htmlstring += "</div><div style=\"height: 15px\"></div>"
                            }
                        }
                        
                        htmlstring += "</body>"
                        htmlstring += "</html>"
                        return htmlstring as String
                    }
                } else {
                    return "Could not parse JSON: \(err!)" + "<br/><br/>" + (responseData as String)
                }
                
            }
        }
        
        return ""
        
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
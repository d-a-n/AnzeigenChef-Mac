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
        
        var stringPost="";
        stringPost+="targetUrl="+targetURI!
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
                        for var i=0; i<ads.count; ++i{
                            if (ads[i] is NSDictionary){
                                println(ads[i]["title"])
                            }
                        }
                    }
                    return true
                }
            }
        }
        
        return false
 
        
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
}
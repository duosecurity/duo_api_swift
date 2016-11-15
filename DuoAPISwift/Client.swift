//
//  Client.swift
//  DuoAPISwift
//
//  Created by James Barclay on 7/22/16.
//  Copyright © 2016 Duo Security. All rights reserved.
//

import Foundation

public class Client: NSObject {
    let ikey: String
    let skey: String
    let host: String
    var userAgent: String
    
    required public init(ikey: String,
                         skey: String,
                         host: String,
                         userAgent: String = "Duo API Swift/\(DuoAPISwiftVersionNumber)") {
        self.ikey = ikey
        self.skey = skey
        self.host = host
        self.userAgent = userAgent
    }
    
    func makeRequest(method: String, uri: String, headers: Dictionary<String, String>, body: String, completion: (NSData, NSHTTPURLResponse?) -> ()) {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = headers
        let session = NSURLSession(
            configuration: config,
            delegate: NSURLSessionPinningDelegate(),
            delegateQueue: nil)
        let url = NSURL(string: "https://\(self.host)\(uri)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = method
        if body != "" {
            request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        }
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in

            if error != nil {
                print("Error making request: \(error?.localizedDescription)")
                return
            } else if let httpResponse = response as? NSHTTPURLResponse {
                completion(data!, httpResponse)
            } else {
                completion(data!, nil)
            }
        }
        task.resume()
    }
    
    /*
        params should either be Dictionary<String, String> or Dictionary<String, [String]>.
     */
    func duoAPICall(method: String, path: String, params: Dictionary<String, AnyObject>, completion: (NSData, NSHTTPURLResponse?) -> ()) {
        let now = Util.rfc2822Date(NSDate())
        let normalizedParams: Dictionary<String, [String]> = Util.normalizeParams(params)
        let authHeader = Util.basicAuth(self.ikey,
                                        skey: self.skey,
                                        method: method,
                                        host: self.host,
                                        path: path,
                                        dateString: now,
                                        params: normalizedParams)
        let canonicalizedParams: String = Util.canonicalizeParams(normalizedParams)
        var body: String = ""
        var uri: String = ""
        var headers = [
            "Authorization": authHeader,
            "Date": now,
            "Host": self.host,
            "User-Agent": self.userAgent
        ]
        if ["POST", "PUT"].contains(method) {
            headers["Content-Type"] = "application/x-www-form-urlencoded"
            body = canonicalizedParams
            uri = path
        } else {
            uri = canonicalizedParams != "" ? "\(path)?\(canonicalizedParams)" : path
        }
        
        // Do the request.
        self.makeRequest(method, uri: uri, headers: headers, body: body, completion: completion)
    }
    
    /*
        params should either be Dictionary<String, String> or Dictionary<String, [String]>.
     */
    func duoJSONAPICall(method: String,
                        path: String,
                        params: Dictionary<String, AnyObject>,
                        completion: AnyObject -> ()) {
        self.duoAPICall(method, path: path, params: params, completion: {
            (let data, let httpResponse) in

            let parsedJSON = self.parseJSONResponse(data)
            completion(parsedJSON)
        })
    }
    
    func parseJSONResponse(data: NSData) -> AnyObject {
        var json: AnyObject = [:]
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            if let stat = json["stat"] as? String {
                if stat == "FAIL" {
                    if let messageDetail = json["message_detail"] as? String {
                        print("Received \(json["message"] as! String) (\(messageDetail))")
                    } else {
                        print("Received \(json["message"] as! String)")
                    }
                }
            } else {
                print("Received bad response: \(json)")
            }
        } catch let JSONError {
            print("Error serializing JSON: \(JSONError)")
        }
        return json
    }
}

//
//  Client.swift
//  DuoAPISwift
//
//  Created by James Barclay on 7/22/16.
//  Copyright © 2016 Duo Security. All rights reserved.
//

import Foundation

open class Client: NSObject {
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
    
    func makeRequest(_ method: String,
                       uri: String,
                       headers: Dictionary<String, String>,
                       body: String,
                       completion: @escaping (Data, HTTPURLResponse?) -> ()) {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = headers
        let session = URLSession(
            configuration: config,
            delegate: NSURLSessionPinningDelegate(),
            delegateQueue: nil)
        let url = URL(string: "https://\(self.host)\(uri)")
        var request = URLRequest.init(url: url!)
        request.httpMethod = method
        if body != "" {
            request.httpBody = body.data(using: String.Encoding.utf8)
        }
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in

            if error != nil {
                print("Error making request: \(error?.localizedDescription)")
                return
            } else if let httpResponse = response as? HTTPURLResponse {
                completion(data!, httpResponse)
            } else {
                completion(data!, nil)
            }
        })
        task.resume()
    }
    
    /*
        params should either be Dictionary<String, String> or Dictionary<String, [String]>.
     */
    func duoAPICall(_ method: String, path: String, params: Dictionary<String, AnyObject>, completion: @escaping (Data, HTTPURLResponse?) -> ()) {
        let now = Util.rfc2822Date(Date())
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
    func duoJSONAPICall(_ method: String,
                          path: String,
                          params: Dictionary<String, AnyObject>,
                          completion: @escaping (AnyObject) -> ()) {
        self.duoAPICall(method, path: path, params: params, completion: {
            (data, httpResponse) in

            let parsedJSON = self.parseJSONResponse(data)
            completion(parsedJSON)
        })
    }
    
    func parseJSONResponse(_ data: Data) -> AnyObject {
        var json = [:] as AnyObject
        do {
            json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
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

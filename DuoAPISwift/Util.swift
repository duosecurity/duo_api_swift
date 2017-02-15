//
//  Util.swift
//  DuoAPISwift
//
//  Created by James Barclay on 7/22/16.
//  Copyright © 2016 Duo Security. All rights reserved.
//

import Foundation

class Util: NSObject {
    /*
        Return a date string that conforms to the format described in RFC 2822.
     
        https://www.ietf.org/rfc/rfc2822.txt
     */
    class func rfc2822Date(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    /*
        Return copy of params with string listified and unicode strings utf-8 encoded.
        params should either be Dictionary<String, String> or Dictionary<String, [String]>.
     */
    class func normalizeParams(_ params: Dictionary<String, Any>) -> Dictionary<String, [String]> {
        var params = params
        var result: Dictionary<String, [String]> = [:]
        
        for (key, values) in params {
            // normalize values to String arrays
            if let values = values as? String {
                params[key] = [values]
            }
            
            // utf8 encode the values
            var values: [String] = []
            for value in params[key] as! [String] {
                values.append(value.toUTF8())
            }
            result[key.toUTF8()] = values
        }
        return result
    }
    
    /*
        Return a canonical string version of the given request parameters.
     */
    class func canonicalizeParams(_ params: Dictionary<String, [String]>) -> String {
        var firstOneAdded = false
        var paramsAsString: String = ""
        let contentKeys: Array<String> = Array(params.keys).sorted(by: {
            $0.compare($1, options: NSString.CompareOptions.literal) == ComparisonResult.orderedAscending
        })
        
        for contentKey in contentKeys {
            let contentValues: Array<String> = params[contentKey]!
            let sortedValues = contentValues.sorted(by: {
                $0.compare($1, options: NSString.CompareOptions.literal) == ComparisonResult.orderedAscending
            })
            
            for value in sortedValues {
                if (!firstOneAdded) {
                    paramsAsString += contentKey.stringByAddingPercentEncodingForRFC3986()! + "=" + (value.stringByAddingPercentEncodingForRFC3986())!
                    firstOneAdded = true
                } else {
                    paramsAsString += "&" + contentKey.stringByAddingPercentEncodingForRFC3986()! + "=" + (value.stringByAddingPercentEncodingForRFC3986())!
                }
            }
        }
        return paramsAsString
    }
    
    /*
        Return signature version 2 canonical string of given request attributes.
     */
    class func canonicalize(_ method: String,
                              host: String,
                              path: String,
                              params: Dictionary<String, [String]>,
                              dateString: String) -> String {
        let canonicalHeaders = [
            dateString, method.uppercased(),
            host.lowercased(), path,
            self.canonicalizeParams(params)]
        return canonicalHeaders.joined(separator: "\n")
    }
    
    /*
        Return basic authorization header line with a Duo Web API signature.
     */
    class func basicAuth(_ ikey: String,
                           skey: String,
                           method: String,
                           host: String,
                           path: String,
                           dateString: String,
                           params: Dictionary<String, [String]>) -> String {
        // Create the canonical string.
        let canonicalHeadersString = canonicalize(method, host: host, path: path, params: params, dateString: dateString)
        
        // Sign the canonical string.
        let signatureHexDigest = canonicalHeadersString.hmac(CryptoAlgorithm.sha1, key: skey)
        let authHeader = "\(ikey):\(signatureHexDigest)"
        let base64EncodedAuthHeader = authHeader.toBase64()
        return "Basic \(base64EncodedAuthHeader)"
    }
}

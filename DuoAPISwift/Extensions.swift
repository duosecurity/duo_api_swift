//
//  Extensions.swift
//  DuoAPISwift
//
//  Created by James Barclay on 7/25/16.
//  Copyright © 2016 Duo Security. All rights reserved.
//

import Foundation

enum CryptoAlgorithm {
    case md5, sha1, sha224, sha256, sha384, sha512
    
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
            case .md5:      result = kCCHmacAlgMD5
            case .sha1:     result = kCCHmacAlgSHA1
            case .sha224:   result = kCCHmacAlgSHA224
            case .sha256:   result = kCCHmacAlgSHA256
            case .sha384:   result = kCCHmacAlgSHA384
            case .sha512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
            case .md5:      result = CC_MD5_DIGEST_LENGTH
            case .sha1:     result = CC_SHA1_DIGEST_LENGTH
            case .sha224:   result = CC_SHA224_DIGEST_LENGTH
            case .sha256:   result = CC_SHA256_DIGEST_LENGTH
            case .sha384:   result = CC_SHA384_DIGEST_LENGTH
            case .sha512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

// MARK: - String utils and helpers
extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
    
    func hmac(_ algorithm: CryptoAlgorithm, key: String) -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        let digest = stringFromResult(result, length: digestLen)
        result.deallocate()
        return digest
    }
    
    fileprivate func stringFromResult(_ result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", result[i])
        }
        return String(hash)
    }
    
    func toUTF8() -> String {
        return String(bytes: [UInt8](self.utf8), encoding: String.Encoding.utf8)!
    }
    
    /*
        Base64 encode a string.
     */
    func toBase64() -> String {
        let data = self.data(using: String.Encoding.utf8)
        return data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
}

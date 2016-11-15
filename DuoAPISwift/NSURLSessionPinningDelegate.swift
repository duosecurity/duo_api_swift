//
//  NSURLSessionPinningDelegate.swift
//  DuoAPISwift
//
//  Created by James Barclay on 10/12/16.
//  Copyright © 2016 Duo Security. All rights reserved.
//

import Foundation
import Security

class NSURLSessionPinningDelegate: NSObject, NSURLSessionDelegate {

    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {

        // Adapted from OWASP https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#iOS

        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secresult = SecTrustResultType.Invalid
                let status = SecTrustEvaluate(serverTrust, &secresult)

                if (status == errSecSuccess) {
                    let count = SecTrustGetCertificateCount(serverTrust)
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, count - 1) {
                        let serverCertificateData: CFDataRef = SecCertificateCopyData(serverCertificate)
                        let data = CFDataGetBytePtr(serverCertificateData)
                        let size = CFDataGetLength(serverCertificateData)
                        let receivedCert = NSData(bytes: data, length: size)
                        if let frameworkBundle = NSBundle(identifier: "com.duosecurity.DuoAPISwift") {
                            let trustedCACertificates = frameworkBundle.pathsForResourcesOfType("der", inDirectory: "Resources")
                            for cert in trustedCACertificates {
                                if let expectedCert = NSData(contentsOfFile: cert) {
                                    if receivedCert.isEqualToData(expectedCert) {
                                        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust:serverTrust))
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        // Pinning failed
        completionHandler(NSURLSessionAuthChallengeDisposition.CancelAuthenticationChallenge, nil)
    }
}

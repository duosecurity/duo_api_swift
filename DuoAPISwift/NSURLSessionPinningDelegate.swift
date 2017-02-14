//
//  NSURLSessionPinningDelegate.swift
//  DuoAPISwift
//
//  Created by James Barclay on 10/12/16.
//  Copyright © 2016 Duo Security. All rights reserved.
//

import Foundation
import Security

class NSURLSessionPinningDelegate: NSObject, URLSessionDelegate {

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        // Adapted from OWASP https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#iOS

        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                var secresult = SecTrustResultType.invalid
                let status = SecTrustEvaluate(serverTrust, &secresult)

                if (status == errSecSuccess) {
                    let count = SecTrustGetCertificateCount(serverTrust)
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, count - 1) {
                        let serverCertificateData: CFData = SecCertificateCopyData(serverCertificate)
                        let data = CFDataGetBytePtr(serverCertificateData)
                        let size = CFDataGetLength(serverCertificateData)
                        let receivedCert = Data(bytes: UnsafePointer<UInt8>(data!), count: size)
                        if let frameworkBundle = Bundle(identifier: "com.duosecurity.DuoAPISwift") {
                            let trustedCACertificates = frameworkBundle.paths(forResourcesOfType: "der", inDirectory: "Resources")
                            for cert in trustedCACertificates {
                                if let expectedCert = try? Data(contentsOf: URL(fileURLWithPath: cert)) {
                                    if receivedCert == expectedCert {
                                        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
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
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }
}

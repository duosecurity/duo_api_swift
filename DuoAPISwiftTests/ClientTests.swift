//
//  ClientTests.swift
//  DuoAPISwift
//
//  Created by Mark Lee on 8/10/16.
//  Copyright © 2022 Cisco Systems, Inc. and/or its affiliates. All rights reserved.
//

import XCTest
@testable import DuoAPISwift

class QueryParameterTests: XCTestCase {
    
    func assertCanonParams(_ params: Dictionary<String, [String]>, expected: String) {
        XCTAssertEqual(Util.canonicalizeParams(Util.normalizeParams(params)), expected)
    }

    func testZeroParams() {
        assertCanonParams([:], expected: "")
    }
    
    func testOneParam() {
        assertCanonParams([ "realname": ["First Last"] ], expected: "realname=First%20Last")
    }
    
    func testTwoParams() {
        assertCanonParams([ "realname": ["First Last"], "username": ["root"] ], expected: "realname=First%20Last&username=root")
    }
    
    func testPrintableAsciiCharacters() {
        let params: Dictionary<String, [String]> = [
            "digits": ["0123456789"],
            "letters": ["abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"],
            "punctuation": ["!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"],
            "whitespace": ["\t\n\u{B}\u{C}\r "]
        ]
        let expected = "digits=0123456789&letters=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ&punctuation=%21%22%23%24%25%26%27%28%29%2A%2B%2C-.%2F%3A%3B%3C%3D%3E%3F%40%5B%5C%5D%5E_%60%7B%7C%7D~&whitespace=%09%0A%0B%0C%0D%20"
        assertCanonParams(params, expected: expected)
    }
    
    func testUnicodeFuzzValues() {
        let params: Dictionary<String, [String]> = [
            "bar": ["\u{2815}\u{aaa3}\u{37cf}\u{4bb7}\u{36e9}\u{cc05}\u{668e}\u{8162}\u{c2bd}\u{a1f1}"],
            "baz": ["\u{0df3}\u{84bd}\u{5669}\u{9985}\u{b8a4}\u{ac3a}\u{7be7}\u{6f69}\u{934a}\u{b91c}"],
            "foo": ["\u{d4ce}\u{d6d6}\u{7938}\u{50c0}\u{8a20}\u{8f15}\u{fd0b}\u{8024}\u{5cb3}\u{c655}"],
            "qux": ["\u{8b97}\u{c846}-\u{828e}\u{831a}\u{ccca}\u{a2d4}\u{8c3e}\u{b8b2}\u{99be}"]
        ]
        let expected = "bar=%E2%A0%95%EA%AA%A3%E3%9F%8F%E4%AE%B7%E3%9B%A9%EC%B0%85%E6%9A%8E%E8%85%A2%EC%8A%BD%EA%87%B1&baz=%E0%B7%B3%E8%92%BD%E5%99%A9%E9%A6%85%EB%A2%A4%EA%B0%BA%E7%AF%A7%E6%BD%A9%E9%8D%8A%EB%A4%9C&foo=%ED%93%8E%ED%9B%96%E7%A4%B8%E5%83%80%E8%A8%A0%E8%BC%95%EF%B4%8B%E8%80%A4%E5%B2%B3%EC%99%95&qux=%E8%AE%97%EC%A1%86-%E8%8A%8E%E8%8C%9A%EC%B3%8A%EA%8B%94%E8%B0%BE%EB%A2%B2%E9%A6%BE"
        assertCanonParams(params, expected: expected)
    }

    func testUnicodeFuzzKeysAndValues() {
        let params: Dictionary<String, [String]> = [
            "\u{469a}\u{287b}\u{35d0}\u{8ef3}\u{6727}\u{502a}\u{0810}\u{d091}\u{c8}\u{c170}": ["\u{0f45}\u{1a76}\u{341a}\u{654c}\u{c23f}\u{9b09}\u{abe2}\u{8343}\u{1b27}\u{60d0}"],
            "\u{7449}\u{7e4b}\u{ccfb}\u{59ff}\u{fe5f}\u{83b7}\u{adcc}\u{900c}\u{cfd1}\u{7813}": ["\u{8db7}\u{5022}\u{92d3}\u{42ef}\u{207d}\u{8730}\u{acfe}\u{5617}\u{0946}\u{4e30}"],
            "\u{7470}\u{9314}\u{901c}\u{9eae}\u{40d8}\u{4201}\u{82d8}\u{8c70}\u{1d31}\u{a042}": ["\u{17d9}\u{0ba8}\u{9358}\u{aadf}\u{a42a}\u{48be}\u{fb96}\u{6fe9}\u{b7ff}\u{32f3}"],
            "\u{c2c5}\u{2c1d}\u{2620}\u{3617}\u{96b3}F\u{8605}\u{20e8}\u{ac21}\u{5934}": ["\u{fba9}\u{41aa}\u{bd83}\u{840b}\u{2615}\u{3e6e}\u{652d}\u{a8b5}\u{d56b}U"]
        ]
        let expected = "%E4%9A%9A%E2%A1%BB%E3%97%90%E8%BB%B3%E6%9C%A7%E5%80%AA%E0%A0%90%ED%82%91%C3%88%EC%85%B0=%E0%BD%85%E1%A9%B6%E3%90%9A%E6%95%8C%EC%88%BF%E9%AC%89%EA%AF%A2%E8%8D%83%E1%AC%A7%E6%83%90&%E7%91%89%E7%B9%8B%EC%B3%BB%E5%A7%BF%EF%B9%9F%E8%8E%B7%EA%B7%8C%E9%80%8C%EC%BF%91%E7%A0%93=%E8%B6%B7%E5%80%A2%E9%8B%93%E4%8B%AF%E2%81%BD%E8%9C%B0%EA%B3%BE%E5%98%97%E0%A5%86%E4%B8%B0&%E7%91%B0%E9%8C%94%E9%80%9C%E9%BA%AE%E4%83%98%E4%88%81%E8%8B%98%E8%B1%B0%E1%B4%B1%EA%81%82=%E1%9F%99%E0%AE%A8%E9%8D%98%EA%AB%9F%EA%90%AA%E4%A2%BE%EF%AE%96%E6%BF%A9%EB%9F%BF%E3%8B%B3&%EC%8B%85%E2%B0%9D%E2%98%A0%E3%98%97%E9%9A%B3F%E8%98%85%E2%83%A8%EA%B0%A1%E5%A4%B4=%EF%AE%A9%E4%86%AA%EB%B6%83%E8%90%8B%E2%98%95%E3%B9%AE%E6%94%AD%EA%A2%B5%ED%95%ABU"

        assertCanonParams(params, expected: expected)
    }

    func testSortOrderWithCommonPrefix() {
        let params: Dictionary<String, [String]> = [
            "foo_bar": ["2"],
            "foo": ["1"]
        ]
        assertCanonParams(params, expected: "foo=1&foo_bar=2")
    }

}

class CanonicalizeTests: XCTestCase {
    
    // Tests of the canonicalization of request attributes and parameters
    // for signing.
    
    func testV2() {
        let params: Dictionary<String, [String]> = [
            "\u{469a}\u{287b}\u{35d0}\u{8ef3}\u{6727}\u{502a}\u{0810}\u{d091}\u{c8}\u{c170}": ["\u{0f45}\u{1a76}\u{341a}\u{654c}\u{c23f}\u{9b09}\u{abe2}\u{8343}\u{1b27}\u{60d0}"],
            "\u{7449}\u{7e4b}\u{ccfb}\u{59ff}\u{fe5f}\u{83b7}\u{adcc}\u{900c}\u{cfd1}\u{7813}": ["\u{8db7}\u{5022}\u{92d3}\u{42ef}\u{207d}\u{8730}\u{acfe}\u{5617}\u{0946}\u{4e30}"],
            "\u{7470}\u{9314}\u{901c}\u{9eae}\u{40d8}\u{4201}\u{82d8}\u{8c70}\u{1d31}\u{a042}": ["\u{17d9}\u{0ba8}\u{9358}\u{aadf}\u{a42a}\u{48be}\u{fb96}\u{6fe9}\u{b7ff}\u{32f3}"],
            "\u{c2c5}\u{2c1d}\u{2620}\u{3617}\u{96b3}F\u{8605}\u{20e8}\u{ac21}\u{5934}": ["\u{fba9}\u{41aa}\u{bd83}\u{840b}\u{2615}\u{3e6e}\u{652d}\u{a8b5}\u{d56b}U"]
        ]

        let canonRequest = Util.canonicalize("PoSt",
                                             host: "foO.BAr52.cOm",
                                             path: "/Foo/BaR2/qux",
                                             params: params,
                                             dateString: "Fri, 07 Dec 2012 17:18:00 -0000")

        let expectedCanonRequest = "Fri, 07 Dec 2012 17:18:00 -0000\nPOST\nfoo.bar52.com\n/Foo/BaR2/qux\n%E4%9A%9A%E2%A1%BB%E3%97%90%E8%BB%B3%E6%9C%A7%E5%80%AA%E0%A0%90%ED%82%91%C3%88%EC%85%B0=%E0%BD%85%E1%A9%B6%E3%90%9A%E6%95%8C%EC%88%BF%E9%AC%89%EA%AF%A2%E8%8D%83%E1%AC%A7%E6%83%90&%E7%91%89%E7%B9%8B%EC%B3%BB%E5%A7%BF%EF%B9%9F%E8%8E%B7%EA%B7%8C%E9%80%8C%EC%BF%91%E7%A0%93=%E8%B6%B7%E5%80%A2%E9%8B%93%E4%8B%AF%E2%81%BD%E8%9C%B0%EA%B3%BE%E5%98%97%E0%A5%86%E4%B8%B0&%E7%91%B0%E9%8C%94%E9%80%9C%E9%BA%AE%E4%83%98%E4%88%81%E8%8B%98%E8%B1%B0%E1%B4%B1%EA%81%82=%E1%9F%99%E0%AE%A8%E9%8D%98%EA%AB%9F%EA%90%AA%E4%A2%BE%EF%AE%96%E6%BF%A9%EB%9F%BF%E3%8B%B3&%EC%8B%85%E2%B0%9D%E2%98%A0%E3%98%97%E9%9A%B3F%E8%98%85%E2%83%A8%EA%B0%A1%E5%A4%B4=%EF%AE%A9%E4%86%AA%EB%B6%83%E8%90%8B%E2%98%95%E3%B9%AE%E6%94%AD%EA%A2%B5%ED%95%ABU"

        XCTAssertEqual(canonRequest, expectedCanonRequest)
    }
}

class SignTests: XCTestCase {
    
    // Tests for proper signature creation for a request.
    
    func testHMACSHA1() {
        let ikey = "test_ikey"
        let skey = "gtdfxv9YgVBYcF6dl2Eq17KUQJN2PLM2ODVTkvoT"
        let signature = Util.basicAuth(ikey,
                                       skey: skey,
                                       method: "PoSt",
                                       host: "foO.BAr52.cOm",
                                       path: "/Foo/BaR2/qux",
                                       dateString: "Fri, 07 Dec 2012 17:18:00 -0000",
                                       params: [
                                            "\u{469a}\u{287b}\u{35d0}\u{8ef3}\u{6727}\u{502a}\u{0810}\u{d091}\u{c8}\u{c170}": ["\u{0f45}\u{1a76}\u{341a}\u{654c}\u{c23f}\u{9b09}\u{abe2}\u{8343}\u{1b27}\u{60d0}"],
                                            "\u{7449}\u{7e4b}\u{ccfb}\u{59ff}\u{fe5f}\u{83b7}\u{adcc}\u{900c}\u{cfd1}\u{7813}": ["\u{8db7}\u{5022}\u{92d3}\u{42ef}\u{207d}\u{8730}\u{acfe}\u{5617}\u{0946}\u{4e30}"],
                                            "\u{7470}\u{9314}\u{901c}\u{9eae}\u{40d8}\u{4201}\u{82d8}\u{8c70}\u{1d31}\u{a042}": ["\u{17d9}\u{0ba8}\u{9358}\u{aadf}\u{a42a}\u{48be}\u{fb96}\u{6fe9}\u{b7ff}\u{32f3}"],
                                            "\u{c2c5}\u{2c1d}\u{2620}\u{3617}\u{96b3}F\u{8605}\u{20e8}\u{ac21}\u{5934}": ["\u{fba9}\u{41aa}\u{bd83}\u{840b}\u{2615}\u{3e6e}\u{652d}\u{a8b5}\u{d56b}U"]
                                        ])

        var expectedSignature = "\(ikey):f01811cbbf9561623ab45b893096267fd46a5178".toBase64()
        expectedSignature = expectedSignature.trimmingCharacters(in: CharacterSet.whitespaces)
        expectedSignature = "Basic \(expectedSignature)"

        XCTAssertEqual(signature, expectedSignature)
    }
}
class PartialMockClient: Client {
    var mockData: Dictionary<String, String>?
    var mockResponse: HTTPURLResponse?
    var statuses: [Int] = []
    var sleepCalls: [UInt32] = []

    override func makeRequest(_ session: URLSession, request: URLRequest, completion: @escaping (Data, HTTPURLResponse?) -> ()) {
        var status: Int = 200
        if (statuses.count > 0) {
            status = statuses.removeFirst()
        }
        mockResponse = HTTPURLResponse(url: mockResponse!.url!, statusCode: status, httpVersion: nil, headerFields: nil)
        super.makeRequest(session, request: request, completion: completion)
        completion(NSKeyedArchiver.archivedData(withRootObject: self.mockData!), self.mockResponse)
    }

    override func createSessionAndRequest(_ method: String,
                                          uri: String,
                                          headers: Dictionary<String, String>,
                                          body: String) -> (URLSession, URLRequest) {
        mockData = [
            "method": method,
            "uri": uri,
            "body": body,
            "headers": Util.canonicalizeParams(Util.normalizeParams(headers))
        ]
        let url = URL(string: "https://\(host)\(uri)")!
        mockResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return super.createSessionAndRequest(method, uri: uri, headers: headers, body: body)
    }

    override func parseJSONResponse(_ data: Data) -> AnyObject {
        return NSKeyedUnarchiver.unarchiveObject(with: data)! as AnyObject
    }

    override func uSleep(_ waitMS: UInt32) {
        sleepCalls.append(waitMS)
    }

    func setResponseStatuses(statuses: [Int]) {
        self.statuses = statuses
    }
}

class RequestTests: XCTestCase {
    
    // Tests for the request created by duoAPICall and duoJSONAPICall
    
    let host = "example.com"
    var client: PartialMockClient!
    var inputParams: Dictionary<String, [String]> = [:]
    var outputParams: String = ""

    override func setUp() {
        super.setUp()

        self.client = PartialMockClient(ikey: "test_ikey", skey: "test_skey", host: host)
        self.inputParams = [
            "foo": ["bar"],
            "baz": ["qux", "quux=quuux", "foobar=foobar&barbaz=barbaz"]
        ]
        self.outputParams = Util.canonicalizeParams(Util.normalizeParams(self.inputParams))
    }

    func testAPICallGetNoParams() {
        let responseExpectation: XCTestExpectation = expectation(description: "duoAPICall GET with no params")
        
        self.client.duoAPICall("GET", path: "/foo/bar", params: [:], completion: {
            (data, httpResponse) in

            let res = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
            XCTAssertEqual(res["method"] as? String, "GET")
            XCTAssertEqual(res["uri"] as? String, "/foo/bar")
            
            responseExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testAPICallPOSTNoParams() {
        let responseExpectation: XCTestExpectation = expectation(description: "duoAPICall POST with no params")
        
        self.client.duoAPICall("POST", path: "/foo/bar", params: [:], completion: {
            (data, httpResponse) in

            let res = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
            XCTAssertEqual(res["method"] as? String, "POST")
            XCTAssertEqual(res["uri"] as? String, "/foo/bar")
            XCTAssertEqual(res["body"] as? String, "")
            
            responseExpectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testAPICallGETParams() {
        self.client.duoAPICall("GET",
                               path: "/foo/bar",
                               params: self.inputParams as Dictionary<String, AnyObject>,
                               completion: {
            (data, httpResponse) in

            let res = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
            let uriParts: [String] = (res["uri"]! as AnyObject).components(separatedBy: "?")
            let uri = uriParts[0]
            let args = uriParts[1]
            
            XCTAssertEqual(res["method"] as? String, "GET")
            XCTAssertEqual(uri, "/foo/bar")
            XCTAssertEqual(args, self.outputParams)
        })
    }
    
    func testAPICallPOSTParams() {
        self.client.duoAPICall("POST",
                               path: "/foo/bar",
                               params: self.inputParams as Dictionary<String, AnyObject>,
                               completion: {
            (data, httpResponse) in

            let res = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
            XCTAssertEqual(res["method"] as? String, "POST")
            XCTAssertEqual(res["uri"] as? String, "/foo/bar")
            XCTAssertEqual(res["body"] as? String, self.outputParams)
        })
    }
    
    func testJSONAPICallGETNoParams() {
        self.client.duoJSONAPICall("GET", path: "/foo/bar", params: [:], completion: { response in
            let res = response as! NSDictionary
            XCTAssertEqual(res["method"] as? String, "GET")
            XCTAssertEqual(res["uri"] as? String, "/foo/bar")
            XCTAssertEqual(res["body"] as? String, "")
        })
    }
    
    func testJSONAPICallPOSTNoParams() {
        self.client.duoJSONAPICall("POST",
                                   path: "/foo/bar",
                                   params: self.inputParams as Dictionary<String, AnyObject>,
                                   completion: { response in
            let res = response as! NSDictionary
            XCTAssertEqual(res["method"] as? String, "POST")
            XCTAssertEqual(res["uri"] as? String, "/foo/bar")
            XCTAssertEqual(res["body"] as? String, self.outputParams)
        })
    }

    func testNonRateLimitedCall() {
        let responseExpectation: XCTestExpectation = expectation(description: "duoAPICall GET with no params")
        self.client.duoAPICall("GET", path: "/foo/bar", params: [:], completion: {
            (data, httpResponse) in

            let res = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
            XCTAssertEqual(res["method"] as? String, "GET")
            XCTAssertEqual(res["uri"] as? String, "/foo/bar")
            XCTAssertEqual(httpResponse!.statusCode, 200)
            XCTAssertEqual(self.client.sleepCalls.count, 0)

            responseExpectation.fulfill()
        })

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testSingleRateLimitedCall() {
        let responseExpectation: XCTestExpectation = expectation(description: "duoAPICall GET with no params")
        self.client.setResponseStatuses(statuses: [429, 200])
        self.client.duoAPICall("GET", path: "/foo/bar", params: [:], completion: {
            (data, httpResponse) in

            let res = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
            XCTAssertEqual(res["method"] as? String, "GET")
            XCTAssertEqual(res["uri"] as? String, "/foo/bar")
            XCTAssertEqual(httpResponse!.statusCode, 200)
            XCTAssertEqual(self.client.sleepCalls.count, 1)
            XCTAssertEqual(self.client.sleepCalls, [1000])

            responseExpectation.fulfill()
        })

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testAllRateLimitedCalls() {
        let responseExpectation: XCTestExpectation = expectation(description: "duoAPICall GET with no params")
        self.client.setResponseStatuses(statuses: [429, 429, 429, 429, 429, 429, 429])
        self.client.duoAPICall("GET", path: "/foo/bar", params: [:], completion: {
            (data, httpResponse) in

            let res = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
            XCTAssertEqual(res["method"] as? String, "GET")
            XCTAssertEqual(res["uri"] as? String, "/foo/bar")
            XCTAssertEqual(httpResponse!.statusCode, 429)
            XCTAssertEqual(self.client.sleepCalls.count, 6)
            XCTAssertEqual(self.client.sleepCalls,
                           [1000, 2000, 4000, 8000, 16000, 32000])

            responseExpectation.fulfill()
        })

        waitForExpectations(timeout: 10, handler: nil)
    }
}

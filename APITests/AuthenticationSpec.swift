//
//  APITests.swift
//  APITests
//
//  Created by eyebookpro on 15/12/2018.
//  Copyright © 2018 ngenii. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import API

class AuthenticationSpec: QuickSpec {

    override func spec() {
        continueAfterFailure = false

        let credential = ClientCredential(consumerAPIKey: "xvz1evFS4wEEPTGEFPHBog",
                                          consumerAPISecretKey: "L8qq9PZyRg6ieKGEKhZolGC0vJWLw8iEJ88DRdyOg")

        context("ClientCredential은") {
            it("consumer key로 부터 bearer token(Base64)을 생성한다.") {
                expect(credential.bearerToken) ==  "eHZ6MWV2RlM0d0VFUFRHRUZQSEJvZzpMOHFxOVBaeVJnNmllS0dFS2hab2xHQzB2SldMdzhpRUo4OERSZHlPZw=="
            }
        }

        let createConfig: () -> APIConfiguration = {
            return MockAPIConfiguration()
        }
        context("API를 요청하는 경우") {
            context("access token이 없다면") {
                var configuration: APIConfiguration!
                beforeEach {
                    configuration = MockAPIConfiguration(requestAccessTokenIfNeeded: true)
                }
                it("access token을 요청한 후 api를 호출한다.") {
                    let requestBuilder = APIRequestBuilder(configuration: configuration,
                                                           method: .get,
                                                           api: .api,
                                                           apiVersion: "1.1", path: "statuses/user_timeline.json",
                                                           parameters: ["screen_name": "swift", "count": 10])
                    waitUntil(timeout: 10, action: { completion in
                        requestBuilder.requestResult([Tweet].self, completion: { (tweets, error) in
                            expect(tweets).toNot(beNil())
                            expect(error).to(beNil())
                            completion()
                        })
                    })
                }
            }
            context("access token이 없다면") {
                var requestBuilder: APIRequestBuildable!
                beforeEach {
                    requestBuilder = APIRequestBuilder(configuration: createConfig(),
                                                       method: .get,
                                                       api: .api,
                                                       apiVersion: "1.1", path: "statuses/user_timeline.json",
                                                       parameters: ["screen_name": "swift", "count": 10])
                }
                it("인증 에러를 반환한다.") {
                    waitUntil(timeout: 10, action: { completion in
                        requestBuilder.requestResult(AccessToken.self) { (result, error) in
                            expect(result).to(beNil())
                            expect(error) == .needAuthentication
                            completion()
                        }
                    })
                }
                context("access token을 요청하면") {
                    var requestBuilder: OAuthRequestBuilder!
                    let configuration = MockAPIConfiguration(requestAccessTokenIfNeeded: true)
                    beforeEach {
                        requestBuilder = OAuthRequestBuilder(configuration: configuration)
                    }
                    it("access token을 받아온다.") {
                        waitUntil(action: { completion in
                            requestBuilder.request { (token, error) in
                                expect(token).toNot(beNil())
                                expect(error).to(beNil())
                                expect(requestBuilder.configuration.accessTokenProvider.accessToken).toNot(beNil())
                                expect(requestBuilder.configuration.accessTokenProvider.accessToken) == token?.accessToken
                                completion()
                            }
                        })
                    }
                    context("인증이 성공하면") {
                        var requestBuilder: APIRequestBuildable!
                        beforeEach {
                            requestBuilder = APIRequestBuilder(configuration: configuration,
                                                               method: .get,
                                                               api: .api,
                                                               apiVersion: "1.1", path: "statuses/user_timeline.json",
                                                               parameters: ["screen_name": "swift", "count": 10])
                        }
                        it("swift의 타임라인을 가져온다.") {
                            expect(configuration.accessTokenProvider.accessToken).toNot(beNil())
                            waitUntil(timeout: 10, action: { completion in
                                requestBuilder.requestResult([Tweet].self, completion: { (json, error) in
                                    expect(json).toNot(beNil())
                                    expect(error).to(beNil())
                                    completion()
                                })
                            })
                        }
                    }
                }
            }
        }
    }

}

final class MockAccessTokenProvider: AccessTokenProvidable {

    var accessToken: String?

    init(accessToken: String? = nil) {
        self.accessToken = accessToken
    }

    func setAccessToken(_ token: String) {
        self.accessToken = token
    }

}

final class MockAPIConfiguration: APIConfiguration {
    init(requestAccessTokenIfNeeded: Bool = false) {
        super.init(accessTokenProvider: MockAccessTokenProvider(),
                   requestAccessTokenIfNeeded: requestAccessTokenIfNeeded)
    }
}

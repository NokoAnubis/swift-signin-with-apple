//
//  File.swift
//  
//
//  Created by Joel Joseph on 5/7/23.
//

import Foundation

public class Validator {
    
    // Static values for requests
    private let ValidationURL: String = "https://appleid.apple.com/auth/token"
    private let RevokeURL: String = "https://appleid.apple.com/auth/revoke"
    private let ContentType: String = "application/x-www-form-urlencoded"
    private let UserAgent: String = "swift-signin-with-apple"
    private let AcceptHeader: String = "application/json"
    
    // URL Session
    private let session: URLSession
    
    // initialize session on init
    public init() {
        self.session = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    /**
     VerifyWebToken sends the WebValidationTokenRequest and gets validation result
     */
    public func VerifyWebToken<T: Decodable>(reqBody: WebValidationTokenRequest, result: inout T) async throws {
        var data: [String: String] = [:]
        data["client_id"] = reqBody.clientID
        data["client_secret"] = reqBody.clientSecret
        data["code"] = reqBody.code
        data["redirect_uri"] = reqBody.redirectURI
        data["grant_type"] = "authorization_code"
        
        try await doRequest(result: &result, url: self.ValidationURL, data: data)
    }
    
    /**
     VerifyAppToken sends the AppValidationTokenRequest and gets validation result
     */
    public func VerifyAppToken<T: Decodable>(reqBody: AppValidationTokenRequest, result: inout T) async throws {
        var data: [String: String] = [:]
        data["client_id"] = reqBody.clientID
        data["client_secret"] = reqBody.clientSecret
        data["code"] = reqBody.code
        data["grant_type"] = "authorization_code"
        
        try await doRequest(result: &result, url: self.ValidationURL, data: data)
    }
    
    /**
     VerifyRefreshToken sends the WebValidationTokenRequest and gets validation result
     */
    public func VerifyRefreshToken<T: Decodable>(reqBody: ValidationRefreshRequest, result: inout T) async throws {
        var data: [String: String] = [:]
        data["client_id"] = reqBody.clientID
        data["client_secret"] = reqBody.clientSecret
        data["refresh_token"] = reqBody.refreshToken
        data["grant_type"] = "refresh_token"
        
        try await doRequest(result: &result, url: self.ValidationURL, data: data)
    }
    
    /**
     RevokeRefreshToken revokes the Refresh Token and gets the revoke result
     */
    public func RevokeRefreshToken<T: Decodable>(reqBody: RevokeRefreshTokenRequest, result: inout T) async throws {
        var data: [String: String] = [:]
        data["client_id"] = reqBody.clientID
        data["client_secret"] = reqBody.clientSecret
        data["token"] = reqBody.refreshToken
        data["grant_type"] = "refresh_token"
        
        try await doRequest(result: &result, url: self.ValidationURL, data: data)
    }
    
    /**
     RevokeAccessToken revokes the Access Token and gets the revoke result
     */
    public func RevokeAccessToken<T: Decodable>(reqBody: RevokeAccessTokenRequest, result: inout T) async throws {
        var data: [String: String] = [:]
        data["client_id"] = reqBody.clientID
        data["client_secret"] = reqBody.clientSecret
        data["token"] = reqBody.accessToken
        data["grant_type"] = "access_token"
        
        try await doRequest(result: &result, url: self.ValidationURL, data: data)
    }
    
    public func doRequest<T: Decodable>(result: inout T, url: String, data: [String: String]) async throws {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue(ContentType, forHTTPHeaderField: "content-type")
        request.addValue(AcceptHeader, forHTTPHeaderField: "accept")
        request.addValue(UserAgent, forHTTPHeaderField: "user-agent")
        request.httpBody = data.map { "\($0)=\($1)" }.joined(separator: "&").data(using: .utf8)

// prints requests for debugging
//        if let d = request.httpBody, let bodyString = String(data: d, encoding: .utf8) {
//            print(bodyString)
//        }
        
        let (data, _) = try await self.session.data(for: request)
        
// prints response for debugging
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let jsonString = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            if let prettyPrintedString = String(data: jsonString, encoding: .utf8) {
                print(prettyPrintedString)
            }
        
        result = try JSONDecoder().decode(T.self, from: data)
    }

}


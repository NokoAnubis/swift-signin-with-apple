//
//  File.swift
//  
//
//  Created by Joel Joseph on 5/7/23.
//

import SwiftJWT
import CryptoKit
import Foundation

/**
 GenerateClientSecret generates the client secret used to make requests to the validation server.
 The secret expires after 6 months

 Parameters:
 signingKey - Private key from Apple obtained by going to the keys section of the developer section
 teamID - Your 10-character Team ID
 clientID - Your Services ID, e.g. com.aaronparecki.services
 keyID - Find the 10-char Key ID value from the portal
 */
public func GenerateClientSecret(signingKey: String, teamID: String, clientID: String, keyID: String) throws -> String {
    
    guard let privateKeyData = signingKey.data(using: .utf8) else {
        throw NSError(domain: "com.example", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid signing key"])
    }
//    let privateKey = try P256.Signing.PrivateKey(pemRepresentation: privateKeyData.base64EncodedString())
    
    let now = Date()
    let expirationDate = now.addingTimeInterval(60 * 60 * 24 * 180) // 180 days
    let claims = JWTClaims(iss: teamID, sub: clientID, exp: expirationDate, aud: "https://appleid.apple.com", iat: now)
    var headers = Header()
    headers.kid = keyID
    
    var jwt = JWT(header: headers, claims: claims)
    
    let jwtSigner = JWTSigner.es256(privateKey: privateKeyData)
    let signedJWT = try jwt.sign(using: jwtSigner)
    
    return signedJWT
}

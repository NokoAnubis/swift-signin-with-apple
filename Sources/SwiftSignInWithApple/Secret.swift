//
//  File.swift
//  
//
//  Created by Joel Joseph on 5/7/23.
//

import JWTKit
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
    let now = Date()
    let exp = now.addingTimeInterval(60 * 60 * 24 * 180) // 180 days
    let key = try ECDSAKey.private(pem: signingKey)
    let signers = JWTSigner.es256(key: key)
    let claims = AppleClaims(iss: teamID, sub: clientID, aud: "https://appleid.apple.com", iat: now, exp: exp)
    let jwt = try signers.sign(claims, kid: JWKIdentifier(string: keyID))
    return jwt
}

/**
We verify apple jwt token against the apple server to make sure it is correct
 */
public func VerifyAppleJWTToken(tk: String) throws -> AppleClaims {
    let jwksData = try Data(contentsOf: URL(string: "https://appleid.apple.com/auth/keys")!)
    let jwks = try JSONDecoder().decode(JWKS.self, from: jwksData)
    let signers = JWTSigners()
    try signers.use(jwks: jwks)
    let payload = try signers.verify(tk, as: AppleClaims.self)
    return payload
}

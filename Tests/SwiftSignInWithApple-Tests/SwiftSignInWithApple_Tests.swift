import XCTest
@testable import SwiftSignInWithApple

final class SwiftSignInWithApple_Tests: XCTestCase {
    func testAppTokenVerfication() async throws {
        let validator = Validator()
        let teamId: String = "5A6H49Q85D"
        let clientId: String = "com.coronislabs.Olympsis"
        let keyId: String = "S3HDPU4ZC5"
        let token = """
            -----BEGIN PRIVATE KEY-----
            xxxxxxxxxxxxxxxxxxxxxxxxxxx
            -----END PRIVATE KEY-----
            """
        let secret = try GenerateClientSecret(signingKey: token, teamID: teamId, clientID: clientId, keyID: keyId)
        let vReq = AppValidationTokenRequest(clientID: clientId, clientSecret: secret, code: "xxxxxxxxxxxxxx")
        var vResp = ValidationResponse()
        try await validator.VerifyAppToken(reqBody: vReq, result: &vResp)
    }
    
    func testAppleJWTTokenDecoder() async throws {
        let payload = try VerifyAppleJWTToken(tk: "xxxxxxxxxxxxxxxx")
    }
}

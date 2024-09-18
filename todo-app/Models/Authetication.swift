struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
    let refresh_token: String
}

struct ErrorResponse: Codable {
    let detail: String
}

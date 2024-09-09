struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
}

struct ErrorResponse: Codable {
    let detail: String
}

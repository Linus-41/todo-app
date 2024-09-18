import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()

    // MARK: - Save Access Token
    func saveAccessToken(_ token: String) {
        save(key: "accessToken", data: token.data(using: .utf8)!)
    }
    
    // MARK: - Get Access Token
    func getAccessToken() -> String? {
        return get(key: "accessToken")
    }
    
    // MARK: - Save Refresh Token
    func saveRefreshToken(_ token: String) {
        save(key: "refreshToken", data: token.data(using: .utf8)!)
    }
    
    // MARK: - Get Refresh Token
    func getRefreshToken() -> String? {
        return get(key: "refreshToken")
    }
    
    // MARK: - Save Token Expiration
    func saveTokenExpiration(_ date: Date) {
        let timeInterval = date.timeIntervalSince1970
        let timeData = withUnsafeBytes(of: timeInterval) { Data($0) }
        save(key: "tokenExpiration", data: timeData)
    }
    
    // MARK: - Get Token Expiration
    func getTokenExpiration() -> Date? {
        guard let data = load(key: "tokenExpiration") else { return nil }
        let timeInterval = data.withUnsafeBytes {
            $0.load(as: TimeInterval.self)
        }
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    // MARK: - Save Helper
    private func save(key: String, data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary) // Ensure old data is removed
        SecItemAdd(query as CFDictionary, nil) // Add new data
    }
    
    // MARK: - Get Helper
    private func get(key: String) -> String? {
        guard let data = load(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Load Helper
    private func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess {
            return result as? Data
        }
        return nil
    }
    
    // MARK: - Delete Helper
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Delete Token Expiration
    func deleteTokenExpiration() {
        delete(key: "tokenExpiration")
    }
}

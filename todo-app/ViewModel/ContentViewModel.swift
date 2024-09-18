import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    
    func checkStayLoggedIn(){
        let stayLoggedIn = UserDefaults.standard.bool(forKey: "stayLoggedIn")
        if stayLoggedIn == true{
            if let refreshToken = KeychainService.shared.getRefreshToken(), !refreshToken.isEmpty {
                self.isSignedIn = true
            }
        }
    }
    
    func clearKeyChain(){
        if let refreshToken = KeychainService.shared.getRefreshToken(), !refreshToken.isEmpty {
            APIService.shared.invalidateRefreshToken(toInvalidateToken: refreshToken) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Old refresh token invalidated!")
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}

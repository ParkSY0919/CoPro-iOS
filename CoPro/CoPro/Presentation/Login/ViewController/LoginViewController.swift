//
//  LoginViewController.swift
//  CoPro
//
//  Created by 박현렬 on 11/8/23.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import OAuthSwift
import SnapKit
import SafariServices
import Alamofire
import KeychainSwift
import CryptoKit

class LoginViewController: BaseViewController, AuthUIDelegate,ASAuthorizationControllerDelegate {
    
    var loginView: LoginView!
    override func loadView() {
        // LoginView를 생성하고 뷰에 추가합니다.
        view = LoginView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
    }
    override func setUI() {
        
    }
    override func setLayout() {
        
    }
    override func setAddTarget() {
        if let loginView = view as? LoginView {
            // Apple 로그인 버튼
            loginView.appleSignInButton.addTarget(self, action: #selector(handleAppleSignIn), for: .touchUpInside)
            // Google 로그인 버튼
            loginView.googleSignInButton.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
            // GitHub 로그인 버튼
            //            loginView.githubSignInButton.addTarget(self, action: #selector(handleGoogleSignIn2), for: .touchUpInside)
        }
    }
    let keychain = KeychainSwift()
    @objc private func signOut() {
        if Auth.auth().currentUser != nil{
            do {
                try Auth.auth().signOut()
                // 로그아웃이 성공적으로 처리된 후의 코드를 여기에 작성합니다.
                // 예를 들어, 로그인 화면으로 돌아가는 등의 처리를 할 수 있습니다.
                print("로그아웃")
                self.navigationController?.popToRootViewController(animated: true)
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }
        else{
            print("로그인 된 계정없음")
        }
    }
    @objc private func handleGoogleSignIn() {
        print("Google Sign in button tapped")
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }
            
            signInResult.user.refreshTokensIfNeeded { user, error in
                guard error == nil else { return }
                guard let user = user else { return }
                
                let idToken = user.idToken?.tokenString
                LoginAPI.shared.getAccessToken(authCode: user.idToken?.tokenString, provider: "google") { result in
                    switch result {
                    case .success(let response):
                        print("구글 로그인 성공")
                        print(response.data.accessToken)
                        print(response.data.refreshToken)
                        self.keychain.set(response.data.accessToken, forKey: "accessToken")
                        self.keychain.set(response.data.refreshToken, forKey: "refreshToken")
                        DispatchQueue.main.async {
                            let vc = BottomTabController()
                            self.navigationController?.setViewControllers([vc], animated: true)
                        }
                    case .failure(let error):
                        print("구글 로그인 실패")
                        print(error)
                    }
                }
                print(idToken!)
            }
        }
    }
    
    
    @objc private func handleAppleSignIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nil)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    print(error?.localizedDescription)
                    return
                }
                
                print("User is signed in")
                print("UserToken: \(idTokenString)")
                self.keychain.set(idTokenString, forKey: "idToken")
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    @objc private func handleGitHubSignIn() {
        print("github SignIn Tapped")
        let provider = OAuthProvider(providerID: "github.com")
        provider.scopes = ["public_repo"] // 이 예에서는 public_repo 권한을 요청합니다. 필요에 따라 변경하세요.
        provider.getCredentialWith(nil, completion: { credential, error in
            
            if let error = error {
                print("Failed to get credential: \(error.localizedDescription)")
                return
            }
            
            // Firebase에 로그인
            if let credential = credential {
                Auth.auth().signIn(with: credential, completion: { authResult, error in
                    if let error = error {
                        print("Login error: \(error.localizedDescription)")
                        return
                    }
                    
                    print("User is signed in")
                    // 여기서 메인 화면으로 이동하도록 코드를 추가하세요.
                })
            }
        })
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Apple 로그인 인증 창 띄우기
        return self.view.window ?? UIWindow()
    }
}

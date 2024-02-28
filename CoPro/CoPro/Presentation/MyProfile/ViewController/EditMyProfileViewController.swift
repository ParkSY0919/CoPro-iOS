//
//  EditMyProfileViewController.swift
//  CoPro
//
//  Created by 박신영 on 2/2/24.
//

import UIKit
import SnapKit
import Then
import KeychainSwift

protocol NowProfileUpdateDelegate: AnyObject {
    func didUpdateProfile()
}

class EditMyProfileViewController: BaseViewController, UITextFieldDelegate {
   
   enum EditMyProfileViewType {
      case FirstLogin, NotFirstLogin
   }
   var activeViewType: EditMyProfileViewType = .NotFirstLogin
   private let keychain = KeychainSwift()
   weak var profileUpdateDelegate: NowProfileUpdateDelegate?
   
   var loginVC = LoginViewController()
   var beforeEditMyProfileData: MyProfileDataModel?
   let container = UIView()
   var languageStackView: UIStackView?
   var careerStackView: UIStackView?
   var initialUserName: String?
   var isJobsButtonTap: Bool?
   var editFlag: Bool?
   var nickNameDuplicateFlag: Bool = true
   var selectedJob: String?
   var selectedLanguageButtons = [UIButton]()
   var selectedCareer: String?
   var isNicknameModificationSuccessful: Bool?
   var isFirstLogin: Bool?
   var readyForNextButton: Bool?
   var nicknameValidity: Bool?
   
   var editMyProfileBody = EditMyProfileRequestBody()
   
   
   private let nickNameLabel = UILabel().then({
      $0.setPretendardFont(text: "닉네임", size: 17, weight: .bold, letterSpacing: 1.23)
      $0.textColor = UIColor.Black()
   })
   
   private var nicknameDuplicateCheckLabel = UILabel().then {
      $0.setPretendardFont(text: "사용 가능한 닉네임입니다.", size: 11, weight: .regular, letterSpacing: 1.23)
      $0.textColor = UIColor.P1()
   }
   
   let nickNameTextField = UITextField().then {
      $0.placeholder = "닉네임"
      $0.clearButtonMode = .always
      $0.keyboardType = .default
      $0.autocapitalizationType = .none
      $0.spellCheckingType = .no
   }
   
   let textFieldContainer = UIView().then {
      $0.layer.backgroundColor = UIColor.G1().cgColor
      $0.layer.cornerRadius = 10
   }
   
   private let languageUsedLabel = UILabel().then {
      $0.setPretendardFont(text: "사용 언어", size: 17, weight: .bold, letterSpacing: 1.23)
      $0.textColor = UIColor.Black()
   }
   
   private let myJobLabel = UILabel().then {
      $0.setPretendardFont(text: "나의 직무", size: 17, weight: .bold, letterSpacing: 1.23)
      $0.textColor = UIColor.Black()
   }
   
   private let careerLabel = UILabel().then {
      $0.setPretendardFont(text: "개발 경력", size: 17, weight: .bold, letterSpacing: 1.23)
      $0.textColor = UIColor.Black()
   }
   
   lazy var jobButtonsStackView = UIStackView().then { stackView in
      stackView.axis = .horizontal
      stackView.distribution = .fillEqually
      stackView.spacing = 11
      let buttonTitles = ["Frontend", "Backend", "Mobile", "AI"]
      
      
      for job in buttonTitles {
         stackView.addArrangedSubview(createButton(withTitle: job))
      }
   }
   
   lazy var nextButton = UIButton().then {
      $0.layer.backgroundColor = UIColor.G1().cgColor
      $0.layer.cornerRadius = 10
      $0.addTarget(self, action: #selector(didNextButtonAlert), for: .touchUpInside)
      $0.setTitle("다음", for: .normal)
      $0.titleLabel?.setPretendardFont(text: "다음", size: 17, weight: .bold, letterSpacing: 1.23)
      $0.titleLabel?.textColor = UIColor.White()
   }
   
   lazy var doneButton = UIButton().then {
      $0.layer.backgroundColor = UIColor.G1().cgColor
      $0.layer.cornerRadius = 10
      $0.addTarget(self, action: #selector(didDoneButton), for: .touchUpInside)
      $0.setTitle("선택 완료", for: .normal)
      $0.titleLabel?.setPretendardFont(text: "선택 완료", size: 17, weight: .bold, letterSpacing: 1.23)
      $0.titleLabel?.textColor = UIColor.White()
      $0.isEnabled = false
   }
   
   private lazy var languageCount = UILabel().then {
      $0.setPretendardFont(text: "(\(selectedLanguageButtons.count)/2)", size: 11, weight: .regular, letterSpacing: 1.23)
      $0.textColor = UIColor.P1()
   }
   
   
   
   
   override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = UIColor.White()
      nickNameTextField.delegate = self
      nickNameTextField.text = beforeEditMyProfileData?.nickName
      isJobsButtonTap = false
      updateButtonState(type: "First")
      nickNameDuplicateFlag = true
      nicknameValidity = true
      editFlag = true
      
   }
   
   override func setUI() {
      if let sheetPresentationController = sheetPresentationController {
         sheetPresentationController.preferredCornerRadius = 15
         sheetPresentationController.prefersGrabberVisible = true
         sheetPresentationController.detents = [.custom {context in
            return self.returnEditMyProfileUIHeight(type: "First")
         }]
      }
   }
   
   override func setLayout() {
      view.addSubview(container)
      container.addSubviews(nickNameLabel, textFieldContainer, nicknameDuplicateCheckLabel, myJobLabel, jobButtonsStackView, nextButton)
      textFieldContainer.addSubview(nickNameTextField)
      
      container.snp.makeConstraints {
         $0.leading.equalToSuperview().offset(16)
         $0.trailing.equalToSuperview().offset(-16)
         $0.top.equalToSuperview().offset(24)
         $0.bottom.equalToSuperview().offset(-30)
      }
      
      nickNameLabel.snp.makeConstraints {
         $0.top.equalToSuperview()
         $0.leading.equalToSuperview().offset(8)
         $0.height.equalTo(21)
      }
      
      textFieldContainer.snp.makeConstraints {
         $0.leading.trailing.equalToSuperview()
         $0.top.equalTo(nickNameLabel.snp.bottom).offset(8)
         $0.height.equalTo(41)
      }
      
      nickNameTextField.snp.makeConstraints {
         $0.centerY.equalToSuperview()
         $0.leading.equalToSuperview().offset(8)
         $0.trailing.equalToSuperview().offset(-8)
      }
      
      nicknameDuplicateCheckLabel.snp.makeConstraints {
         $0.top.equalTo(textFieldContainer.snp.bottom).offset(5)
         $0.leading.equalToSuperview().offset(8)
         //         $0.width.equalTo(150)
         $0.height.equalTo(15)
      }
      
      myJobLabel.snp.makeConstraints {
         $0.top.equalTo(nicknameDuplicateCheckLabel.snp.bottom).offset(18)
         $0.leading.equalToSuperview().offset(8)
         $0.height.equalTo(21)
      }
      
      jobButtonsStackView.snp.makeConstraints {
         $0.top.equalTo(myJobLabel.snp.bottom).offset(8)
         $0.leading.trailing.equalToSuperview()
         $0.height.equalTo(41)
      }
      
      nextButton.snp.makeConstraints {
         $0.top.equalTo(jobButtonsStackView.snp.bottom).offset(18)
         $0.leading.trailing.equalToSuperview()
         $0.height.equalTo(41)
      }
   }
   
   private func postEditMyProfile() {
      if let token = self.keychain.get("accessToken") {
         switch activeViewType {
            
         case .FirstLogin:
            let checkFirstlogin = true
            MyProfileAPI.shared.postEditMyProfile(token: token, requestBody: editMyProfileBody, checkFirstlogin: checkFirstlogin) { result in
               switch result {
               case .success(let data):
                  if let data = data as? EditMyProfileDTO {
                     self.keychain.set(data.data.picture, forKey: "currentUserProfileImage")
                     self.keychain.set(data.data.nickName, forKey: "currentUserNickName")
                     self.keychain.set(data.data.occupation, forKey: "currentUserOccupation")
                     self.keychain.set(data.data.email, forKey: "currentUserEmail")
                     
                     self.postFcmToken()
                     print("🍎🍎🍎🍎🍎🍎🍎checkFirstlogin true / postFcmToken 성공🍎🍎🍎🍎🍎🍎🍎🍎🍎")
                     self.dismiss(animated: true) {
                        let loginViewController = LoginViewController()
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let delegate = windowScene.delegate as? SceneDelegate,
                           let window = delegate.window {
                           window.rootViewController = loginViewController
                           window.makeKeyAndVisible()
                           let alertVC = EditGithubModalViewController()
                           alertVC.activeModalType = .FirstLogin
                           loginViewController.present(alertVC, animated: true, completion: nil)
                        }
                     }
                  }
               case .requestErr(let message):
                  print("Error : \(message)")
               case .pathErr, .serverErr, .networkFail:
                  print("another Error")
               default:
                  break
               }
            }
            
         case .NotFirstLogin:
            let checkFirstlogin = false
            MyProfileAPI.shared.postEditMyProfile(token: token, requestBody: editMyProfileBody, checkFirstlogin: checkFirstlogin) { result in
               switch result {
               case .success(_):
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                     self.showAlert(title: "프로필 수정을 완료하였습니다",
                                    confirmButtonName: "확인",
                                    confirmButtonCompletion: { [self] in
                        self.profileUpdateDelegate?.didUpdateProfile()
                        self.dismiss(animated: true)
                     })
                  }
                  
                  print("NotFirstLogin 타입 / checkFirstlogin false / 프로필수정 성공공")
               case .requestErr(let message):
                  print("Error : \(message)")
               case .pathErr, .serverErr, .networkFail:
                  print("another Error")
               default:
                  break
               }
            }
         }
      }
   }
   
//   func getTopViewController() -> UIViewController? {
//      if var topController = UIApplication.shared.keyWindow?.rootViewController {
//         while let presentedViewController = topController.presentedViewController {
//            topController = presentedViewController
//         }
//         return topController
//      }
//      return nil
//   }
   
   func postFcmToken() {
      print("🔥")
      
      guard let token = self.keychain.get("accessToken") else {
         print("No accessToken found in keychain.")
         return
      }
      guard let fcmToken = keychain.get("FcmToken") else {return print("postFcmToken 안에 FcmToken 설정 에러")}
      
      NotificationAPI.shared.postFcmToken(token: token, requestBody: FcmTokenRequestBody(fcmToken: fcmToken)) { result in
         switch result {
         case .success(_):
            print("FcmToken 보내기 성공")
            
         case .requestErr(let message):
            // 요청 에러인 경우
            print("Error : \(message)")
            if (message as AnyObject).contains("401") {
               // 만료된 토큰으로 인해 요청 에러가 발생한 경우
            }
            
         case .pathErr, .serverErr, .networkFail:
            // 다른 종류의 에러인 경우
            print("another Error")
         default:
            break
         }
      }
   }
   
   
   
   private func returnEditMyProfileUIHeight(type: String) -> CGFloat {
      if type == "First" {
         return 300.0
      }
      else {
         return 520
      }
   }
   
   //여기
   internal func textFieldDidEndEditing(_ textField: UITextField) {
      if let text = textField.text {
         print("사용자가 입력한 텍스트: \(text)")
         if text == initialUserName {
            nickNameDuplicateFlag = true
            nicknameValidity = true
            editFlag = true
            DispatchQueue.main.async {
               self.nicknameDuplicateCheckLabel.text = "사용 가능한 닉네임입니다."
            }
         } else {
            
            // 정규 표현식을 사용하여 영어, 한글, 숫자만을 허용하고, 한글 자소로 나누어진 입력을 허용하지 않는지 확인합니다.
            let regex = "^[a-zA-Z0-9가-힣]{1,8}$"
            let test = NSPredicate(format:"SELF MATCHES %@", regex)
            let result = test.evaluate(with: text)
            
            if !result {
               DispatchQueue.main.async {
                  self.showAlert(title: "닉네임 요건이 충족되지 못하였습니다",
                                 message: "1. 특수문자는 입력이 불가능합니다.\n2. 닉네임 길이 규정은 1글자 이상 8글자 이하입니다.\n3. 'ㅋㅗㅍㅡㄹㅗ'와 같이 한글 자소 입력은 불가능합니다.," ,
                                 confirmButtonName: "확인",
                                 confirmButtonCompletion: { [self] in
                     nicknameValidity = false
                     nicknameDuplicateCheckLabel.text = "사용할 수 없는 닉네임입니다." })
               }
            } else {
               nicknameValidity = true
               getNickNameDuplication(nickname: text)
            }
         }
      }
      updateButtonState(type: "First")
   }
   
   internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      return true
   }
   
   override func setUpKeyboard() {
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
   }
   
   deinit {
      NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
      NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
   }
   
   func addLanguageButtonsForJobType(jobType: String) {
      let jobTypeTechnologies = [
         "Frontend": ["React.js", "Vue.js", "Angular.js", "TypeScript"],
         "Backend": ["Spring", "Django", "Flask", "Node.js", "Go"],
         "Mobile": ["SwiftUI", "UIKit", "Flutter", "Kotlin", "Java", "RN"],
         "AI": ["TensorFlow", "Keras", "PyTorch"]
      ]
      DispatchQueue.main.async { [self] in
         guard let technologies = jobTypeTechnologies[jobType] else { return }
         languageStackView = UIStackView().then { stackView in
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 11
            
            for technology in technologies {
               stackView.addArrangedSubview(createButton(withTitle: technology))
               
            }
         }
         
         guard let stackView = languageStackView else { return print("languageStackView failed") }
         
         container.addSubviews(languageUsedLabel, languageCount, stackView)
         
         nextButton.removeFromSuperview()
         languageUsedLabel.snp.makeConstraints {
            $0.top.equalTo(jobButtonsStackView.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(8)
            $0.height.equalTo(21)
         }
         
         languageCount.snp.makeConstraints {
            $0.leading.equalTo(languageUsedLabel.snp.trailing).offset(3)
            $0.bottom.equalTo(languageUsedLabel)
            $0.height.equalTo(14)
         }
         
         stackView.snp.makeConstraints {
            $0.top.equalTo(languageUsedLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(41)
         }
      }
   }
   
   @objc func handleJobButtonSelection(_ sender: UIButton) {
      print("handleJobButtonSelection")
      for subview in jobButtonsStackView.arrangedSubviews {
         if let button = subview as? UIButton {
            button.isSelected = false
            button.layer.backgroundColor = UIColor.G1().cgColor
         }
      }
      selectedJob = sender.currentTitle
      isJobsButtonTap = true
      sender.isSelected = true
      sender.layer.backgroundColor = UIColor.P7().cgColor
      updateButtonState(type: "First")
   }
   
   @objc func handleLanguageButtonSelection(_ sender: UIButton) {
      DispatchQueue.main.async { [self] in
         print("selectedLanguageButtons.count :",selectedLanguageButtons.count)
         
         // 선택한 언어 버튼이 2개 미만일 때,
         if selectedLanguageButtons.count < 2 {
            
            // 선택한 버튼이 selectedLanguageButtons에 이미 있을 때
            if selectedLanguageButtons.contains(sender) {
               print("지금 2개 미만인 상황, selectedLanguageButtons에 \(sender) 있음!!!")
               var index = 0
               for i in 0..<2 {
                  if selectedLanguageButtons[i] == sender {
                     selectedLanguageButtons[i].isSelected = false
                     selectedLanguageButtons[i].layer.backgroundColor = UIColor.G1().cgColor
                     selectedLanguageButtons.remove(at: i)
                     break
                  }
               }
            }
            // 선택한 버튼이 selectedLanguageButtons에 없을 때
            else {
               sender.isSelected = true
               sender.layer.backgroundColor = UIColor.P7().cgColor
               selectedLanguageButtons.append(sender)
            }
            
            languageCount.text = "(\(selectedLanguageButtons.count)/2)"
         }
         
         // 선택한 언어 버튼이 2개 이상일 때,
         else {
            if selectedLanguageButtons.contains(sender) {
               print("지금 2개 이상인 상황, selectedLanguageButtons에 \(sender) 있음!!!")
               for i in 0..<2 {
                  if selectedLanguageButtons[i] == sender {
                     selectedLanguageButtons[i].isSelected = false
                     selectedLanguageButtons[i].layer.backgroundColor = UIColor.G1().cgColor
                     selectedLanguageButtons.remove(at: i)
                     break
                  }
               }
            }
            else {
               // 선택된 버튼이 이미 2개일 때
               let firstButton = selectedLanguageButtons.removeFirst()   // 첫 번째로 선택된 버튼을 제거
               firstButton.isSelected = false
               firstButton.layer.backgroundColor = UIColor.G1().cgColor
               
               sender.isSelected = true
               sender.layer.backgroundColor = UIColor.P7().cgColor
               selectedLanguageButtons.append(sender)   // 새로 선택된 버튼을 추가
            }
            languageCount.text = "(\(selectedLanguageButtons.count)/2)"
            
         }
         updateButtonState(type: "End")
      }
   }
   
   @objc func handleCareerButtonSelection(_ sender: UIButton) {
      guard let careerStackView = careerStackView else {return print("careerStackView error")}
      for subview in careerStackView.arrangedSubviews {
         if let button = subview as? UIButton {
            button.isSelected = false
            button.layer.backgroundColor = UIColor.G1().cgColor
         }
      }
      sender.isSelected = true
      sender.layer.backgroundColor = UIColor.P7().cgColor
      selectedCareer = sender.currentTitle
      updateButtonState(type: "End")
   }
   
   
   func updateButtonState(type: String) {
      if type == "First" {
         var isTextFieldNotEmpty = nickNameTextField.text?.isEmpty == false
         let isSelectedJobNotEmpty = selectedJob?.isEmpty == false
         DispatchQueue.main.async { [self] in
            if isTextFieldNotEmpty && isSelectedJobNotEmpty {
               nextButton.backgroundColor = UIColor.P2()
               editFlag = true
            } else {
               nextButton.backgroundColor = .gray
               editFlag = false
            }
         }
      } else {
         let isSelectedButtonsNotEmpty = selectedLanguageButtons.isEmpty == false
         let isSelectedCareerNotEmpty = selectedCareer?.isEmpty == false
         DispatchQueue.main.async { [self] in
            if isSelectedButtonsNotEmpty && isSelectedCareerNotEmpty {
               doneButton.backgroundColor = UIColor.P2()
               let languageArr = selectedLanguageButtons.map { $0.currentTitle ?? "" }
               editMyProfileBody.language = languageArr.joined(separator: ",")
               editMyProfileBody.career = convertCareerToInt(selectedCareer: selectedCareer ?? "")
               doneButton.isEnabled = true
            } else {
               doneButton.backgroundColor = UIColor.G1()
               doneButton.isEnabled = false
            }
         }
      }
   }
   
   func convertCareerToInt(selectedCareer: String) -> Int {
      if selectedCareer == "신입" {
         return 1
      } else if selectedCareer == "3년 미만" {
         return 2
      } else if selectedCareer == "3년 이상" {
         return 3
      } else if selectedCareer == "5년 이상" {
         return 4
      } else if selectedCareer == "10년 이상" {
         return 5
      } else {
         return 20
      }
   }
   
   
   
   @objc func didTapNextButton(jobType: String) {
      editMyProfileBody.nickName = nickNameTextField.text ?? ""
      editMyProfileBody.occupation = selectedJob ?? ""
      nickNameTextField.isEnabled = false
      
      DispatchQueue.main.async { [self] in
         nextButton.isHidden = true
         nickNameLabel.textColor = UIColor.gray
         nickNameTextField.textColor = UIColor.gray
         myJobLabel.textColor = UIColor.gray
         jobButtonsStackView.arrangedSubviews.forEach { view in
            if let button = view as? UIButton {
               button.isEnabled = false
               if button.isSelected == true {
                  button.setTitleColor(UIColor(hex: "#5D5BC1"), for: .normal)
               }
            }
         }
         sheetPresentationController?.animateChanges { [self] in
            self.sheetPresentationController?.detents = [.custom {context in
               return self.returnEditMyProfileUIHeight(type: "Secound")
            }]
         }
         
         addLanguageButtonsForJobType(jobType: jobType)
         addCareerButtons()
         addDoneButton()
      }
   }
   
   
   
   func addCareerButtons() {
      careerStackView = UIStackView().then { stackView in
         stackView.axis = .horizontal
         stackView.distribution = .fillEqually
         stackView.spacing = 11
         let careerType = ["신입", "3년 미만", "3년 이상", "5년 이상", "10년 이상"]
         
         for career in careerType {
            stackView.addArrangedSubview(createButton(withTitle: career))
         }
      }
      
      DispatchQueue.main.async { [self] in
         guard let stackView = careerStackView else { return print("careerStackView failed") }
         if let languageStackView = languageStackView {
            container.addSubviews(careerLabel, stackView)
            
            careerLabel.snp.makeConstraints {
               $0.top.equalTo(languageStackView.snp.bottom).offset(18)
               $0.leading.equalToSuperview().offset(8)
               $0.height.equalTo(21)
            }
            
            stackView.snp.makeConstraints {
               $0.top.equalTo(careerLabel.snp.bottom).offset(8)
               $0.leading.trailing.equalToSuperview()
               $0.height.equalTo(41)
            }
         } else {
            // languageStackView가 nil일 때의 처리를 여기에 작성합니다.
         }
      }
   }
   
   func addDoneButton() {
      DispatchQueue.main.async { [self] in
         container.addSubview(doneButton)
         
         doneButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-27)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(41)
         }
         updateButtonState(type: "didTapNextButton")
      }
   }
   
   
   
   //얘 활용하기
   func createButton(withTitle title: String) -> UIButton {
      let button = UIButton()
      button.setTitle(title, for: .normal)
      button.titleLabel?.setPretendardFont(text: title, size: 13, weight: .regular, letterSpacing: 1.23)
      button.layer.backgroundColor = UIColor.G1().cgColor
      button.layer.cornerRadius = 10
      button.setTitleColor(UIColor.G4(), for: .normal)
      button.setTitleColor(UIColor.P5(), for: .selected)
      button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3) // 여기에서 패딩을 설정합니다. 원하는 값으로 조절하세요.
      if ["Frontend", "Backend", "Mobile", "AI"].contains(title) {
         button.addTarget(self, action: #selector(handleJobButtonSelection(_:)), for: .touchUpInside)
      } else if ["신입", "3년 미만", "3년 이상", "5년 이상", "10년 이상"].contains(title) {
         button.addTarget(self, action: #selector(handleCareerButtonSelection(_:)), for: .touchUpInside)
      } else {
         button.addTarget(self, action: #selector(handleLanguageButtonSelection(_:)), for: .touchUpInside)
      }
      
      if beforeEditMyProfileData?.language.contains(title) == true ||
            beforeEditMyProfileData?.career == convertCareerToInt(selectedCareer: title) || beforeEditMyProfileData?.occupation.contains(title) == true {
         if beforeEditMyProfileData?.language.contains(title) == true {
            selectedLanguageButtons.append(button)
         } else if beforeEditMyProfileData?.career == convertCareerToInt(selectedCareer: title) {
            selectedCareer = title
         } else {
            selectedJob = title
         }
         button.isSelected = true
         button.layer.backgroundColor = UIColor.P7().cgColor
      }
      
      return button
   }
   
   private func getNickNameDuplication(nickname: String) {
      if let token = self.keychain.get("accessToken") {
         print("현재 nickname : \(nickname)")
         MyProfileAPI.shared.getNickNameDuplication(token: token, nickname: nickname) { result in
            print("Result: \(result)")
            switch result {
            case .success(let data):
               print("🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊uccess🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊")
               if let data = data as? getNickNameDuplicationDTO {
                  self.nickNameDuplicateFlag = data.data
                  DispatchQueue.main.async {
                     self.nicknameDuplicateCheckLabel.text = data.message
                  }
               } else {
                  print("Failed to decode the response.")
               }
               
            case .requestErr(let message):
               print("Error : \(message)")
            case .pathErr, .serverErr, .networkFail:
               print("another Error")
            default:
               break
            }
         }
      }
   }
   
   @objc func didDoneButton() {
      postEditMyProfile()
   }
   
   
   @objc func didNextButtonAlert() {
      if readyForNextButton == false {
         nickNameTextField.resignFirstResponder()
      } else {
         if editFlag == true && nickNameDuplicateFlag == true && nicknameValidity == true {
            didNext()
         }
         else {
            didError()
         }
         
      }
   }
   
   @objc private func didNext() {
      showAlert(title: "다음 수정을 진행하시겠습니까?",
                message: "이후 이전 내용은 수정하실 수 없습니다" ,
                cancelButtonName: "취소",
                confirmButtonName: "확인",
                confirmButtonCompletion: { [self] in
         didTapNextButton(jobType: selectedJob ?? "")
      })
   }
   
   @objc private func didError() {
      showAlert(title: "모든 필드가 유효한지 확인 및 입력해주세요",
                confirmButtonName: "확인")
   }
   
   func faileEditProfile() {
      showAlert(title: "프로필 수정을 실패하였습니다",
                confirmButtonName: "확인",
                confirmButtonCompletion: { [self] in
         self.dismiss(animated: true, completion: nil)
      })
   }
   
   @objc func keyboardWillShow(notification: NSNotification) {
      if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
         readyForNextButton = false
         UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
         }
      }
   }
   
   @objc func keyboardWillHide(notification: NSNotification) {
      readyForNextButton = true
      UIView.animate(withDuration: 0.3) {
         self.view.layoutIfNeeded()
      }
   }
   
}

//
//  MiniCard.swift
//  CoPro
//
//  Created by 박현렬 on 1/8/24.
//

import UIKit
import SnapKit
import Then

class MiniCard: BaseView {
    
    
    let shapes = UIView().then {
        $0.clipsToBounds = true
    }
    
    let profile = UIImageView().then {
        let size = CGSize(width: 80, height: 80) // 원하는 크기로 변경하세요.
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            let context = UIGraphicsGetCurrentContext()
            
            context?.setFillColor(UIColor.red.cgColor) // 원하는 색상으로 변경하세요.
            context?.fillEllipse(in: CGRect(origin: .zero, size: size))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            $0.image = image
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        
    }
    let profileLabel = UILabel().then{
        $0.text = "Your Title"
        $0.font = UIFont(name: "Pretendard-Regular", size: 9)
            $0.textColor = .black
            $0.textAlignment = .center
    }
    let lineView = UIView().then {
        $0.backgroundColor = .lightGray // 연한 회색으로 설정
        $0.heightAnchor.constraint(equalToConstant: 1).isActive = true // 가로줄 두께 설정
    }
    let infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 8
        $0.alignment = .center
        
    }
    
    let userPartLabel = UILabel().then {
        $0.textAlignment = .center
        $0.attributedText = NSAttributedString(string: "Mobile", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.kern: 1.37])
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.7
    }
    let userLangLabel = UILabel().then {
        $0.textAlignment = .center
        $0.attributedText = NSAttributedString(string: "Swift / Dart", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.kern: 1.37])
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.7
    }
    let userCareerLabel = UILabel().then {
        $0.textAlignment = .center
        $0.attributedText = NSAttributedString(string: "~6개월", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.kern: 1.21])
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.7
    }
    let cardbuttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 5
    }
    let chatButton = UIButton().then {
        $0.backgroundColor =  UIColor(red: 0.71, green: 0.769, blue: 0.866, alpha: 1)
        $0.layer.cornerRadius = 15
    }
    let chatLabel = UILabel().then {
        $0.textAlignment = .center
        $0.attributedText = NSAttributedString(string: "채팅하기", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.kern: 1.25])
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.7
    }
    let gitImage = UIImageView(image: Image.github_SignInButton)
    let gitButtonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 1
        $0.alignment = .center
    }
    
    let gitButton: UIButton = {
        var config = UIButton.Configuration.plain()
        let gitImage = UIImage(named: "github_SignInButton")?.withRenderingMode(.alwaysTemplate)
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 16, weight: .regular)
        let resizedImage = gitImage?.resized(to: CGSize(width: 32, height: 32)) // 이미지 크기 조절
        
        // 이미지와 텍스트 간 여백 설정
        config.imagePadding = 5 // 이미지 여백
        config.imagePlacement = .leading // 이미지 위치
        config.attributedTitle = AttributedString("Git", attributes: container)
        config.image = resizedImage
        config.baseForegroundColor = .black
        
        let button = UIButton(configuration: config)
        
        button.backgroundColor =  UIColor(red: 0.71, green: 0.769, blue: 0.866, alpha: 1)
        button.layer.cornerRadius = 15
        
        return button
    }()
    
    override func setUI() {
       
        addSubview(shapes)
        shapes.addSubviews(profile,profileLabel)
        shapes.addSubview(lineView)
        shapes.addSubview(infoStackView)
        infoStackView.addArrangedSubviews(userPartLabel,userLangLabel,userCareerLabel)
        shapes.addSubview(cardbuttonStackView)
        cardbuttonStackView.addArrangedSubview(gitButton)
        cardbuttonStackView.addArrangedSubview(chatButton)
        chatButton.addSubview(chatLabel)
        
        
       
        
        let layer1 = CALayer().then {
            $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        }
        
        shapes.layer.addSublayer(layer1)
        
        shapes.layer.do {
            $0.cornerRadius = 15
            $0.borderWidth = 1
            $0.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        }
    }
    
    override func setLayout() {
        shapes.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        profile.snp.makeConstraints{
            $0.top.equalTo(shapes.snp.top).offset(20)
            $0.centerX.equalToSuperview()
        }
        profileLabel.snp.makeConstraints{
            $0.top.equalTo(profile.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        lineView.snp.makeConstraints{
            $0.top.equalTo(profileLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(3)
        }
        infoStackView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        cardbuttonStackView.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(20)
            $0.width.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
        chatButton.snp.makeConstraints{
            $0.centerY.equalToSuperview()
        }
        gitButton.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            
        }
        chatLabel.snp.makeConstraints{
            $0.center.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layer1 = shapes.layer.sublayers?.first {
            layer1.bounds = shapes.bounds
            layer1.position = shapes.center
        }
    }
}

// 전처리
#if DEBUG

import SwiftUI
@available(iOS 13.0, *)

// UIViewControllerRepresentable을 채택
struct ViewControllerRepresentable: UIViewControllerRepresentable {
    // update
    // _ uiViewController: UIViewController로 지정
    func updateUIViewController(_ uiViewController: UIViewController , context: Context) {
        
    }
    // makeui
    func makeUIViewController(context: Context) -> UIViewController {
    // Preview를 보고자 하는 Viewcontroller 이름
    // e.g.)
        return CardViewController()
    }
}

struct ViewController_Previews: PreviewProvider {
    
    @available(iOS 13.0, *)
    static var previews: some View {
        // UIViewControllerRepresentable에 지정된 이름.
        ViewControllerRepresentable()

// 테스트 해보고자 하는 기기
            .previewDevice("iPhone 11")
    }
}
#endif

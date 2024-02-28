//
//  ConversionSettingsTableViewCell.swift
//  CoPro
//
//  Created by 박신영 on 1/11/24.
//

import UIKit
import SnapKit
import Then


class CardTypeSettingsTableViewCell: UITableViewCell {
   
   let labelContainer: UIView = UIView()
   
   let titleLabel = UILabel().then {
      $0.setPretendardFont(text: "개발자 프로필 화면 설정", size: 17, weight: .medium, letterSpacing: 1.25)
   }
   
   let subTitleLabel = UILabel().then {
      $0.setPretendardFont(text: "개발자 프로필을 카드뷰 혹은 목록으로 확인할 수 있습니다.", size: 13, weight: .regular, letterSpacing: 0.8)
      $0.textColor = UIColor.G3()
   }
   let greaterthanContainer: UIView = UIView()
   
   let greaterthanImage = UIImageView().then {
      $0.image = UIImage(systemName: "chevron.right")
      $0.contentMode = .scaleAspectFill
   }
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      setLayout()
      selectedBackgroundView = UIView()
      
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   func setLayout() {
      contentView.addSubviews(labelContainer, greaterthanContainer)
      greaterthanContainer.isUserInteractionEnabled = true
      labelContainer.addSubviews(titleLabel, subTitleLabel)
      greaterthanContainer.addSubviews(greaterthanImage)
      
      
      labelContainer.snp.makeConstraints {
         $0.leading.equalToSuperview().offset(16)
         $0.trailing.equalTo(greaterthanContainer.snp.leading)
         $0.centerY.equalToSuperview()
      }
      
      titleLabel.snp.makeConstraints {
         $0.top.equalToSuperview()
         $0.leading.equalToSuperview()
      }
      
      subTitleLabel.snp.makeConstraints {
         $0.top.equalTo(titleLabel.snp.bottom)
         $0.bottom.equalToSuperview()
         $0.leading.equalToSuperview()
      }
      
      greaterthanContainer.snp.makeConstraints {
         $0.centerY.equalToSuperview()
         $0.trailing.equalToSuperview().offset(-16)
         $0.width.equalTo(20)
         $0.height.equalTo(20)
      }
      
      greaterthanImage.snp.makeConstraints {
         $0.centerY.equalToSuperview()
         $0.trailing.equalToSuperview()
         $0.width.equalTo(10)
         $0.height.equalTo(13)
      }
   }
}

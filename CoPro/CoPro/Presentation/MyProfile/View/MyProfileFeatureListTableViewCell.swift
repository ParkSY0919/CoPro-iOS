//
//  MyProfileFeatureListTableViewCell.swift
//  CoPro
//
//  Created by 박신영 on 1/11/24.
//

import UIKit
import SnapKit
import Then


class MyProfileFeatureListTableViewCell: UITableViewCell {
   
   let titleLabel = UILabel().then {
      $0.setPretendardFont(text: "test", size: 17, weight: .regular, letterSpacing: 1.25)
   }
   
   let heartContainer: UIView = UIView()
   
   let heartImageView: UIImageView = {
      let imageView = UIImageView()
      imageView.translatesAutoresizingMaskIntoConstraints = false
      if let image = UIImage(systemName: "heart.fill") {
         imageView.image = image
      }
      return imageView
   }()
   
   let heartCountLabel = UILabel().then {
      $0.setPretendardFont(text: "test", size: 17, weight: .regular, letterSpacing: 1.25)
      $0.textColor = UIColor.P2()
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
}

extension MyProfileFeatureListTableViewCell {
   private func setLayout() {
      contentView.addSubviews(titleLabel, heartContainer, greaterthanContainer)
      
      heartContainer.addSubviews(heartImageView, heartCountLabel)
      greaterthanContainer.addSubviews(greaterthanImage)
      
      titleLabel.snp.makeConstraints {
         $0.centerY.equalToSuperview()
         $0.leading.equalToSuperview().offset(16)
      }
      
      heartContainer.snp.makeConstraints {
         $0.centerY.equalToSuperview()
         $0.trailing.equalToSuperview().offset(-16)
         $0.width.equalTo(54)
      }
      
      heartImageView.snp.makeConstraints {
         $0.centerY.equalToSuperview()
         $0.trailing.equalTo(heartCountLabel.snp.leading).offset(-4)
         $0.width.equalTo(20)
         $0.height.equalTo(20)
      }
      
      heartCountLabel.snp.makeConstraints {
         $0.centerY.equalTo(heartImageView)
         $0.trailing.equalToSuperview()
         $0.trailing.equalToSuperview()
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

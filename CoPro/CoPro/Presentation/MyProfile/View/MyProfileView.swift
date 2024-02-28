//
//  MyProfileView.swift
//  CoPro
//
//  Created by 박신영 on 1/7/24.
//

import UIKit
import SnapKit
import Then


class MyProfileView: BaseView {
   
   let profileImage = UIImageView(image : Image.coproLogo)
   let tableView: UITableView = UITableView()
   
   override func setUI() {
      addSubviews(tableView)
      
      tableView.do {
         $0.backgroundColor = UIColor.White()
         $0.separatorInset = UIEdgeInsets.zero
         $0.separatorStyle = .singleLine
         $0.register(ProfileImageTableViewCell.self, forCellReuseIdentifier: "ProfileImageTableViewCell")
         $0.register(MyProfileFeatureListTableViewCell.self, forCellReuseIdentifier: "MyProfileFeatureListTableViewCell")
         $0.register(CardTypeSettingsTableViewCell.self, forCellReuseIdentifier: "CardTypeSettingsTableViewCell")
         $0.showsVerticalScrollIndicator = false
         $0.showsHorizontalScrollIndicator = false
      }
   }
   
   override func setLayout() {
      
      tableView.snp.makeConstraints {
         $0.edges.equalToSuperview()
         $0.centerX.width.equalToSuperview()
      }
   }
   
}


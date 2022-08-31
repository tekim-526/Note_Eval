//
//  PopUpViewController.swift
//  Note_Eval
//
//  Created by Kim TaeSoo on 2022/08/31.
//

import UIKit
import SnapKit

class PopUpViewController: BaseViewController {
    
    let popUpView = PopUpView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func configureUI() {
        view.addSubview(popUpView)
        popUpView.okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        
    }
    override func makeConstraints() {
        popUpView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.height.equalTo(view.snp.height).multipliedBy(0.3)
            make.width.equalTo(view.snp.width).multipliedBy(0.7)
        }
    }
    @objc func okButtonTapped() {
        dismiss(animated: true) {
            UserDefaults.standard.set(true, forKey: "isIntialStart")
        }
    }
}

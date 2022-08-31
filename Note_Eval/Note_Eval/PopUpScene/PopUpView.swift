//
//  PopUpView.swift
//  Note_Eval
//
//  Created by Kim TaeSoo on 2022/08/31.
//

import UIKit

import SnapKit

class PopUpView: BaseView {
    
    let initialLabel: UILabel = {
        let view = UILabel()
        view.text = "처음 오셨군요!\n환영합니다 :)\n\n당신만의메모를 작성하고\n관리해보세요!"
        view.font = .systemFont(ofSize: 20, weight: .heavy)
        view.numberOfLines = 0
        view.textColor = .label
        return view
    }()
    
    let okButton: UIButton = {
        let view = UIButton()
        view.setTitle("확인", for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 20, weight: .heavy)
        view.layer.cornerRadius = 15
        view.setTitleColor(.white, for: .normal)
        view.backgroundColor = .systemOrange
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func configureUI() {
        self.layer.cornerRadius = 15
        [initialLabel, okButton].forEach { self.addSubview($0) }
    }
    override func makeConstraints() {
        let spacing = 16
        initialLabel.snp.makeConstraints { make in
            make.leading.top.equalTo(self.safeAreaLayoutGuide).offset(spacing)
            make.trailing.equalTo(self.safeAreaLayoutGuide).offset(-spacing)
            make.height.equalTo(self.snp.height).multipliedBy(0.6)
        }
        okButton.snp.makeConstraints { make in
            make.leading.equalTo(self.safeAreaLayoutGuide).offset(spacing)
            make.trailing.bottom.equalTo(self.safeAreaLayoutGuide).offset(-spacing)
            make.height.equalTo(self.snp.height).multipliedBy(0.22)
        }
    }
}

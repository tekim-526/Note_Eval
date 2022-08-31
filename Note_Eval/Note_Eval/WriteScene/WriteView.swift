//
//  WriteView.swift
//  Note_Eval
//
//  Created by Kim TaeSoo on 2022/08/31.
//

import UIKit

import SnapKit

class WriteView: BaseView {
    let textView: UITextView = {
        let view = UITextView()
        view.textColor = .label
        view.font = .systemFont(ofSize: 20, weight: .regular)
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
        self.addSubview(textView)
    }
    override func makeConstraints() {
        textView.snp.makeConstraints { make in
            let spacing = 16
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.top.leading.equalTo(spacing)
            make.trailing.equalTo(-spacing)
        }
    }
}

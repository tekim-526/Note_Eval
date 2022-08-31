//
//  NoteListTableViewCell.swift
//  Note_Eval
//
//  Created by Kim TaeSoo on 2022/08/31.
//

import UIKit

import SnapKit

class NoteListTableViewCell: UITableViewCell {
    let titleLabel: UILabel = {
        let view = UILabel()
        view.text = "123"
        view.textColor = .label
        return view
    }()
    let subtitleLabel: UILabel = {
        let view = UILabel()
        view.text = "123"
        view.textColor = .lightGray
        return view
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "NoteListTableViewCell")
        configureUI()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configureUI() {
        [titleLabel, subtitleLabel].forEach { self.addSubview($0) }
    }
    func makeConstraints() {
        let spacing = 12
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(4)
            make.leading.equalTo(spacing)
            make.trailing.equalTo(-spacing)
            make.height.equalTo(self.snp.height).multipliedBy(0.4)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(spacing)
            make.trailing.equalTo(-spacing)
                
        }
    }
}

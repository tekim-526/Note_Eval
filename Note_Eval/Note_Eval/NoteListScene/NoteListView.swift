//
//  HomeView.swift
//  Note_Eval
//
//  Created by Kim TaeSoo on 2022/08/31.
//

import UIKit

import SnapKit

class NoteListView: BaseView {
    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        
        return view
    }()
    
    lazy var toolBar: UIToolbar = {
        let view = UIToolbar()
        view.tintColor = .systemOrange
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
        self.addSubview(tableView)
        self.addSubview(toolBar)
    }
    
    override func makeConstraints() {
        tableView.snp.makeConstraints { $0.edges.equalTo(self.safeAreaLayoutGuide) }
        
        toolBar.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(self.safeAreaLayoutGuide)
        }
    }
}

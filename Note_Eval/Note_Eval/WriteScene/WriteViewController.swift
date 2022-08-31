//
//  WriteViewController.swift
//  Note_Eval
//
//  Created by Kim TaeSoo on 2022/08/31.
//

import UIKit

class WriteViewController: BaseViewController {
    var isNew: Bool = false
    var writeView = WriteView()
    var noteRealm = NoteRealm()
    var task: NoteTable!
    
    override func loadView() {
        view = writeView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func configureUI() {
        navigationItem.largeTitleDisplayMode = .never
    
        let finishBarButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(finishBarButtonTapped))
        let shareBarButtonImage = UIImage(systemName: "square.and.arrow.up")
        let shareBarButton = UIBarButtonItem(image: shareBarButtonImage, style: .done, target: self, action: #selector(shareBarButtonTapped))
        
        navigationController?.navigationBar.tintColor = .systemOrange
        
        
        navigationItem.rightBarButtonItems = [finishBarButton, shareBarButton]
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(#function)
        if writeView.textView.text != "" {
            if isNew {
                noteRealm.addTask(task: NoteTable(writtenString: writeView.textView.text))
            } else if !isNew{
                noteRealm.updateWrittenString(task: task, writtenString: writeView.textView.text)
            }
        } else if isNew == false && writeView.textView.text == "" {
            noteRealm.deleteTask(task: task)
        }
    }
    @objc func finishBarButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func shareBarButtonTapped() {
        
    }
    
}

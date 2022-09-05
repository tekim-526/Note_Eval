//
//  WriteViewController.swift
//  Note_Eval
//
//  Created by Kim TaeSoo on 2022/08/31.
//

import UIKit

class WriteViewController: BaseViewController {
    private var noteRealm = NoteRealm()
    var isNew: Bool = false
    var writeView = WriteView()
    var task: NoteTable!
    
    override func loadView() {
        view = writeView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        writeView.textView.becomeFirstResponder()
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
        
        if writeView.textView.text != "", !writeView.textView.text.allIsWhiteSpace() {
            if isNew {
                noteRealm.addTask(task: NoteTable(writtenString: writeView.textView.text)) { showAlert(title: "메모를 추가할 수 없습니다.", message: nil) }
            } else if !isNew{
                noteRealm.updateWrittenString(task: task, writtenString: writeView.textView.text) { showAlert(title: "메모를 수정할 수 없습니다.", message: nil) }
            }
            
        } else if isNew == false && writeView.textView.text == "" {
            noteRealm.deleteTask(task: task) { showAlert(title: "메모를 지울 수 없습니다.", message: nil) }
        }
    }
    @objc func finishBarButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func shareBarButtonTapped() {
        let text = writeView.textView.text
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        self.present(activityViewController, animated: true)
    }
    
}

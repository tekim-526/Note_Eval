//
//  ViewController.swift
//  Note_Eval
//
//  Created by Kim TaeSoo on 2022/08/31.
//

import UIKit

import RealmSwift

class NoteListViewController: BaseViewController {
    // MARK: - Properties
    
    let noteListView = NoteListView()
    let searchController = UISearchController()
    
    let noteRealm = NoteRealm()
    
    var tasks: Results<NoteTable>! {
        didSet {
            noteListView.tableView.reloadData()
        }
    }
    
    // MARK: - Methods
    override func loadView() {
        view = noteListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        noteListView.tableView.delegate = self
        noteListView.tableView.dataSource = self
        
        noteListView.tableView.register(NoteListTableViewCell.self, forCellReuseIdentifier: "NoteListTableViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tasks = noteRealm.fetch()
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "메모", style: .plain, target: self, action: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let popUpViewController = PopUpViewController()
        if UserDefaults.standard.bool(forKey: "isIntialStart") == false {
            popUpViewController.modalPresentationStyle = .popover
            present(popUpViewController, animated: true)
        
        }
        
    }
    
    override func configureUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "메모"
        navigationItem.searchController = searchController
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let addNoteButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(addNoteButtonTapped))
        noteListView.toolBar.setItems([flexibleSpace, addNoteButton], animated: true)
        
    }
    
    @objc func addNoteButtonTapped() {
        let vc = WriteViewController()
        vc.isNew = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func makeSubtitle(_ date: Date, subTitle: String) -> String {
        let dateFormatter = DateFormatter()
        let todayWeekOfYear = Calendar.current.component(.weekOfYear, from: Date())
        let writtenWeekOfYear = Calendar.current.component(.weekOfYear, from: date)
        
        dateFormatter.dateFormat = "yy-MM-dd"
        
        if dateFormatter.string(from: date) == dateFormatter.string(from: Date()) {
            dateFormatter.dateFormat = "a hh:mm"
        } else if todayWeekOfYear == writtenWeekOfYear {
            dateFormatter.dateFormat = "E"
        } else {
            dateFormatter.dateFormat = "yyyy. MM. dd. a hh:mm"
        }
        return dateFormatter.string(from: date) + " " + subTitle
    }
    
    func trimmedText(cell: NoteListTableViewCell, table: NoteTable) {
        if let text = table.writtenString, text.contains("\n") {
            cell.subtitleLabel.text = makeSubtitle(table.date, subTitle: text[text.index(after: text.firstIndex(of: "\n")!)...].description)
        } else {
            cell.subtitleLabel.text = makeSubtitle(table.date, subTitle: "추가 텍스트 없음")
        }
    }
    
}

// MARK: - Extension
extension NoteListViewController: UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - TableView Delegate & DataSource
    // 섹션 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.filter { $0.isPinned == true }.count == 0 ? 1 : 2
    }
    
    // 섹션별 cell 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.numberOfSections == 2 {
            if section == 0 {
                return noteRealm.fetchBooleanFilter(bool: 1).count
            } else if section == 1 {
                return noteRealm.fetchBooleanFilter(bool: 0).count
            }
        }
        return tasks.count
    }
    
    // cell 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteListTableViewCell") as? NoteListTableViewCell else { return UITableViewCell() }
        if tableView.numberOfSections == 2 {
            if indexPath.section == 0 {
                cell.titleLabel.text = noteRealm.fetchBooleanFilter(bool: 1)[indexPath.row].writtenString
                trimmedText(cell: cell, table: noteRealm.fetchBooleanFilter(bool: 1)[indexPath.row])
            } else if indexPath.section == 1 {
                cell.titleLabel.text = noteRealm.fetchBooleanFilter(bool: 0)[indexPath.row].writtenString
                trimmedText(cell: cell, table: noteRealm.fetchBooleanFilter(bool: 0)[indexPath.row])
            }
        } else if tableView.numberOfSections == 1 {
            cell.titleLabel.text = tasks[indexPath.row].writtenString
            trimmedText(cell: cell, table: noteRealm.fetchBooleanFilter(bool: 0)[indexPath.row])
        }
        
//        if let text = tasks[indexPath.row].writtenString, text.contains("\n") {
//            cell.subtitleLabel.text = makeSubtitle(tasks[indexPath.row].date, subTitle: text[text.index(after: text.firstIndex(of: "\n")!)...].description)
//        } else {
//            cell.subtitleLabel.text = makeSubtitle(tasks[indexPath.row].date, subTitle: "추가 텍스트 없음")
//        }
        return cell
    }
    // 셀 탭했을 때 -> WriteViewController로 이동
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WriteViewController()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "검색", style: .plain, target: self, action: nil)
        if tableView.numberOfSections == 2 {
            if indexPath.section == 0 {
                vc.task = noteRealm.fetchBooleanFilter(bool: 1)[indexPath.row]
                vc.writeView.textView.text = noteRealm.fetchBooleanFilter(bool: 1)[indexPath.row].writtenString
            } else if indexPath.section == 1 {
                vc.task = noteRealm.fetchBooleanFilter(bool: 0)[indexPath.row]
                vc.writeView.textView.text = noteRealm.fetchBooleanFilter(bool: 0)[indexPath.row].writtenString
            }
        } else {
            vc.task = noteRealm.fetchBooleanFilter(bool: 0)[indexPath.row]
            vc.writeView.textView.text = noteRealm.fetchBooleanFilter(bool: 0)[indexPath.row].writtenString
        }
        navigationController?.pushViewController(vc, animated: true)
        
       
    }
    
    // 테이블 뷰 헤더 폰트 및 글자 색상
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        header.textLabel?.textColor = .label
    }
    
    // 오른쪽에서 왼쪽으로 cell 스와이프 해서 요소 제거하기
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: nil) { action, view, handler in
            
            if tableView.numberOfSections == 2 {
                if indexPath.section == 0 {
                    self.noteRealm.deleteTask(task: self.noteRealm.fetchBooleanFilter(bool: 1)[indexPath.row])
                } else if indexPath.section == 1 {
                    self.noteRealm.deleteTask(task: self.noteRealm.fetchBooleanFilter(bool: 0)[indexPath.row])
                }
            } else if tableView.numberOfSections == 1 {
                self.noteRealm.deleteTask(task: self.noteRealm.fetchBooleanFilter(bool: 0)[indexPath.row])
            }
            tableView.reloadData()
        }
        action.image = UIImage(systemName: "trash.fill")
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    // 왼쪽에서 오른쪽으로 cell 스와이프 해서 요소 고정된 메모로 올리기
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: nil) { action, view, handler in
            if tableView.numberOfSections == 2 {
                if indexPath.section == 0 {
                    self.noteRealm.updateIsPinned(task: self.noteRealm.fetchBooleanFilter(bool: 1)[indexPath.row])
                } else if indexPath.section == 1 {
                    self.noteRealm.updateIsPinned(task: self.noteRealm.fetchBooleanFilter(bool: 0)[indexPath.row])
                }
            } else if tableView.numberOfSections == 1 {
                self.noteRealm.updateIsPinned(task: self.noteRealm.fetchBooleanFilter(bool: 0)[indexPath.row])
            }
            tableView.reloadData()
        }
        if tableView.numberOfSections == 2 {
            if indexPath.section == 0 {
                action.image = noteRealm.fetchBooleanFilter(bool: 1)[indexPath.row].isPinned ? UIImage(systemName: "pin.fill") : UIImage(systemName: "pin.slash.fill")
            } else if indexPath.section == 1 {
                action.image = noteRealm.fetchBooleanFilter(bool: 0)[indexPath.row].isPinned ? UIImage(systemName: "pin.fill") : UIImage(systemName: "pin.slash.fill")
            }
        } else if tableView.numberOfSections == 1 {
            action.image = noteRealm.fetchBooleanFilter(bool: 0)[indexPath.row].isPinned ? UIImage(systemName: "pin.fill") : UIImage(systemName: "pin.slash.fill")
        }
        tableView.reloadData()
        print("\(Int.random(in: 1...100))")
        
        action.backgroundColor = .systemOrange
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    // 섹션 헤더 제목 설정
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // tableView.numberOfSections
        if tableView.numberOfSections == 2 {
            if section == 0 {
                return "고정된 메모"
            } else if section == 1 {
                return "메모"
            }
        }
        return "메모"
    
    }
    
    // 섹션 높이
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    // MARK: - SearchController Protocol
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if text != "" {
            tasks = noteRealm.fetchTextFilter(text: text)
        } else {
            tasks = noteRealm.fetch()
        }
        
    }
    
}

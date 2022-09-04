//
//  ViewController.swift
//  Note_Eval
//
//  Created by Kim TaeSoo on 2022/08/31.
//

import UIKit

import RealmSwift

final class NoteListViewController: BaseViewController {
    // MARK: - Properties
    
    private let noteListView = NoteListView()
    private let searchController = UISearchController()
    
    private let noteRealm = NoteRealm()
    
    private var tasks: Results<NoteTable>! {
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
        searchController.searchBar.tintColor = .systemOrange
        
        noteListView.tableView.delegate = self
        noteListView.tableView.dataSource = self
        
        noteListView.tableView.register(NoteListTableViewCell.self, forCellReuseIdentifier: "NoteListTableViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tasks = noteRealm.fetch()
        navigationItem.title = makeNavigationTitle(memoCnt: tasks.count)
        
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
        
        navigationItem.searchController = searchController
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let addNoteButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(addNoteButtonTapped))
        noteListView.toolBar.setItems([flexibleSpace, addNoteButton], animated: true)
        
    }
    
    @objc private func addNoteButtonTapped() {
        let vc = WriteViewController()
        vc.isNew = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func makeNavigationTitle(memoCnt: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        guard let count = numberFormatter.string(for: memoCnt) else { return "?"}
        return count + "개의 메모"
    }
    
    // MARK: - Cell-Related Methods
    private func makeSubtitle(_ date: Date, subTitle: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko-KR")
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
    
    private func trimmedText(cell: NoteListTableViewCell, table: NoteTable) {
        if let text = table.writtenString, text.contains("\n") {
            cell.subtitleLabel.text = makeSubtitle(table.date, subTitle: text[text.index(after: text.firstIndex(of: "\n")!)...].description).replacingOccurrences(of: "\n", with: " ")
        } else {
            cell.subtitleLabel.text = makeSubtitle(table.date, subTitle: "추가 텍스트 없음")
        }
    }
    
    private func configureCellWithBoolFilter(cell: NoteListTableViewCell, indexPath: IndexPath, isPinned: Int) {
        cell.titleLabel.attributedText = makeAttributedString(task: noteRealm.fetchBooleanFilter(isPinned: isPinned)[indexPath.row])
        trimmedText(cell: cell, table: noteRealm.fetchBooleanFilter(isPinned: isPinned)[indexPath.row])
    }
    private func configureCellWithTextAndBoolFilter(cell: NoteListTableViewCell, indexPath: IndexPath, text: String, isPinned: Int) {
        cell.titleLabel.attributedText = makeAttributedString(task: noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: isPinned)[indexPath.row])
        trimmedText(cell: cell, table: noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: isPinned)[indexPath.row])
    }
    private func passingData(vc: WriteViewController, task: NoteTable) {
        vc.task = task
        vc.writeView.textView.text = task.writtenString
    }
    private func makeAttributedString(task: NoteTable) -> NSAttributedString {
        return task.writtenString?.highlightText(searchController.searchBar.text ?? "", with: .systemOrange, caseInsensitive: true) ?? NSAttributedString()
    }
    private func setLeadingSwipeImage(isPinned: Int, item: Int) -> UIImage? {
        return noteRealm.fetchBooleanFilter(isPinned: isPinned)[item].isPinned ? UIImage(systemName: "pin.slash.fill") : UIImage(systemName: "pin.fill")
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
                if let text = searchController.searchBar.text, text != "", searchController.isActive {
                    return noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: 1).count
                } else {
                    return noteRealm.fetchBooleanFilter(isPinned: 1).count
                }
            } else if section == 1 {
                if let text = searchController.searchBar.text, text != "", searchController.isActive {
                    return noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: 0).count
                } else {
                    return noteRealm.fetchBooleanFilter(isPinned: 0).count
                }
            }
        }
        return tasks.count
    }
    
    // cell 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteListTableViewCell") as? NoteListTableViewCell else { return UITableViewCell() }
        
        if tableView.numberOfSections == 2 {
            if indexPath.section == 0 {
                if let text = searchController.searchBar.text, text != "", searchController.isActive {
                    configureCellWithTextAndBoolFilter(cell: cell, indexPath: indexPath, text: text, isPinned: 1)
                } else {
                    configureCellWithBoolFilter(cell: cell, indexPath: indexPath, isPinned: 1)
                }
            } else if indexPath.section == 1 {
                if let text = searchController.searchBar.text, text != "", searchController.isActive {
                    configureCellWithTextAndBoolFilter(cell: cell, indexPath: indexPath, text: text, isPinned: 0)
                } else {
                    configureCellWithBoolFilter(cell: cell, indexPath: indexPath, isPinned: 0)
                }
            }
        } else if tableView.numberOfSections == 1 {
            cell.titleLabel.attributedText = makeAttributedString(task: tasks[indexPath.row])
            trimmedText(cell: cell, table: tasks[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // 셀 탭했을 때 -> WriteViewController로 이동
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WriteViewController()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "검색", style: .plain, target: self, action: nil)
        if tableView.numberOfSections == 2 {
            if indexPath.section == 0 {
                if let text = searchController.searchBar.text, text != "", searchController.isActive {
                    passingData(vc: vc, task: noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: 1)[indexPath.row])
                } else {
                    passingData(vc: vc, task: noteRealm.fetchBooleanFilter(isPinned: 1)[indexPath.row])
                }
            } else if indexPath.section == 1 {
                if let text = searchController.searchBar.text, text != "", searchController.isActive {
                    passingData(vc: vc, task: noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: 0)[indexPath.row])
                } else {
                    passingData(vc: vc, task: noteRealm.fetchBooleanFilter(isPinned: 0)[indexPath.row])
                }
            }
        } else if tableView.numberOfSections == 1 {
            passingData(vc: vc, task: tasks[indexPath.row])
            
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
                    if let text = self.searchController.searchBar.text, text != "", self.searchController.isActive {
                        self.noteRealm.deleteTask(task: self.noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: 1)[indexPath.row])
                    } else {
                        self.noteRealm.deleteTask(task: self.noteRealm.fetchBooleanFilter(isPinned: 1)[indexPath.row])
                    }
                } else if indexPath.section == 1 {
                    if let text = self.searchController.searchBar.text, text != "", self.searchController.isActive {
                        self.noteRealm.deleteTask(task: self.noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: 0)[indexPath.row])
                    } else {
                        self.noteRealm.deleteTask(task: self.noteRealm.fetchBooleanFilter(isPinned: 0)[indexPath.row])
                    }                }
            } else if tableView.numberOfSections == 1 {
                self.noteRealm.deleteTask(task: self.tasks[indexPath.row])
            }
            
            self.navigationItem.title = self.makeNavigationTitle(memoCnt: self.tasks.count)
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
                    self.noteRealm.updateIsPinned(task: self.noteRealm.fetchBooleanFilter(isPinned: 1)[indexPath.row])
                } else if indexPath.section == 1 {
                    if self.noteRealm.fetchBooleanFilter(isPinned: 1).count > 4 {
                        self.showAlert(title: "고정된 메모는 최대 5개 까지 등록 가능합니다.", message: nil)
                    } else {
                        self.noteRealm.updateIsPinned(task: self.noteRealm.fetchBooleanFilter(isPinned: 0)[indexPath.row])
                    }
                }
            } else if tableView.numberOfSections == 1 {
                self.noteRealm.updateIsPinned(task: self.noteRealm.fetchBooleanFilter(isPinned: 0)[indexPath.row])
            }
            tableView.reloadData()
        }
        if tableView.numberOfSections == 2 {
            if indexPath.section == 0 {
                action.image = setLeadingSwipeImage(isPinned: 1, item: indexPath.row)
            } else if indexPath.section == 1 {
                action.image = setLeadingSwipeImage(isPinned: 0, item: indexPath.row)
            }
        } else if tableView.numberOfSections == 1 {
            action.image = setLeadingSwipeImage(isPinned: 0, item: indexPath.row)
        }
        tableView.reloadData()
        
        
        action.backgroundColor = .systemOrange
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    // 섹션 헤더 제목 설정
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let text = searchController.searchBar.text, text != "", searchController.isActive {
            return section == 1 ? "메모 - \(noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: 0).count)개 찾음" : "고정된 메모 - \(noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: 1).count)개 찾음"
        }
        if tableView.numberOfSections == 2 {
            if section == 0 {
                return "고정된 메모"
            } else if section == 1 {
                return "메모"
            }
        }
        return "메모"
        
    }
    func makeif(numberOfSections: Int, indexPath: IndexPath ,completion: @escaping () -> Void) {
        if numberOfSections == 2 {
            if indexPath.section == 0 {
               completion()
            } else if indexPath.section == 1 {
                completion()
            }
        } else if numberOfSections == 1 {
            completion()
        }
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

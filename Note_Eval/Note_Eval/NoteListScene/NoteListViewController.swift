//
//  ViewController.swift
//  Note_Eval
//
//  Created by Kim TaeSoo on 2022/08/31.
//

import UIKit

import RealmSwift
import RxCocoa
import RxSwift

final class NoteListViewController: BaseViewController {
    // MARK: - Properties
    
    private let noteListView = NoteListView()
    private let searchController = UISearchController()
    
    private let noteRealm = NoteRealm()
    private var noteViewModel: NoteListViewModel!
    
    private let disposeBag = DisposeBag()
    private var tasks: Results<NoteTable>! {
        didSet {
            noteListView.tableView.reloadData()
        }
    }
    lazy var tasksCount = BehaviorSubject(value: tasks.count)
    
    // MARK: - Methods
    override func loadView() {
        view = noteListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteViewModel = NoteListViewModel(searchedText: searchController.searchBar.text)
        searchController.searchResultsUpdater = self
        searchController.searchBar.tintColor = .systemOrange
        
        noteListView.tableView.delegate = self
        noteListView.tableView.dataSource = self
        
        noteListView.tableView.register(NoteListTableViewCell.self, forCellReuseIdentifier: "NoteListTableViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bind()
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
    func bind() {
        tasks = noteRealm.fetch()
        tasksCount.onNext(tasks.count)
        tasksCount
            .map { "\($0)개의 메모" }
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)

    }
    override func configureUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let addNoteButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: nil)
        
        addNoteButton.rx.tap.bind { _ in
            let vc = WriteViewController()
            vc.isNew = true
            self.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)

        noteListView.toolBar.setItems([flexibleSpace, addNoteButton], animated: true)
        
    }
    func passingData(vc: WriteViewController, task: NoteTable) {
        vc.task = task
        vc.writeView.textView.text = task.writtenString
    }
}

// MARK: - Extension
extension NoteListViewController: UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - TableView Delegate & DataSource
    // 섹션 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        if tasks.count == 0 {
            return 0
        }
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
        noteViewModel.categorizingWithSection(numberOfSections: tableView.numberOfSections, indexPath: indexPath) {
            if let text = searchController.searchBar.text, text != "", searchController.isActive {
                cell.titleLabel.attributedText = noteViewModel.configureCellWithTextAndBoolFilter(indexPath: indexPath, text: text, isPinned: 1).title
                cell.subtitleLabel.attributedText = noteViewModel.configureCellWithTextAndBoolFilter(indexPath: indexPath, text: text, isPinned: 1).subtitle
//                noteViewModel.configureCellWithTextAndBoolFilter(cell: cell, indexPath: indexPath, text: text, isPinned: 1)
            } else {
                cell.titleLabel.attributedText = noteViewModel.configureCellWithBoolFilter(indexPath: indexPath, isPinned: 1).title
                cell.subtitleLabel.attributedText = noteViewModel.configureCellWithBoolFilter(indexPath: indexPath, isPinned: 1).subtitle
            }
        } notPinnedCompletion: {
            if let text = searchController.searchBar.text, text != "", searchController.isActive {
                cell.titleLabel.attributedText = noteViewModel.configureCellWithTextAndBoolFilter(indexPath: indexPath, text: text, isPinned: 0).title
                cell.subtitleLabel.attributedText = noteViewModel.configureCellWithTextAndBoolFilter(indexPath: indexPath, text: text, isPinned: 0).subtitle
//                noteViewModel.configureCellWithTextAndBoolFilter(cell: cell, indexPath: indexPath, text: text, isPinned: 0)
            } else {
                cell.titleLabel.attributedText = noteViewModel.configureCellWithBoolFilter(indexPath: indexPath, isPinned: 0).title
                cell.subtitleLabel.attributedText = noteViewModel.configureCellWithBoolFilter(indexPath: indexPath, isPinned: 0).subtitle
            }
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
        
        self.noteViewModel.categorizingWithSection(numberOfSections: tableView.numberOfSections, indexPath: indexPath) {
            if let text = searchController.searchBar.text, text != "", searchController.isActive {
                passingData(vc: vc, task: noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: 1)[indexPath.row])
            } else {
                passingData(vc: vc, task: noteRealm.fetchBooleanFilter(isPinned: 1)[indexPath.row])
            }
        } notPinnedCompletion: {
            if let text = searchController.searchBar.text, text != "", searchController.isActive {
                passingData(vc: vc, task: noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: 0)[indexPath.row])
            } else {
                passingData(vc: vc, task: noteRealm.fetchBooleanFilter(isPinned: 0)[indexPath.row])
            }
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
            self.noteViewModel.categorizingWithSection(numberOfSections: tableView.numberOfSections, indexPath: indexPath) { 
                if let text = self.searchController.searchBar.text, text != "", self.searchController.isActive {
                    self.noteRealm.deleteTask(task: self.noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: 1)[indexPath.row]) { self.showAlert(title: "메모를 지울 수 없습니다.", message: nil) }
                } else {
                    self.noteRealm.deleteTask(task: self.noteRealm.fetchBooleanFilter(isPinned: 1)[indexPath.row]) { self.showAlert(title: "메모를 지울 수 없습니다.", message: nil) }
                }
            } notPinnedCompletion: {
                if let text = self.searchController.searchBar.text, text != "", self.searchController.isActive {
                    self.noteRealm.deleteTask(task: self.noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: 0)[indexPath.row]) { self.showAlert(title: "메모를 지울 수 없습니다.", message: nil) }
                } else {
                    self.noteRealm.deleteTask(task: self.noteRealm.fetchBooleanFilter(isPinned: 0)[indexPath.row]) { self.showAlert(title: "메모를 지울 수 없습니다.", message: nil) }
                }
            }
            self.tasksCount.onNext(self.tasks.count)
            tableView.reloadData()
        }
        
        action.image = UIImage(systemName: "trash.fill")
        let configuration = UISwipeActionsConfiguration(actions: [action])
        
        return configuration
    }
    
    // 왼쪽에서 오른쪽으로 cell 스와이프 해서 요소 고정된 메모로 올리기
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: nil) { action, view, handler in
            self.noteViewModel.categorizingWithSection(numberOfSections: tableView.numberOfSections, indexPath: indexPath) {
                self.noteRealm.updateIsPinned(task: self.noteRealm.fetchBooleanFilter(isPinned: 1)[indexPath.row]) { self.showAlert(title: "메모를 고정할 수 없습니다.", message: nil) }
            } notPinnedCompletion: {
                if self.noteRealm.fetchBooleanFilter(isPinned: 1).count > 4 {
                    self.showAlert(title: "고정된 메모는 최대 5개 까지 등록 가능합니다.", message: nil)
                } else {
                    self.noteRealm.updateIsPinned(task: self.noteRealm.fetchBooleanFilter(isPinned: 0)[indexPath.row]) { self.showAlert(title: "메모를 고정할 수 없습니다.", message: nil) }
                }
            }
            tableView.reloadData()
        }
        noteViewModel.categorizingWithSection(numberOfSections: tableView.numberOfSections, indexPath: indexPath) {
            let systemName = noteViewModel.setLeadingSwipeImage(isPinned: 1, item: indexPath.row)
            action.image = UIImage(systemName: systemName)
        } notPinnedCompletion: {
            let systemName = noteViewModel.setLeadingSwipeImage(isPinned: 0, item: indexPath.row)
            action.image = UIImage(systemName: systemName)
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
    
    // 섹션 높이
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    // MARK: - SearchController Protocol
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        noteViewModel.searchedText = searchController.searchBar.text
        if text != "" {
            tasks = noteRealm.fetchTextFilter(text: text)
            
        } else {
            tasks = noteRealm.fetch()
        }
        
    }
}

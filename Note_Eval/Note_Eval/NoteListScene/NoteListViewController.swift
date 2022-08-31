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
    let pinnedRealm = NoteRealm()
    
    var tasks: Results<NoteTable>! {
        didSet {
            noteListView.tableView.reloadData()
        }
    }
    var pinnedTasks: Results<NoteTable>! {
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
        noteListView.tableView.delegate = self
        noteListView.tableView.dataSource = self
        
        noteListView.tableView.register(NoteListTableViewCell.self, forCellReuseIdentifier: "NoteListTableViewCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tasks = noteRealm.fetch()
        pinnedTasks = pinnedRealm.fetch()
        
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
}

// MARK: - Extension
extension NoteListViewController: UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - TableView Delegate $ DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return pinnedTasks?.isEmpty == nil ? 1 : 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? pinnedTasks?.count ?? tasks.count : tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteListTableViewCell") as? NoteListTableViewCell else { return UITableViewCell() }
        if indexPath.section == 1 {
            cell.titleLabel.text = tasks[indexPath.row].writtenString
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WriteViewController()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "검색", style: .plain, target: self, action: nil)
        vc.task = tasks[indexPath.row]
        vc.writeView.textView.text = tasks[indexPath.row].writtenString
        
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        header.textLabel?.textColor = .label
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: nil) { action, view, handler in
            self.noteRealm.deleteTask(task: self.tasks[indexPath.row])
            
            tableView.reloadData()
        }
        action.image = UIImage(systemName: "trash.fill")
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: nil) { action, view, handler in
            self.noteRealm.updateIsPinned(task: self.tasks[indexPath.row])
            self.pinnedRealm.addTask(task: self.tasks[indexPath.row])
            self.noteRealm.deleteTask(task: self.tasks[indexPath.row])
            tableView.reloadData()
        }
        action.image = tasks[indexPath.row].isPinned ? UIImage(systemName: "pin.fill") : UIImage(systemName: "pin.slash.fill")
        action.backgroundColor = .systemOrange
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
           return "메모"
        } else if section <= 0 {
            return "고정된 메모"
        } else {
            return "메모"
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    // MARK: - SearchController Protocol
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
    }
    
    
}

//
//  NoteListViewModel.swift
//  Note_Eval
//
//  Created by Kim TaeSoo on 2022/10/27.
//

import UIKit
import RxSwift
import RxCocoa

class NoteListViewModel {
    let searchController: UISearchController!
    let noteRealm = NoteRealm()
    init(searchController: UISearchController!) {
        self.searchController = searchController
    }
    func makeNavigationTitle(memoCnt: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        guard let count = numberFormatter.string(for: memoCnt) else { return "?"}
        return count + "개의 메모"
    }
    
    func makeAttributedString(text: String?, font: UIFont? = nil) -> NSAttributedString {
        return text?.highlightText(searchController.searchBar.text ?? "", with: .systemOrange, font: font ?? .preferredFont(forTextStyle: .body)) ?? NSAttributedString()
    }
    
    func trimmedText(cell: NoteListTableViewCell, table: NoteTable) {
        guard let text = table.writtenString else { return }
        if text.contains("\n") {
            let subtitle = makeSubtitle(table.date, subTitle: text[text.index(after: text.firstIndex(of: "\n")!)...].description).replacingOccurrences(of: "\n", with: " ")
            cell.subtitleLabel.attributedText = makeAttributedString(text: subtitle, font: .systemFont(ofSize: 13))
        } else {
            cell.subtitleLabel.text = makeSubtitle(table.date, subTitle: "추가 텍스트 없음")
        }
    }
    
    func configureCellWithBoolFilter(cell: NoteListTableViewCell, indexPath: IndexPath, isPinned: Int) {
        cell.titleLabel.attributedText = makeAttributedString(text: noteRealm.fetchBooleanFilter(isPinned: isPinned)[indexPath.row].writtenString)
        trimmedText(cell: cell, table: noteRealm.fetchBooleanFilter(isPinned: isPinned)[indexPath.row])
    }
    
    func configureCellWithTextAndBoolFilter(cell: NoteListTableViewCell, indexPath: IndexPath, text: String, isPinned: Int) {
        cell.titleLabel.attributedText = makeAttributedString(text: noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: isPinned)[indexPath.row].writtenString)
        trimmedText(cell: cell, table: noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: isPinned)[indexPath.row])
    }
    
    func passingData(vc: WriteViewController, task: NoteTable) {
        vc.task = task
        vc.writeView.textView.text = task.writtenString
    }
    
    func setLeadingSwipeImage(isPinned: Int, item: Int) -> UIImage? {
        return noteRealm.fetchBooleanFilter(isPinned: isPinned)[item].isPinned ? UIImage(systemName: "pin.slash.fill") : UIImage(systemName: "pin.fill")
    }
    
    func makeSubtitle(_ date: Date, subTitle: String) -> String {
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
    
    func categorizingWithSection(numberOfSections: Int, indexPath: IndexPath , pinnedCompletion: () -> Void, notPinnedCompletion: () -> Void) {
        if numberOfSections == 2 {
            if indexPath.section == 0 {
                pinnedCompletion()
            } else if indexPath.section == 1 {
                notPinnedCompletion()
            }
        } else if numberOfSections == 1 {
            notPinnedCompletion()
        }
    }
}

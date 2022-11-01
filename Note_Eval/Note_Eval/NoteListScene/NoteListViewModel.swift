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
    var searchedText: String?
    let noteRealm = NoteRealm()
    
    init(searchedText: String?) {
        self.searchedText = searchedText
    }
    
    func makeNavigationTitle(memoCnt: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        guard let count = numberFormatter.string(for: memoCnt) else { return "?"}
        return count + "개의 메모"
    }
    
    func makeAttributedString(text: String?, font: UIFont? = nil) -> NSAttributedString {
        return text?.highlightText(searchedText ?? "", with: .systemOrange, font: font ?? .preferredFont(forTextStyle: .body)) ?? NSAttributedString()
    }
    
    func trimmedText(table: NoteTable) -> NSAttributedString? {
        guard let text = table.writtenString else { return nil }
        if text.contains("\n") {
            let subtitle = makeSubtitle(table.date, subTitle: text[text.index(after: text.firstIndex(of: "\n")!)...].description).replacingOccurrences(of: "\n", with: " ")
            return makeAttributedString(text: subtitle, font: .systemFont(ofSize: 13))
        } else {
            return makeAttributedString(text: makeSubtitle(table.date, subTitle: "추가 텍스트 없음"), font: .systemFont(ofSize: 13))
        }
    }
    
    // 리스트 처음 나왔을 때 엔트리포인트
    func configureCellWithBoolFilter(indexPath: IndexPath, isPinned: Int) -> (title: NSAttributedString?, subtitle : NSAttributedString?) {
        let title = makeAttributedString(text: noteRealm.fetchBooleanFilter(isPinned: isPinned)[indexPath.row].writtenString)
        let subtitle = trimmedText(table: noteRealm.fetchBooleanFilter(isPinned: isPinned)[indexPath.row])
        return (title, subtitle)
    }
    
    // 검색들어갔을 때
    func configureCellWithTextAndBoolFilter(indexPath: IndexPath, text: String, isPinned: Int) -> (title: NSAttributedString?, subtitle : NSAttributedString?) {
        let title = makeAttributedString(text: noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: isPinned)[indexPath.row].writtenString)
        let subtitle = trimmedText(table: noteRealm.fetchTextAndBooleanFilter(text: text, isPinned: isPinned)[indexPath.row])
        return (title, subtitle)
    }
    
    
    func setLeadingSwipeImage(isPinned: Int, item: Int) -> String {
        return noteRealm.fetchBooleanFilter(isPinned: isPinned)[item].isPinned ? "pin.slash.fill" : "pin.fill"
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

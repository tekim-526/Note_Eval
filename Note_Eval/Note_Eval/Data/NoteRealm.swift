//
//  NoteRealm.swift
//  Note_Eval
//
//  Created by Kim TaeSoo on 2022/08/31.
//

import Foundation
import RealmSwift

class NoteRealm {
    let localRealm = try! Realm()
    
    func fetch() -> Results<NoteTable> {
        return localRealm.objects(NoteTable.self).sorted(byKeyPath: "date", ascending: false)
    }
    func fetchTextFilter(text: String) -> Results<NoteTable> {
        return localRealm.objects(NoteTable.self).filter("writtenString CONTAINS[c] '\(text)'").sorted(byKeyPath: "date", ascending: false)
    }
    func fetchBooleanFilter(isPinned: Int) -> Results<NoteTable> {
        return localRealm.objects(NoteTable.self).filter("isPinned == %@", isPinned).sorted(byKeyPath: "date", ascending: false)
    }
    func fetchTextAndBooleanFilter(text: String, isPinned: Int) -> Results<NoteTable> {
        return localRealm.objects(NoteTable.self).filter("isPinned == %@", isPinned).filter("writtenString CONTAINS[c] '\(text)'").sorted(byKeyPath: "date", ascending: false)
    }
    
    func updateIsPinned(task: NoteTable, completion: () -> Void) {
        do {
            try localRealm.write {
                task.isPinned.toggle()
            }
        } catch {
            completion()
        }
    }
    func updateWrittenString(task: NoteTable, writtenString: String?, completion: () -> Void) {
        do {
            try localRealm.write {
                task.writtenString = writtenString
            }
        } catch {
            completion()
        }
    }
    func addTask(task: NoteTable, completion: () -> Void) {
        do {
            try localRealm.write {
                localRealm.add(task)
            }
        } catch {
            completion()
        }
    }
    func deleteTask(task: NoteTable, completion: () -> Void) {
        do {
            try localRealm.write {
                localRealm.delete(task)
            }
        } catch {
            completion()
        }
    }
   
}



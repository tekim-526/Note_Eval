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
        print(localRealm.configuration.fileURL!)
        return localRealm.objects(NoteTable.self).sorted(byKeyPath: "date", ascending: false)
    }
    func fetchTextFilter(text: String) -> Results<NoteTable> {
        return localRealm.objects(NoteTable.self).filter("writtenString CONTAINS[c] '\(text)'")
    }
    func fetchBooleanFilter(bool: Int) -> Results<NoteTable> {
        return localRealm.objects(NoteTable.self).filter("isPinned == %@", bool)
    }
    
    
    func updateIsPinned(task: NoteTable) {
        do {
            try localRealm.write {
                task.isPinned.toggle()
            }
        } catch {
            print(error)
        }
    }
    func updateWrittenString(task: NoteTable, writtenString: String?) {
        do {
            try localRealm.write {
                task.writtenString = writtenString
            }
        } catch {
            print(error)
        }
    }
    func addTask(task: NoteTable) {
        do {
            try localRealm.write {
                localRealm.add(task)
            }
        } catch {
            print(error)
        }
    }
    func deleteTask(task: NoteTable) {
        do {
            try localRealm.write {
                localRealm.delete(task)
            }
        } catch {
            print(error)
        }
    }
   
}



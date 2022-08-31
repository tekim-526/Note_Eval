//
//  NoteTable.swift
//  Note_Eval
//
//  Created by Kim TaeSoo on 2022/08/31.
//

import Foundation
import RealmSwift


class NoteTable: Object {
    @Persisted var writtenString: String?
    @Persisted var date: Date = Date()
    @Persisted var isPinned: Bool = false
    
    @Persisted(primaryKey: true) var objectId : ObjectId
    
    convenience init(writtenString: String?) {
        self.init()
        self.writtenString = writtenString
        
    }
}



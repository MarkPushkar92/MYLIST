//
//  StorageManager.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 01.10.2022.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write({
            realm.add(place)
        })
    }
    
    static func deleteObj(_ place: Place) {
        try! realm.write({
            realm.delete(place)
        })
    }
}

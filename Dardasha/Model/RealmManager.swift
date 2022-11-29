//
//  RealmManager.swift
//  Dardasha
//
//  Created by Ahmed on 13/09/2022.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    
    let realm = try! Realm()
    
    private init (){}
    
    func save<T: Object> (_ object: T){
        
        do {
            try realm.write {
                realm.add(object, update: .all)
            }
        }catch{
            print("Error saving data: ",error.localizedDescription)
        }
    }
}

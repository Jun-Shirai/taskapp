//
//  Category.swift
//  taskapp
//
//  Created by 白井淳 on 2021/02/04.
//

import RealmSwift

class Category: Object {
    
    //管理用ID。プライマリーキー
    @objc dynamic var id = 0
    
    //カテゴリ項目
    @objc dynamic var item = ""
    
    //idをプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}



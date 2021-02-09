//
//  ItemViewController.swift
//  taskapp
//
//  Created by 白井淳 on 2021/02/04.
//

import UIKit
import RealmSwift

class ItemViewController: UIViewController {
    
    @IBOutlet weak var itemTextField: UITextField!
    
    //プロパティ
    let realm = try!Realm()
    
    var item: Category!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //背景をタップしたらdismissKeyboardを呼ぶように設定
        //背景にこのUI部品を登録するためにtapGestureと値を設定
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //背景はviewプロパティに該当するため、これに登録
        self.view.addGestureRecognizer(tapGesture)
        
        itemTextField.text = item.item
    }
    //
    @objc func dismissKeyboard() {
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    //遷移するときに画面が非表示になるときに呼ばれるメソッド
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.item.item = self.itemTextField.text!
            self.realm.add(self.item,update: .modified)
        }
        super.viewWillDisappear(animated)  //作成したものを保存する
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

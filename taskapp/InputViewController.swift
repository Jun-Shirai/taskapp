//
//  InputViewController.swift
//  taskapp
//
//  Created by 白井淳 on 2021/01/30.
//

import UIKit
import RealmSwift //追加する
import UserNotifications//追加する。ローカル通知の登録のため

class InputViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!  //カテゴリー追加のため
    
    //プロパティ
    let realm = try! Realm()  //追加する
    var task: Task! //追加する
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //背景をタップしたらdismissKeyboardを呼ぶように設定する
        //タップしたときに動作するようターゲット（InputViewController）とメソッド（dismissKeyboard）を指定
        //背景にこのUI部品を登録するために、tapGestureと値を設定
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //背景はviewプロパティに該当するため、これに登録
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        categoryTextField.text = task.category
        datePicker.date = task.date
    }
    //上記によって呼び出される関数
    @objc func dismissKeyboard() {
        //キーボードを閉じる
        view.endEditing(true)
    }
    //追加する。遷移に伴い画面が非表示になるときに呼ばれる動作・メソッド
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = self.categoryTextField.text! //カテゴリー追加のため
            self.realm.add(self.task,update: .modified)
        }
        setNotification(task: task)
        //↑ローカル通知の設定
        //タスク作成・編集画面から一覧への戻り、データベースにタスクを保存するタイミングでローカル通知の設定もあわせてする
        
        super.viewWillDisappear(animated)
    }
    
    //上記の動作を下記に設定しタスクのローカル通知を登録する。ーーここからーー
    func setNotification(task: Task) {
        //タイトルや内容を設定するためのインスタンスを生成
        let content = UNMutableNotificationContent()
        //タイトルと内容を設定（中身がない場合メッセージなしで音だけの通知になるので「xxなし」を表示する）
        if task.title == "" {
            content.title = "(タイトルなし)"
        }else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        }else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
    
    //ローカル通知が発動するtrigger（日付マッチ）を作成
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: task.date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
    //identifier,content,triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
    //このidentifi/Users/shiraiatsushi/Documents/taskapp/taskapp/Assets.xcassetserはsegueのものではない
    let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
    
    //ローカル通知を登録
    let center = UNUserNotificationCenter.current()
        center.add(request) {(error) in
        print(error ?? "ローカル通知登録　OK")
    //errorがnilならローカル通知の登録に成功したと表示する。errorが存在すればerrorと表示する。
    }
    
    //未通知のローカル通知一覧をログ出力＊get pending：保留中　という意味
    center.getPendingNotificationRequests {(requests: [UNNotificationRequest]) in
        for request in requests {
            print("/-------------")
            print(request)
            print("-------------/")
            
        }
        
    }
}//ーーここまで追加ーー
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

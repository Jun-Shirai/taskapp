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
    
    //プロパティ
    let realm = try! Realm()  //追加する
    var task: Task! //追加する
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //背景をタップしたらdismissKeyboardを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
    }
    
    @objc func dismissKeyboard() {
        //キーボードを閉じる
        view.endEditing(true)
    }
    //追加する。遷移するときに画面が非表示になる
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task,update: .modified)
        }
        setNotification(task: task) //追加する。ローカル通知の登録のため
        
        super.viewWillDisappear(animated)
    }
    
    //タスクのローカル通知を登録する。ーーここからーー
    func setNotification(task: Task) {
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
    let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
    
    //ローカル通知を登録
    let center = UNUserNotificationCenter.current()
        center.add(request) {(error) in
        print(error ?? "ローカリ通知登録　OK")
    //errorがnilならローカル通知の登録に成功したと表示する。errorが存在すればerrorと表示する。
    }
    
    //未通知のローカル通知一覧をログ出力
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

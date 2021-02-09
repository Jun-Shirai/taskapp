//
//  InputViewController.swift
//  taskapp
//
//  Created by 白井淳 on 2021/01/30.
//

import UIKit
import RealmSwift
import UserNotifications//ローカル通知の登録のため

class InputViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!  //カテゴリテキスト用
    @IBOutlet weak var tableView: UITableView!  //カテゴリ選択一覧用
    
    //プロパティ
    let realm = try! Realm()
    var task: Task!
    var categoryArray = try! Realm().objects(Category.self) //Categoryクラスを引っ張ってきてリスト生成
    
    var pickerView = UIPickerView()  //ピッカービューのインスタンスを取得
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //デリゲート指定
        tableView.delegate = self
        tableView.dataSource = self
        
        
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
        
        //ピッカービューのデリゲート指定
        pickerView.delegate = self
        pickerView.dataSource = self
        
        categoryTextField.inputView = pickerView
        
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
        toolbar.setItems([doneButtonItem], animated: true)
        categoryTextField.inputAccessoryView = toolbar
    }
    //キーボードを閉じる関数
    @objc func dismissKeyboard() {
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    //ツールバーを閉じる関数
    @objc func donePicker() {
        categoryTextField.endEditing(true)
    }
    
//UIPickerViewのデリゲートメソッドなどを記述
    //表示する列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //表示するデータの数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    //表示するデータの登録
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArray[row].item
    }
    //データが選択されたときに呼ばれるメソッド
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = categoryArray[row].item
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        categoryTextField.endEditing(true)
    }
    
//カテゴリー：データ（セル）の数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なセルへ
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseCell", for: indexPath)
        //Cellの値を設定
        let itemcategory = categoryArray[indexPath.row]
        cell.textLabel?.text = itemcategory.item
        
        return cell
    }
    
    //各セルを(InputVieaControllerより)選択したときに実行されるメソッド：遷移
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セグエのidentifierに名前つけて指定しよう
        performSegue(withIdentifier: "inputcellSegue", sender: nil)
    }
    
    //セルの削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return.delete
    }
    //Deleteボタンが押されたときに呼び出されるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //データベースからタスクを削除
            try! realm.write {
                self.realm.delete(self.categoryArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    //segueでタスク作成画面からカテゴリ作成画面へ遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //itemViewControllerを取得
        let itemViewController: ItemViewController = segue.destination as! ItemViewController
        
        //セルをタップしたときに作成済みのカテゴリ一覧から該当するCategoryクラスのインスタンスを取得していく
        if segue.identifier == "inputcellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            itemViewController.item = categoryArray[indexPath!.row]  //渡す値
        }else {
            //「新規作成」をタップしたときに新たなインスタンスの生成とidの設定をする
            let item = Category()
            
            let allitems = realm.objects(Category.self)
            if allitems.count != 0 {
                item.id = allitems.max(ofProperty: "id")! + 1
                
            }
            itemViewController.item = item //渡す値
        }
    }
    //カテゴリ作成画面からもどってきたときにTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
        
        super.viewWillDisappear(animated)  //作成したものを保存する
    }
    
    //上記の動作を下記に設定しタスクのローカル通知を登録する。
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

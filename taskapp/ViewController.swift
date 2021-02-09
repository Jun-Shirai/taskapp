//
//  ViewController.swift
//  taskapp
//
//  Created by 白井淳 on 2021/01/30.
//

import UIKit
import RealmSwift //Realmのデータベース準備するため。
import UserNotifications //タスク削除のときに通知キャンセルをするために

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
 
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var textField: UITextField!
    
    //Realmインスタンスを取得する。これを使ってメソッドを呼び出す。
    let realm = try! Realm()
    
    //DB内のタスクが格納されるリスト。「Task」はTask.swiftからのもの。
    //日付の近い順でソート：昇順
    //以降内容をアプデするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    //↑追加。これでデータベースの準備ができた。
    
    var pickerTextView = UIPickerView()  //ピッカービューのインスタンスを取得
    var categoryArray = try! Realm().objects(Category.self)  //ピッカーのためにCategoryクラスを引っ張ってくる
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        searchbar.delegate = self  //サーチバー用にデリゲート指定
        searchbar.showsCancelButton = true
        //入力なしでもリターンキーが押せるようにする
        searchbar.enablesReturnKeyAutomatically = false
        
        //ピッカービューのデリゲート指定
        pickerTextView.delegate = self
        pickerTextView.dataSource = self
        
        textField.inputView = pickerTextView  //テキストとピッカーをつなげる
        
        //ツールバーの位置と選択後の閉じる動作
        let texttoolbar = UIToolbar()
        texttoolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endPicker))
        texttoolbar.setItems([doneButton], animated: true)
        textField.inputAccessoryView = texttoolbar
        
    }
    
    //ツールバーを閉じる関数
    @objc func endPicker() {
        textField.endEditing(true)
    }
    
//ピッカービューで検索するパターン（デリゲートメソッドを記述）
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
        textField.text = categoryArray[row].item
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.endEditing(true)
    }
    
    //検索ボタンが押された時の場合分け
    @IBAction func searchButton(_ sender: Any) {
        let searchCategoryText: String = textField.text!
        
        //テキスが空欄のときはタスク全て表示
        if (textField.text! == "") {
            taskArray = realm.objects(Task.self)
            tableView.reloadData()  //タスク表示の更新
        }else {
            
            //テキストに入力があるときは一致するものを検索
            let predicate = NSPredicate(format: "category == %@", "\(searchCategoryText)")
            let results = realm.objects(Task.self).filter(predicate)
            
            //検索件数
            let categorycount = results.count
            //０のとき
            if (categorycount == 0) {
                //全てのタスクを表示
            }else {
                //ヒットしたときは一致するものを表示
                taskArray = results
            }
            tableView.reloadData()  //タスク表示の更新
        }
    }
    
    
//サーチバーに文字列を入力して検索するパターン
    //検索ボタン押したときに呼び出される
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.endEditing(true)
        
        //入力される文字列の値を設定。「nil」が入る可能性も考慮して「！」を付ける
        let searchText: String = searchbar.text!
        
        //テキスト入力時の場合分け
        
        //①検索欄が空欄のとき全てのタスクを表示
        if (searchbar.text! == "") {
            //↓全てのタスク
            taskArray = realm.objects(Task.self)
            //↑左のを簡略化したものtaskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
            tableView.reloadData()  //タスク一覧の再読み込み
            
        }else {
        //②検索欄に文字が入力されていた場合は該当カテゴリのセルを検索
        //条件：検索文字がcategoryと一致するものを検索
        let predicate = NSPredicate(format: "category == %@", "\(searchText)")
        let results = realm.objects(Task.self).filter(predicate)
        
        //検索結果の件数を取得
        let count = results.count
        
            //結果件数に応じた場合分け
            
            //件数が０のとき
        if (count == 0) {
            //全てのタスク表示
           
        }else {
            //上記以外、つまりヒットしたタスクがある場合はそれを表示
            taskArray = results
            
        }
            tableView.reloadData()  //タスク一覧の再読み込み
        }
        
    }
    
    
    //データ（セル）の数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count //←全てのタスク
    }
    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なセルを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //Cellの値を設定するーーここからーー
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        //↓データフォーマッターは、日時の表し方を任意の形で文字列に変換しり機能を持つクラス
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        //ーーここまで追加ーー
        
        return cell
    }
    //各セルを選択したときに実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    //セルの削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return.delete
    }
    //Deleteボタンが押されたときに呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            //ローカル通知をキャンセルする＊remove pending：保留中の削除　という意味
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            //データベースから削除
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests {(requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/--------------")
                    print(request)
                    print("--------------/")
                }
            }
        }
    }

    //segueでタスク一覧からタスク作成・編集画面へ遷移するときに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //inputViewControllerを取得
        let inputViewController:InputViewController = segue.destination as! InputViewController
        //今回は「+」（新規）と「cell」（編集）をタップしたとき２パターンがあるので、
        //場合分けして値を設定していく
        if segue.identifier == "cellSegue" {
            //セルをタップしたとき。この場合は作成済みのタスクなので、配列taskArrayから該当するTaskクラスのインスタンスを取得して
            //inputViewControllerのプロパティに設定していく。
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]  //渡す値
        }else {
            //+をタップしたときは新たなインスタンスを生成して、idを設定する。
            //idはすでに存在しているidのうち最大のものを取得して、+1することにより、他のタスクとの重複を避ける。
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task  //渡す値
        }
    }
    //タスク作成画面から戻ってきたときにTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
}


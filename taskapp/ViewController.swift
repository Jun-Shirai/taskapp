//
//  ViewController.swift
//  taskapp
//
//  Created by 白井淳 on 2021/01/30.
//

import UIKit
import RealmSwift //<-追加。Realmのデータベース準備するため。
import UserNotifications //<-追加する。タスク削除のときに通知キャンセルをするために

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate{
 //↑サーチバー用に機能追加
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    //↑サーチバー接続
        
    //Realmインスタンスを取得する。これを使ってメソッドを呼び出す。
    let realm = try! Realm() //<-追加
    
    //DB内のタスクが格納されるリスト。「Task」はTask.swiftからのもの。
    //日付の近い順でソート：昇順
    //以降内容をアプデするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    //↑追加。これでデータベースの準備ができた。
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        searchbar.delegate = self  //サーチバー用にデリゲート指定
        searchbar.showsCancelButton = true
        //入力なしでもリターンキーが押せるようにする
        searchbar.enablesReturnKeyAutomatically = false
        
        
    }
    
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
        return taskArray.count //←修正
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
        //ーーここから追加ーー
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
        }//ーーここまで追加・変更ーー
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
    //入力（作成・編集）画面から戻ってきたときにTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
}


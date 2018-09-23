//
//  NotificationViewController.swift
//  chat-app
//
//  Created by Yota Nakamura on 2018/09/23.
//  Copyright © 2018年 中村　陽太. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {
    var tableView: UITableView?
    var setting: [String] = ["通知", "ビーコン通知時", "新規メッセージ", "自分へのリプライ"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションバーのテキストを変更
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = "通知"
        // テーブルのインスタンス
        tableView = UITableView()
        // テーブルサイズを画面いっぱいに
        tableView?.frame = view.frame
        // デリゲート
        tableView?.dataSource = self
        // セルをテーブルに紐付ける
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        // データのないセルを表示しないようにする
        tableView?.tableFooterView = UIView(frame: .zero)
        // テーブルを表示
        view.addSubview(tableView!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// データ・ソース
extension NotificationViewController: UITableViewDataSource {
    // データ要素数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setting.count
    }
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    // セル生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = setting[indexPath.row]
//        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = UISwitch()
        return cell
    }
}

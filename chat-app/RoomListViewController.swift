//
//  RoomListViewController.swift
//  chat-app
//
//  Created by Yota Nakamura on 2018/09/19.
//  Copyright © 2018年 中村　陽太. All rights reserved.
//

import UIKit

class RoomListViewController: UIViewController {
    var tableView: UITableView?
    var roomList: [[String]] = [
        ["MIRAI BASE"],
        ["未来大4Fスタジオ"]
    ]
    let roomStatus: [String] = ["参加中のルーム", "圏外のルーム"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "ルーム"
        
        // テーブルのインスタンス
        tableView = UITableView()
        
        if let tableView: UITableView = tableView {
            // テーブルサイズを画面いっぱいに
            tableView.frame = view.frame
            // デリゲート
            tableView.delegate = self
            tableView.dataSource = self
            // セルをテーブルに紐付ける
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            // データのないセルを表示しないようにする
            tableView.tableFooterView = UIView(frame: .zero)
            // テーブルを表示
            view.addSubview(tableView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "toChatViewController") {
//            let chatViewController:ChatViewController = (segue.destination as? ChatViewController)!
//        }
//    }
}

// データ・ソース
extension RoomListViewController: UITableViewDataSource {
    // セクションごとにデータ要素数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomList[section].count
    }
    // セクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        return roomStatus.count
    }
    // セクションヘッダ
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return roomStatus[section]
    }
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    // セル生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = roomList[indexPath.section][indexPath.row]
        cell.accessoryType = .disclosureIndicator
        //cell.accessoryView = UISwitch() // スィッチ
        return cell
    }
}

// セルタップ時の動作定義など
extension RoomListViewController: UITableViewDelegate {
    // セクションヘッダの高さ
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    // セルタップ時の挙動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        let chatViewController: ChatViewController = ChatViewController()
        let displayName: String = roomList[indexPath.section][indexPath.row]
        chatViewController.senderDisplayName = displayName
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
}

//
//  RoomListViewController.swift
//  chat-app
//
//  Created by Yota Nakamura on 2018/09/19.
//  Copyright © 2018年 中村　陽太. All rights reserved.
//

import UIKit
import CoreLocation

class RoomListViewController: UIViewController, CLLocationManagerDelegate {
    var tableView: UITableView?
    var roomList: [[String]] = [
        ["Test User"],
        ["iPhone5", "test"],
        ["MIRAI BASE", "未来大4F"]
    ]
    let roomStatus: [String] = ["ユーザ情報", "参加中のルーム", "圏外のルーム"]
    var myLocationManager: CLLocationManager?
    var myBeaconRegion: CLBeaconRegion?
    var beaconUuids: NSMutableArray?
    var beaconDetails: NSMutableArray?
    let UUIDList: [String] = [
        "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA",
        "12345678-1234-1234-1234-123456789012",
        "48534442-4C45-4144-80C0-1800FFFFFFFF"
    ]
    var isBeaconInside: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションバーの背景色
        self.navigationController?.navigationBar.barTintColor = .purple
        // ナビゲーションバーアイテムの色
        self.navigationController?.navigationBar.tintColor = .white
        // ナビゲーションバーのテキストを変更
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = "チャットルームリスト"
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        // テーブルのインスタンス
        tableView = UITableView()
        // テーブルサイズを画面いっぱいに
        tableView?.frame = view.frame
        // デリゲート
        tableView?.delegate = self
        tableView?.dataSource = self
        // セルをテーブルに紐付ける
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        let nib = UINib(nibName: "UserInfoTableViewCell", bundle: nil)
//        tableView?.register(nib, forCellReuseIdentifier: "UserCell")
        // データのないセルを表示しないようにする
        tableView?.tableFooterView = UIView(frame: .zero)
        // テーブルを表示
        view.addSubview(tableView!)
        
        // ビーコン関連
        myLocationManager = CLLocationManager()
        myLocationManager?.delegate = self
        myLocationManager?.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager?.distanceFilter = 1
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        print("CLAuthorizedStatus: \(status.rawValue)")
        if status == .notDetermined {
            myLocationManager?.requestAlwaysAuthorization()
        }
        beaconUuids = NSMutableArray()
        beaconDetails = NSMutableArray()
    }
    
    private func startMyMonitoring() {
        for i: Int in 0 ..< UUIDList.count {
            let uuid: NSUUID? = NSUUID(uuidString: "\(UUIDList[i].lowercased())")
            let identifierStr: String = "abcde\(i)"
            myBeaconRegion = CLBeaconRegion(proximityUUID: uuid! as UUID, identifier: identifierStr)
            myBeaconRegion?.notifyEntryStateOnDisplay = false
            myBeaconRegion?.notifyOnEntry = true
            myBeaconRegion?.notifyOnExit = true
            myLocationManager?.startMonitoring(for: myBeaconRegion!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus")
        switch status {
        case .notDetermined:
            print("not determined")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorizedAlways:
            print("authorizedAlways")
            startMyMonitoring()
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            startMyMonitoring()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            print("iBeacon inside")
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
        case .outside:
            print("iBeacon outside")
        case .unknown:
            print("iBeacon unknown")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        beaconUuids = NSMutableArray()
        beaconDetails = NSMutableArray()
//        if beacons.count > 0 {
            for i: Int in 0 ..< beacons.count {
                let beacon: CLBeacon = beacons[i]
                let beaconUUID: UUID = beacon.proximityUUID
                let minorID: NSNumber = beacon.minor
                let majorID: NSNumber = beacon.major
                let rssi: Int = beacon.rssi
                var proximity: String = ""
                switch beacon.proximity {
                case CLProximity.unknown :
                    print("Proximity: Unknown")
                    proximity = "Unknown"
                case CLProximity.far:
                    print("Proximity: Far")
                    proximity = "Far"
                case CLProximity.near:
                    print("Proximity: Near")
                    proximity = "Near"
                case CLProximity.immediate:
                    print("Proximity: Immediate")
                    proximity = "Immediate"
                }
                beaconUuids?.add(beaconUUID.uuidString)
                var myBeaconDetails: String = "Major: \(majorID) "
                myBeaconDetails += "Minor: \(minorID) "
                myBeaconDetails += "Proximity:\(proximity) "
                myBeaconDetails += "RSSI:\(rssi)"
                print(myBeaconDetails)
                beaconDetails?.add(myBeaconDetails)
//                label1.text = proximity
                if isBeaconInside == false {
                    isBeaconInside = true
                    setAlert()
                }
            }
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion: iBeacon found")
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion: iBeacon lost")
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
        
        isBeaconInside = false
        setAlert()
    }
    
    func setAlert() {
        switch isBeaconInside {
        case true:
            // アラート
            let alert: UIAlertController = UIAlertController(title: "ルーム名: \("iPhone5")", message: "チャットルームに参加しますか？", preferredStyle: .alert)
            // OKボタンを追加
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        case false:
            // アラート
            let alert: UIAlertController = UIAlertController(title: "ビーコンを検出できません", message: "チャットルームに参加するには、\nビーコンに近づいてください", preferredStyle: .alert)
            // OKボタンを追加
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapSettingButton(_ sender: Any) {
        let settingViewController: SettingViewController = SettingViewController()
        self.navigationController?.pushViewController(settingViewController, animated: true)
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

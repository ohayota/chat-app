//
//  ViewController.swift
//  chat-app
//
//  Created by 中村　陽太 on 2018/09/08.
//  Copyright © 2018年 中村　陽太. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import KRActivityIndicatorView
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    var databaseRef: DatabaseReference?
    // メッセージ内容に関するプロパティ
    var messages: [JSQMessage]?
    // 背景画像に関するプロパティ
    var incomingBubble: JSQMessagesBubbleImage?
    var outgoingBubble: JSQMessagesBubbleImage?
    // アバター画像に関するプロパティ
    var incomingAvatar: JSQMessagesAvatarImage?
    var outgoingAvarar: JSQMessagesAvatarImage?
    // 読み込み中に表示するインジケータ
    var activityIndicator: KRActivityIndicatorView?
    
    func setupFirebase() {
        // DatabaseReferenceのインスタンス化
        databaseRef = Database.database().reference()
        // Realmオブジェクトを作成する
        let realm: Realm = try! Realm()
        // 最新25件のデータをデータベースから取得する
        // 最新のデータが追加されるたびに最新データを取得する
        if let databaseRef: DatabaseReference = databaseRef {
            databaseRef.queryLimited(toLast: 25).observe(DataEventType.childAdded, with: { (snapshot) -> Void in
                self.activityIndicator?.startAnimating()
                let chatMessage: ChatMessage = ChatMessage()
                let snapshotValue: NSDictionary = snapshot.value as! NSDictionary
                let sender: String = snapshotValue["from"] as! String
                let name: String = snapshotValue["name"] as! String
                let text: String = snapshotValue["text"] as! String
                chatMessage.from = sender
                chatMessage.name = name
                chatMessage.text = text
                print(snapshot.value!)
                if name == self.senderDisplayName {
                    let message: JSQMessage? = JSQMessage(senderId: sender, displayName: name, text: text)
                    self.messages?.append(message!)
                }
                // ACIDが保証されているトランザクション
                realm.beginWrite()
                realm.add(chatMessage)
                try! realm.commitWrite()
                self.activityIndicator?.stopAnimating()
                self.finishSendingMessage()
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = senderDisplayName
        // 読み込み中に表示するインジケータのインスタンス
        activityIndicator = KRActivityIndicatorView(style: .color(.purple))
        activityIndicator?.frame = CGRect(x: self.view.bounds.width / 2 - 50, y: self.view.bounds.height / 2 - 50, width: 50, height: 50)
        activityIndicator?.isLarge = true
        activityIndicator?.hidesWhenStopped = true
        view.addSubview(activityIndicator!)
        // クリーンアップツールバーの設定
        inputToolbar!.contentView!.leftBarButtonItem = nil
        // 新しいメッセージを受信するたび下にスクロールする
        automaticallyScrollsToMostRecentMessage = true
        // 自分のsenderIDを設定（ユーザ判定に必要なのでデバイスによって変更する）
        self.senderId = "User1"
        // 表示するチャット画面が複数あるのでコメントアウト
//        self.senderDisplayName = "test"
        // 吹き出しの設定
        let bubbleFactory: JSQMessagesBubbleImageFactory? = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.purple)
        // アバターの設定
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage.swiftLogo, diameter: 64)
        self.outgoingAvarar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage.swiftLogo, diameter: 64)
        // メッセージデータの配列を初期化
        self.messages = []
        setupFirebase()
    }
    
    override func didPressSend(_ button: UIButton?, withMessageText text: String?, senderId: String?, senderDisplayName: String?, date: Date?) {
        // メッセージの送信処理を完了する（画面上にメッセージを表示する）
        self.finishReceivingMessage(animated: true)
        // Firebaseにメッセージを送信、保存する
        let post1: [String: String?] = ["from": senderId, "name": senderDisplayName, "text": text]
        if let databaseRef: DatabaseReference = databaseRef {
            let post1Ref: DatabaseReference = databaseRef.childByAutoId()
            post1Ref.setValue(post1)
        }
        self.finishSendingMessage(animated: true)
    }
    // アイテムごとに参照するメッセージデータを返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData? {
        return messages![indexPath.item]
    }
    // アイテムごとのMessageBubble（背景）を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource? {
        let message: JSQMessage? = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    // アイテムごとにアバター画像を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        let message: JSQMessage? = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingAvarar
        }
        return self.incomingAvatar
    }
    // アイテムの総数を返す
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages!.count
    }
    // メッセージテキストの色変更
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        if messages?[indexPath.row].senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

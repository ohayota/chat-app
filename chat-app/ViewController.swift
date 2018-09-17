//
//  ViewController.swift
//  chat-app
//
//  Created by 中村　陽太 on 2018/09/08.
//  Copyright © 2018年 中村　陽太. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ViewController: JSQMessagesViewController {
    var databaseRef: DatabaseReference!
    
    // メッセージ内容に関するプロパティ
    var messages: [JSQMessage]?
    // 背景画像に関するプロパティ
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    // アバター画像に関するプロパティ
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvarar: JSQMessagesAvatarImage!
    
    func setupFirebase() {
        // DatabaseReferenceのインスタンス化
        databaseRef = Database.database().reference()
        
        // 最新25件のデータをデータベースから取得する
        // 最新のデータが追加されるたびに最新データを取得する
        databaseRef.queryLimited(toLast: 25).observe(DataEventType.childAdded, with: { (snapshot) -> Void in
            let snapshotValue = snapshot.value as! NSDictionary
            let text = snapshotValue["text"] as! String
            let sender = snapshotValue["from"] as! String
            let name = snapshotValue["name"] as! String
            print(snapshot.value!)
            let message = JSQMessage(senderId: sender, displayName: name, text: text)
            self.messages?.append(message!)
            self.finishSendingMessage()
        })
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // クリーンアップツールバーの設定
        inputToolbar!.contentView!.leftBarButtonItem = nil
        // 新しいメッセージを受信するたび下にスクロールする
        automaticallyScrollsToMostRecentMessage = true
        
        // 自分のsenderID, senderDisplayNameを設定
        self.senderId = "user1"
        self.senderDisplayName = "test"
        
        // 吹き出しの設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        
        // アバターの設定
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "Swift-Logo")!, diameter: 64)
        self.outgoingAvarar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "Swift-Logo")!, diameter: 64)
        
        // メッセージデータの配列を初期化
        self.messages = []
        setupFirebase()
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // メッセージの送信処理を完了する（画面上にメッセージを表示する）
        self.finishReceivingMessage(animated: true)
        
        // Firebaseにメッセージを送信、保存する
        let post1 = ["from": senderId, "name": senderDisplayName, "text": text]
        let post1Ref = databaseRef.childByAutoId()
        post1Ref.setValue(post1)
        self.finishSendingMessage(animated: true)
        
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    // アイテムごとに参照するメッセージデータを返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages![indexPath.item]
    }
    
    // アイテムごとのMessageBubble（背景）を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    // アイテムごとにアバター画像を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingAvarar
        }
        return self.incomingAvatar
    }
    
    // アイテムの総数を返す
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages!.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


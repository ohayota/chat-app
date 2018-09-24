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
import MessageKit

class ChatViewController: MessagesViewController {
    var databaseRef: DatabaseReference?
//    // メッセージ内容に関するプロパティ
//    var messages: [JSQMessage]?
//    // 背景画像に関するプロパティ
//    var incomingBubble: JSQMessagesBubbleImage?
//    var outgoingBubble: JSQMessagesBubbleImage?
//    // アバター画像に関するプロパティ
//    var incomingAvatar: JSQMessagesAvatarImage?
//    var outgoingAvarar: JSQMessagesAvatarImage?
    // 読み込み中に表示するインジケータ
    var activityIndicator: KRActivityIndicatorView?
    
    var messageList: [MockMessage] = []
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
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
//                chatMessage.from = sender
//                chatMessage.name = name
//                chatMessage.text = text
                print(snapshot.value!)
                if name == self.navigationController?.navigationItem.title {
//                    let message: JSQMessage? = JSQMessage(senderId: sender, displayName: name, text: text)
//                    self.messages?.append(message!)
                }
                // ACIDが保証されているトランザクション
//                realm.beginWrite()
//                realm.add(chatMessage)
//                try! realm.commitWrite()
//                self.activityIndicator?.stopAnimating()
//                self.finishSendingMessage()
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        self.navigationItem.title = senderDisplayName
        // 読み込み中に表示するインジケータのインスタンス
        activityIndicator = KRActivityIndicatorView(style: .color(.purple))
        activityIndicator?.frame = CGRect(x: self.view.bounds.width / 2 - 50, y: self.view.bounds.height / 2 - 50, width: 50, height: 50)
        activityIndicator?.isLarge = true
        activityIndicator?.hidesWhenStopped = true
        view.addSubview(activityIndicator!)
        // クリーンアップツールバーの設定
//        inputToolbar!.contentView!.leftBarButtonItem = nil
        // 新しいメッセージを受信するたび下にスクロールする
//        automaticallyScrollsToMostRecentMessage = true
        // 自分のsenderIDを設定（ユーザ判定に必要なのでデバイスによって変更する）
//        self.senderId = "User1"
        // 表示するチャット画面が複数あるのでコメントアウト
//        self.senderDisplayName = "test"
        // 吹き出しの設定
//        let bubbleFactory: JSQMessagesBubbleImageFactory? = JSQMessagesBubbleImageFactory()
//        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
//        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.purple)
//        // アバターの設定
//        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage.swiftLogo, diameter: 64)
//        self.outgoingAvarar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage.swiftLogo, diameter: 64)
        // メッセージデータの配列を初期化
//        self.messages = []
        setupFirebase()
        DispatchQueue.main.async {
            // messageListにメッセージの配列を入れて
            self.messageList = self.getMessages()
            // messagesCollectionViewをリロードして
            self.messagesCollectionView.reloadData()
            // 一番下までスクロールする
            self.messagesCollectionView.scrollToBottom()
        }
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor.purple
        
        // メッセージ入力欄の左に画像選択ボタンを追加
        let items = [
            makeButton(named: "clip.png").onTextViewDidChange { button, textView in
                button.tintColor = UIColor.purple
                button.isEnabled = textView.text.isEmpty
            }
        ]
        items.forEach { $0.tintColor = .purple }
        messageInputBar.setStackViewItems(items, forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 45, animated: false)
        // メッセージ入力時に一番下までスクロール
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
    }
    
    // ボタンの作成
    func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: true)
            }.onSelected {
                $0.tintColor = UIColor.gray
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
        }
    }
    
//    override func didPressSend(_ button: UIButton?, withMessageText text: String?, senderId: String?, senderDisplayName: String?, date: Date?) {
//        // メッセージの送信処理を完了する（画面上にメッセージを表示する）
//        self.finishReceivingMessage(animated: true)
//        // Firebaseにメッセージを送信、保存する
//        let post1: [String: String?] = ["from": senderId, "name": senderDisplayName, "text": text]
//        if let databaseRef: DatabaseReference = databaseRef {
//            let post1Ref: DatabaseReference = databaseRef.childByAutoId()
//            post1Ref.setValue(post1)
//        }
//        self.finishSendingMessage(animated: true)
//    }
    // アイテムごとに参照するメッセージデータを返す
//    override func collectionView(_ collectionView: JSQMessagesCollectionView?, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData? {
//        return messages![indexPath.item]
//    }
    // アイテムごとのMessageBubble（背景）を返す
//    override func collectionView(_ collectionView: JSQMessagesCollectionView?, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource? {
//        let message: JSQMessage? = self.messages?[indexPath.item]
//        if message?.senderId == self.senderId {
//            return self.outgoingBubble
//        }
//        return self.incomingBubble
//    }
    // アイテムごとにアバター画像を返す
//    override func collectionView(_ collectionView: JSQMessagesCollectionView?, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
//        let message: JSQMessage? = self.messages?[indexPath.item]
//        if message?.senderId == self.senderId {
//            return self.outgoingAvarar
//        }
//        return self.incomingAvatar
//    }
    // アイテムの総数を返す
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return messages!.count
//    }
    // メッセージテキストの色変更
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell: JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
//        if messages?[indexPath.row].senderId == senderId {
//            cell.textView?.textColor = UIColor.white
//        } else {
//            cell.textView?.textColor = UIColor.black
//        }
//        return cell
//    }
    
    // サンプル用に適当なメッセージ
    func getMessages() -> [MockMessage] {
        return [
            createMessage(text: "あ"),
            createMessage(text: "い"),
            createMessage(text: "う"),
            createMessage(text: "え"),
            createMessage(text: "お"),
            createMessage(text: "か"),
            createMessage(text: "き"),
            createMessage(text: "く"),
            createMessage(text: "け"),
            createMessage(text: "こ"),
            createMessage(text: "さ"),
            createMessage(text: "し"),
            createMessage(text: "すせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん"),
        ]
    }
    
    func createMessage(text: String) -> MockMessage {
        let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
        return MockMessage(attributedText: attributedText, sender: otherSender(), messageId: UUID().uuidString, date: Date())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> Sender {
        return Sender(id: "", displayName: "")
    }
    
    func otherSender() -> Sender {
        return Sender(id: "", displayName: "")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    // メッセージの上に文字を表示（名前）
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    // メッセージの下に文字を表示（日付）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    // メッセージの色を変更（デフォルトは自分：白、相手：黒）
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .darkText : .white
    }
    // メッセージの背景色を変更している（デフォルトは自分：緑、相手：グレー）
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?
            UIColor.purple :
            UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
    }
    // メッセージの枠にしっぽをつける
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    // アイコンをセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // message.sender.displayNameとかで送信者の名前を取得できるので、そこからイニシャル生成
        let avatar = Avatar(initials: "匿")
        avatarView.set(avatar: avatar)
    }
}
// 各ラベルの高さを設定（デフォルト0なので必須）
extension ChatViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 { return 10 }
        return 0
    }
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension ChatViewController: MessageCellDelegate {
    // メッセージをタップした時の挙動
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
}

extension ChatViewController: MessageInputBarDelegate {
    // メッセージ送信ボタンをタップした時の挙動
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let image = component as? UIImage {
                
                let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])
                
            } else if let text = component as? String {
                
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                                                   .foregroundColor: UIColor.white])
                let message = MockMessage(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(message)
                messagesCollectionView.insertSections([messageList.count - 1])
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
}


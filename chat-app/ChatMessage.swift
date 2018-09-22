//
//  ChatMessage.swift
//  chat-app
//
//  Created by Yota Nakamura on 2018/09/22.
//  Copyright © 2018年 中村　陽太. All rights reserved.
//

import RealmSwift

class ChatMessage: Object {
    @objc dynamic var from: String? = ""
    @objc dynamic var name: String? = ""
    @objc dynamic var text: String? = ""
}

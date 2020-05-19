//
//  WebSocketClient.swift
//  SignalingServer
//
//  Created by Sam on 2020/5/11.
//  Copyright © 2020 AP-EC. All rights reserved.
//

//检测到的客户端的对象

import Foundation
import Network

final class WebSocketClient: Hashable, Equatable {//继承哈希协议, 才能放进去set集合
    
    let id: String
    let connection: NWConnection
    
    
    init(connection: NWConnection) {
        self.connection = connection
        //获取随机UUID
        self.id = UUID().uuidString
    }
    
    // MARK:- 判断等价的条件 Equatable协议
    ///Returns a Boolean value indicating whether two values are equal.
    static func == (lhs: WebSocketClient, rhs: WebSocketClient) -> Bool {
        lhs.id == rhs.id
    }
    // MARK:- 提供一个哈希标识
    /// Hashes the essential components of this value by feeding them into the given hasher.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

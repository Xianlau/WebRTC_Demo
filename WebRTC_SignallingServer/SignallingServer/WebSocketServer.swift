//
//  WebSocketServer.swift
//  SignalingServer
//
//  Created by Sam on 2020/5/11.
//  Copyright © 2020 AP-EC. All rights reserved.
//

//本机开启的服务器对象

import Foundation
import Network

final class WebSocketServer {
    
    //global线程
    private let queue = DispatchQueue.global()
    //端口
    private let port: NWEndpoint.Port = 8080
    //网络监听者
    private let listener: NWListener
    //用Set来存放连接进来的客户端对象
    private var connectedClients = Set<WebSocketClient>()
    
    // MARK:- 初始化后台服务
    init() throws {
        let parameters = NWParameters.tcp//TCP连接方式
        let webSocketOptions = NWProtocolWebSocket.Options()//连接属性设置
        webSocketOptions.autoReplyPing = true//自动回复ping包
        parameters.defaultProtocolStack.applicationProtocols.append(webSocketOptions)
        self.listener = try NWListener(using: parameters, on: self.port)//设置连接相关的方式和参数
    }
    
    // MARK:- 开启后台服务
    func start() {
        //设置接收到消息的处理方法
        self.listener.newConnectionHandler = self.newConnectionHandler
        //开启后台服务监听
        self.listener.start(queue: queue)
        print("信令服务器开始监听端口 \(self.port)")
    }
    
    // MARK:- 接收到一个新的client的处理方法
    private func newConnectionHandler(_ connection: NWConnection) {
        let client = WebSocketClient(connection: connection)//新建一个客户端对象
        self.connectedClients.insert(client)//往set里面插入一个客户端对象
        client.connection.start(queue: self.queue)//开始连接这个客户端
        //接收到这个客户端的数据
        client.connection.receiveMessage { [weak self] (data, context, isComplete, error) in
            //数据处理
            self?.didReceiveMessage(from: client, data: data, context: context, error: error)
        }
        print("有一个客户端连进来了， 现在连接的客户端总数: \(self.connectedClients.count)")
    }
    // MARK:- 断开一个client
    private func didDisconnect(client: WebSocketClient) {
        self.connectedClients.remove(client)
        print("有一个客户端断开了， 现在连接的客户端总数: \(self.connectedClients.count)")

    }
    
    // MARK:- 收到来自client的信息 处理数据
    private func didReceiveMessage(from client: WebSocketClient,
                                   data: Data?,
                                   context: NWConnection.ContentContext?,
                                   error: NWError?) {
        
        if let context = context, context.isFinal {//如果是收到终止连接的context信息
            client.connection.cancel()//取消连接
            self.didDisconnect(client: client)//断开连接
            return
        }
        //如果收到data数据, 分发给其他client
        if let data = data {
            let otherClients = self.connectedClients.filter { $0 != client }//能用这个语法是因为实现了equal协议
            //把这个客户端发过来的数据转发给其他client
            self.broadcast(data: data, to: otherClients)
            //打印收到的数据
            if let str = String(data: data, encoding: .utf8) {
                print("------------------------------------ 接收到 数据信息 ------------------------------------")
                print(str + "\n")
            }
        }
        //继续接收消息
        client.connection.receiveMessage { [weak self] (data, context, isComplete, error) in
            self?.didReceiveMessage(from: client, data: data, context: context, error: error)
        }
    }
    // MARK:- 发送数据给其他client
    private func broadcast(data: Data, to clients: Set<WebSocketClient>) {
        clients.forEach {
            let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)//元数据
            let context = NWConnection.ContentContext(identifier: "context", metadata: [metadata])
            //发送数据
            $0.connection.send(content: data,
                               contentContext: context,
                               isComplete: true,
                               completion: .contentProcessed({ _ in }))
        }
    }
}

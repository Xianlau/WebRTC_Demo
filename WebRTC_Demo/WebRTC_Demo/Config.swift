//
//  Config.swift
//  WebRTC_Demo
//
//  Created by Sam on 2020/5/19.
//  Copyright © 2020 Samlau. All rights reserved.
//

import Foundation

//这里设置你的服务器端电脑连接的wifi的ip地址
fileprivate let server_wifi_ip:String = "10.10.60.79"

//连接服务端的URL
fileprivate let defaultSignalingServerUrl = URL(string: "ws://\(server_wifi_ip):8080")!

//谷歌的公共stun服务器
fileprivate let defaultIceServers = ["stun:stun.l.google.com:19302",
                                     "stun:stun1.l.google.com:19302",
                                     "stun:stun2.l.google.com:19302",
                                     "stun:stun3.l.google.com:19302",
                                     "stun:stun4.l.google.com:19302"]

struct Config {
    let signalingServerUrl: URL
    let webRTCIceServers: [String]
    
    static let `default` = Config(signalingServerUrl: defaultSignalingServerUrl, webRTCIceServers: defaultIceServers)
}

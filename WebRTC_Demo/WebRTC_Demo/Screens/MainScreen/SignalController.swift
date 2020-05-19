//
//  SingnalController.swift
//  WebRTC-Demo
//
//  Created by Sam on 2020/5/18.
//  Copyright © 2020 Stas Seldin. All rights reserved.
//

import UIKit
import AVFoundation
import WebRTC

enum SignalItems: NSInteger {
    case socketConnect = 0
    case local_SDP
    case remote_SDP
    case local_Candidate
    case remote_Candidate
    case webrtc_statue
    case mute
    case sperker
    
    case operation//  先连服务器, 然后发送offer, 远程SDP状态改变后, 发送answer, 就能进入视频了.
    
    case sendOffer
    case sendAnswer
    
    case isConnect//
    
    case sendData
    case video
}
enum RTCConnectStatus{
    case unconnected
    case connected
}

class SignalController: UIViewController {

    private let signalClient: SignalingClient
    private let webRTCClient: WebRTCClient
    private lazy var videoViewController = VideoViewController(webRTCClient: self.webRTCClient)
    
    let titles = ["服务器连接状态:", "本地SDP状态:", "远程SDP状态:", "本地Candidate数量:", "远程Candidate数量:", "WebRTC连接状态:", "静音", "扬声器", "点击以下进行连接", "先发送offer", "再发送answer", "点击以下进行通信", "发送文字", "进入视频直播",]
    
    lazy var tableview: UITableView = {
        let tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init()
        tableView.register(SettingItemsTableViewCell.self)
        return tableView
    }()
    //socket连上
    private var signalingConnected: Bool = false{
        didSet{
            updateTableview()
        }
    }
    
    private var rtcStatue:RTCConnectStatus = .unconnected{
        didSet{
            updateTableview()
        }
    }
    
    private var hasLocalSdp: Bool = false{
        didSet{
            updateTableview()
        }
    }
    private var localCandidateCount: Int = 0 {
        didSet {
            updateTableview()
        }
    }
    
    private var hasRemoteSdp: Bool = false {
        didSet {
            updateTableview()
        }
    }
    
    private var remoteCandidateCount: Int = 0 {
        didSet {
            updateTableview()
        }
    }
    
    private var speakerOn: Bool = false
    private var mute: Bool = false
    
    // MARK:- 更新tableview
    private func updateTableview(){
        DispatchQueue.main.async {
            self.tableview.reloadData()
        }
    }
    
    init(signalClient: SignalingClient, webRTCClient: WebRTCClient) {
        
        self.signalClient = signalClient
        self.webRTCClient = webRTCClient
        super.init(nibName: nil, bundle: Bundle.main)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableview)
        
        self.webRTCClient.delegate = self
        self.signalClient.delegate = self
        self.signalClient.connect()
        
        self.navigationItem.title = "WebRTC Demo"
    }
}

extension SignalController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: SettingItemsTableViewCell.self, for: indexPath)
        cell.titleName = titles[indexPath.row]
        let item = SignalItems.init(rawValue: indexPath.row)
        switch item {
        case .socketConnect:
            cell.cellTpye = .rightTitle
            if self.signalingConnected {
                cell.rightText = "✅"
                cell.rightTextColor = .green
            }else{
                cell.rightText = "❌"
                cell.rightTextColor = .orange
            }
        case .local_SDP:
            cell.cellTpye = .rightTitle
            cell.rightText = self.hasLocalSdp ? "✅" : "❌"
            
        case .remote_SDP:
            cell.cellTpye = .rightTitle
            cell.rightText = self.hasRemoteSdp ? "✅" : "❌"
            
        case .local_Candidate:
            cell.cellTpye = .rightTitle
            cell.rightTextColor = .orange
            cell.rightText = "\(self.localCandidateCount)"
            
        case .remote_Candidate:
            cell.cellTpye = .rightTitle
            cell.rightTextColor = .orange
            cell.rightText = "\(self.remoteCandidateCount)"
            
        case .webrtc_statue:
            cell.cellTpye = .rightTitle
            cell.rightText = (self.rtcStatue == .connected) ? "✅" : "❌"
            
        // MARK:- 静音
        case .mute:
            cell.cellTpye = .hasSwitch
            cell.feedbackSwitchBlock = {(isOn) -> Void in
                if isOn {
                    self.webRTCClient.muteAudio()
                }
                else {
                    self.webRTCClient.unmuteAudio()
                }
                self.mute = isOn
            }
            
        case .sendData:
            cell.cellTpye = .rightArrow
            if rtcStatue == .connected {
                cell.titleName = "发信息✅"
            }else{
                cell.titleName = "发信息❌"
            }
            
        case .sperker:
            cell.cellTpye = .hasSwitch
            cell.feedbackSwitchBlock = {(isOn) -> Void in
                if !isOn {
                    self.webRTCClient.speakerOff()
                }
                else {
                    self.webRTCClient.speakerOn()
                }
                self.speakerOn = isOn
            }
            
            
        case .video:
        
            cell.cellTpye = .rightArrow
            if rtcStatue == .connected {
                cell.titleName = "进入视频直播✅"
            }else{
                cell.titleName = "进入视频直播❌"
            }
            
            
        case .sendOffer, .sendAnswer:
            cell.cellTpye = .rightArrow
            
        case .operation , .isConnect:
            cell.cellTpye = .normal
            cell.leftTextColor = .blue

        default:
            cell.cellTpye = .normal
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = SignalItems.init(rawValue: indexPath.row)
        switch item {
        case .sendOffer:
            self.webRTCClient.offer { (sdp) in
                self.hasLocalSdp = true
                self.signalClient.send(sdp: sdp)
            }

        case .sendAnswer:
            self.webRTCClient.answer { (localSdp) in
                self.hasLocalSdp = true
                self.signalClient.send(sdp: localSdp)
            }
        case .video:
            self.present(videoViewController, animated: true, completion: nil)
            
        // MARK:- 发消息
        case .sendData:
            let alert = UIAlertController(title: "发送信息给对方",
                                          message: "通过WebRTC通道发信息给对方",
                                          preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = ""
            }
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "发送", style: .default, handler: { [weak self, unowned alert] _ in
                guard let dataToSend = alert.textFields?.first?.text?.data(using: .utf8) else {
                    return
                }
                self?.webRTCClient.sendData(dataToSend)
            }))
            self.present(alert, animated: true, completion: nil)
            
        default:
            print("")
        }
    }

}

extension SignalController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        self.signalingConnected = true
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        self.signalingConnected = false
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("Received remote sdp")
        self.webRTCClient.set(remoteSdp: sdp) { (error) in
            self.hasRemoteSdp = true
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        print("Received remote candidate")
        self.remoteCandidateCount += 1
        self.webRTCClient.set(remoteCandidate: candidate)
    }
}

extension SignalController: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("discovered local candidate")
        self.localCandidateCount += 1
        self.signalClient.send(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {

        switch state {
        case .connected, .completed:
            self.rtcStatue = .connected
        default:
            self.rtcStatue = .unconnected
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            let alert = UIAlertController(title: "收到对方信息", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}


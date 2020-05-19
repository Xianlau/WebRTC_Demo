//
//  main.swift
//  SignallingServer
//
//  Created by Sam on 2020/5/11.
//  Copyright © 2020 AP-EC. All rights reserved.
//

import Foundation

let server = try WebSocketServer()
server.start()
RunLoop.main.run()

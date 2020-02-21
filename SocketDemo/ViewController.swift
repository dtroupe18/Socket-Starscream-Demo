//
//  ViewController.swift
//  SocketDemo
//
//  Created by Dave Troupe on 2/21/20.
//  Copyright © 2020 High Tree Development. All rights reserved.
//

import UIKit
import Starscream // https://github.com/daltoniam/Starscream
import SnapKit // https://github.com/SnapKit/SnapKit

final class ViewController: UIViewController {
  private var isConnected: Bool = false
  private var setName: Bool = false

  // Lazy so we can assign the delegate to self
  private lazy var socket: WebSocket = {
    var request = URLRequest(url: URL(string: "ws://localhost:1337/")!)
    request.timeoutInterval = 10
    request.setValue("chat", forHTTPHeaderField: "Sec-WebSocket-Protocol")

    let socket = WebSocket(request: request)
    socket.delegate = self
    return socket
  }()

  private let promptLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 1
    label.font = UIFont.boldSystemFont(ofSize: 14)
    label.text = "Choose name:"
    return label
  }()

  private let textView: UITextView = {
    let textView = UITextView()
    textView.isEditable = false
    textView.isSelectable = false
    textView.backgroundColor = UIColor.lightGray
    return textView
  }()

  private lazy var textField: UITextField = {
    let textField = UITextField()
    textField.layer.cornerRadius = 8
    textField.layer.borderColor = UIColor.black.cgColor
    textField.layer.borderWidth = 1.0
    textField.delegate = self
    textField.returnKeyType = .done
    return textField
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.setupViews()
    self.socket.connect()
  }

  deinit {
    self.socket.disconnect()
    self.socket.delegate = nil
  }

  private func setupViews() {
    view.addSubview(self.textView)
    self.textView.snp.makeConstraints({ make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
      make.left.equalTo(view).offset(16)
      make.right.equalTo(view).offset(-16)
      make.height.equalTo(250)
    })

    view.addSubview(self.promptLabel)
    self.promptLabel.snp.makeConstraints({ make in
      make.left.equalTo(self.textView)
      make.top.equalTo(self.textView.snp.bottom).offset(8)
      make.width.equalTo(100)
      make.height.equalTo(40)
    })

    view.addSubview(self.textField)
    self.textField.snp.makeConstraints({ make in
      make.left.equalTo(self.promptLabel.snp.right).offset(8)
      make.top.bottom.equalTo(self.promptLabel)
      make.right.equalTo(self.textView)
    })
  }
}

extension ViewController: WebSocketDelegate {
  /* This is the only delegate method. You can also use a closure like this
        socket.onEvent = { event in
          switch event {
          }
        }
   */
  func didReceive(event: WebSocketEvent, client: WebSocket) {
    switch event {
    case .connected(let headers):
      self.isConnected = true
      print("websocket is connected: \(headers)")
    case .disconnected(let reason, let code):
      self.isConnected = false
      print("websocket is disconnected: \(reason) with code: \(code)")
    case .text(let string):
      print("Received text: \(string)")
      self.handleTextReceived(string)
    case .binary(let data):
      print("Received data: \(data.count)")
    case .ping(_):
      break
    case .pong(_):
      break
    case .viablityChanged(_):
      break
    case .reconnectSuggested(_):
      break
    case .cancelled:
      isConnected = false
    case .error(let error):
      isConnected = false
      print("Received error: \(error?.localizedDescription ?? "")")
    }
  }

  private func sendSocketMessage(_ msg: String) {
    self.socket.write(string: msg, completion: {
      print("Finished sending msg: \(msg)")
    })
  }

  // Get the nested JSON data from the string sent to the socket
  private func handleTextReceived(_ text: String) {
    guard let data = text.data(using: .utf16),
      let jsonData = try? JSONSerialization.jsonObject(with: data),
      let jsonDict = jsonData as? [String: Any],
      let messageType = jsonDict["type"] as? String else {
        return
    }

    if messageType == "message",
      let messageData = jsonDict["data"] as? [String: Any],
      let messageAuthor = messageData["author"] as? String,
      let messageText = messageData["text"] as? String {

      displayNewMessage(msg: messageText, author: messageAuthor)
    }
  }

  // Update textView text
  private func displayNewMessage(msg: String, author: String) {
    let existingText = self.textView.text ?? ""
    let newText = "\(author): \(msg)\n" + existingText

    self.textView.text = newText
  }
}

extension ViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard let txt = textField.text else { return false }
    self.textField.resignFirstResponder()

    let trimmed = txt.trimmingCharacters(in: .whitespacesAndNewlines)
    if !trimmed.isEmpty {
      if !setName { setName = true }
      self.sendSocketMessage(trimmed)
    }

    // Clear text
    self.textField.text = nil
    return true
  }
}

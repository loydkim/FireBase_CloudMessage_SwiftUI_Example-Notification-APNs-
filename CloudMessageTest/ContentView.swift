//
//  ContentView.swift
//  CloudMessageTest
//
//  Created by YOUNGSIC KIM on 2020-01-01.
//  Copyright © 2020 YOUNGSIC KIM. All rights reserved.
//

import SwiftUI
import Firebase

// Please change it your physical phone device FCM Token
// To get it, touch the handleLogTokenTouch button and see log
let ReceiverFCMToken = "Physical_Phone_Receiver_FCMToken_String"

// Please change it your Firebase Legacy server key
// Firebase -> Project settings -> Cloud messaging -> Legacy server key
let legacyServerKey = "Your_Firebase_Legacy_Server_Key_String"

struct ContentView: View {
    @State private var fcmTokenMessage = "fcmTokenMessage"
    @State private var instanceIDTokenMessage = "instanceIDTokenMessage"
    
    @State private var notificationTitle: String = ""
    @State private var notificationContent: String = ""
    var body: some View {
        VStack {
            Text(fcmTokenMessage).padding(20)
            Text(instanceIDTokenMessage).padding(20)
            Button(action: {self.handleLogTokenTouch()}) {
                Text("Get user FCM Token String").font(.title)
            }.padding(20)
            TextField("Add Notification Title", text: $notificationTitle).textFieldStyle(RoundedBorderTextFieldStyle()).padding(20)
            TextField("Add Notification Content", text: $notificationContent).textFieldStyle(RoundedBorderTextFieldStyle()).padding(20)
            Button(action: {self.sendMessageTouser(to: ReceiverFCMToken, title: self.notificationTitle, body: self.notificationContent)
                self.notificationTitle = ""
                self.notificationContent = ""
            }) {
                Text("Send message to User").font(.title)
            }.padding(20)
        }
    }
    
    func sendMessageTouser(to token: String, title: String, body: String) {
        print("sendMessageTouser()")
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(legacyServerKey)", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    func handleLogTokenTouch() {
        // [START log_fcm_reg_token]
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        // [END log_fcm_reg_token]
        self.fcmTokenMessage  = "Logged FCM token: \(token ?? "")"

        // [START log_iid_reg_token]
        InstanceID.instanceID().instanceID { (result, error) in
          if let error = error {
            print("Error fetching remote instance ID: \(error)")
          } else if let result = result {
            print("Remote instance ID token: \(result.token)")
            self.instanceIDTokenMessage  = "Remote InstanceID token: \(result.token)"
          }
        }
        // [END log_iid_reg_token]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

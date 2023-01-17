//
//  NotificationSettingHostingViewController.swift
//  柚希胎动计数器
//
//  Created by 王哲夫 on 2023/1/17.
//

import UIKit
import SwiftUI

struct NotificationSettingView: View {
    @State var data: [NotificationDataModel] = GlobalSettings.notificationDates
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                ForEach(0..<data.count, id: \.self) { i in
                    HStack {
                        DatePicker("Alarm \(i + 1)", selection: $data[i].date_d, displayedComponents: .hourAndMinute)
                        Toggle("", isOn: $data[i].isEnable).frame(width: 60, alignment: .trailing)
                    }
                    .padding(EdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0))
                    .onChange(of: data[i].date, perform: updateNotifi(_:))
                    .onChange(of: data[i].isEnable, perform: updateNotifi(_:))
                }
            }
        }
    }
    private func updateNotifi(_ _: Any) {
        GlobalSettings.notificationDates = data
        LocalNotificationManager.shared.notificationSettingChanged { isSuccess in
            if !isSuccess {
                let all = GlobalSettings.notificationDates
                all.forEach {
                    $0.isEnable = false
                }
                GlobalSettings.notificationDates = all
                data = GlobalSettings.notificationDates
            }
        }
    }
}

class NotificationSettingHostViewController: UIHostingController<NotificationSettingView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: NotificationSettingView())
    }
    @IBAction func doneTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}

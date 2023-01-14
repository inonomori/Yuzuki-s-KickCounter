//
//  HistoryViewController.swift
//  柚希动动计数器
//
//  Created by 王哲夫 on 2023/1/14.
//

import UIKit

class HistoryViewController: UIViewController {
    @IBOutlet weak var tableview: UITableView!
    private let format: DateFormatter = {
        let formate = DateFormatter()
        formate.setLocalizedDateFormatFromTemplate("yyyy-MM-dd, HH:mm")
        formate.timeZone = TimeZone.current
        formate.locale = Locale.current
        return formate
    }()
    fileprivate lazy var data: [DataModel] = {
        GlobalSettings.data.reversed()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        let dataModel = data[indexPath.row]
        var config = cell.defaultContentConfiguration()
        let dateString = format.string(from: dataModel.dateStart)
        config.text = "\(dateString)"
        config.secondaryText = "\(dataModel.count)"
        cell.contentConfiguration = config
        return cell
    }
    
    
}

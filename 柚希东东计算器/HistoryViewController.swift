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
        formate.setLocalizedDateFormatFromTemplate("HH:mm")
        formate.timeZone = TimeZone.current
        formate.locale = Locale.current
        return formate
    }()
    private let format2: DateFormatter = {
        let formate = DateFormatter()
        formate.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
        formate.timeZone = TimeZone.current
        formate.locale = Locale.current
        return formate
    }()
    fileprivate var data: [[DataModel]]?
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
    }
    private func reloadData() {
        var section: [[DataModel]] = []
        let allData: [DataModel] = GlobalSettings.data.reversed()
        var lastSec: [DataModel]?
        var lastDate: Date?
        for d in allData {
            if lastDate == nil {
                lastSec = [d]
                lastDate = d.dateStart
                continue
            } else if Calendar.current.isDate(d.dateStart, inSameDayAs: lastDate!) {
                lastSec?.append(d)
            } else {
                if let lastSec, lastSec.count > 0 {
                    section.append(lastSec)
                }
                lastSec = [d]
                lastDate = d.dateStart
            }
        }
        if let lastSec, lastSec.count > 0 {
            section.append(lastSec)
        }
        data = section
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEnd", let vc: EndViewController = segue.destination as? EndViewController, let data: DataModel = sender as? DataModel {
            vc.data = data
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPathForSelectedRow = tableview.indexPathForSelectedRow {
            tableview.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        data?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data?[section].count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        let dataModel = data[indexPath.section][indexPath.row]
        var config = cell.defaultContentConfiguration()
        let dateString = format.string(from: dataModel.dateStart)
        config.text = "\(dateString)"
        config.secondaryText = "\(dataModel.count)"
        cell.contentConfiguration = config
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data else {
            return
        }
        let dataModel = data[indexPath.section][indexPath.row]
        performSegue(withIdentifier: "goToEnd", sender: dataModel)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let data, let data = data[section].first else {
            return nil
        }
        return format2.string(from: data.dateStart)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let data else {
            return
        }
        if (editingStyle == .delete) {
            let section = data[indexPath.section]
            let sectionNeedToBeDelete: Bool = section.count == 1
            let dataToDelete = section[indexPath.row]
            let formate = DateFormatter()
            formate.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm")
            formate.timeZone = TimeZone.current
            formate.locale = Locale.current

            let alc = UIAlertController(title: "Are you sure?", message: "Record in \(formate.string(from: dataToDelete.dateStart)) will be deleted", preferredStyle: .actionSheet)
            alc.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alc.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                var allData = GlobalSettings.data
                allData.removeAll {
                    $0.dateStart == dataToDelete.dateStart
                }
                GlobalSettings.data = allData
                tableView.beginUpdates()
                if sectionNeedToBeDelete {
                    tableView.deleteSections([indexPath.section], with: .automatic)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                self?.reloadData()
                tableView.endUpdates()
            })
            present(alc, animated: true)
        }
    }
}

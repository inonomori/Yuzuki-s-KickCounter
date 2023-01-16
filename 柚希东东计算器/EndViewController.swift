//
//  EndViewController.swift
//  柚希动动计数器
//
//  Created by 王哲夫 on 2023/1/14.
//

import UIKit
import SwiftUI

class EndViewController: UIViewController {
    var data: DataModel?
    @IBOutlet weak var labelResult: UILabel!
    @IBOutlet weak var labelTap: UILabel!
    @IBOutlet weak var labelPredictedCount: UILabel!
    @IBOutlet weak var labelPredictedCountTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        labelResult.text = "\(data?.count ?? 0)"
        labelTap.text = "Total Tap: \(data?.rawRecords.count ?? 0)"
        if let dateToday = data?.dateStart {
            let recordsInToday: [DataModel] = GlobalSettings.data[dateToday.toYYYYMMDD] ?? []
            let totalCount: Float = Float(recordsInToday.reduce(0) { partialResult, dataModel in
                return partialResult + dataModel.count
            })
            let pedicted: Int = Int((totalCount / Float(recordsInToday.count)) * 12.0)
            labelPredictedCount.text = "\(pedicted)"
            let formate = DateFormatter()
            formate.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
            formate.timeZone = TimeZone.current
            formate.locale = Locale.current
            labelPredictedCountTitle.text = "Predicted Daily Count (\(formate.string(from: dateToday)))"
        }
    }
    @IBSegueAction func toChart(_ coder: NSCoder) -> UIViewController? {
        guard let data else {
            return nil
        }
        return BarChartHostingViewController(coder: coder, data: data)
    }
}

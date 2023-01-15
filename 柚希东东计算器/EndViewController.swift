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
    override func viewDidLoad() {
        super.viewDidLoad()
        labelResult.text = "\(data?.count ?? 0)"
        labelTap.text = "Total Tap: \(data?.rawRecords.count ?? 0)"
        if let dateToday = data?.dateStart {
            let datas: [DataModel] = GlobalSettings.data
            let recordsInToday: [DataModel] = datas.filter {
                Calendar.current.isDate($0.dateStart, inSameDayAs: dateToday)
            }
            let totalCount: Float = Float(recordsInToday.reduce(0) { partialResult, dataModel in
                return partialResult + dataModel.count
            })
            let pedicted: Int = Int((totalCount / Float(recordsInToday.count)) * 12.0)
            labelPredictedCount.text = "\(pedicted)"
        }
    }
    @IBSegueAction func toChart(_ coder: NSCoder) -> UIViewController? {
        guard let data else {
            return nil
        }
        return BarChartHostingViewController(coder: coder, data: data)
    }
}

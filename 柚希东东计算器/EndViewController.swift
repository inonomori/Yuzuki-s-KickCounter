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
    @IBOutlet weak var labelPredictedCount: UILabel!
    @IBOutlet weak var labelPredictedCountTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        labelResult.text = "\(data?.count ?? 0)"
        if let dateToday = data?.dateStart {
            let recordsInToday: [DataModel] = GlobalSettings.data[dateToday.toYYYYMMDD] ?? []
            labelPredictedCount.text = "\(recordsInToday.predictedDailyCount)"
            labelPredictedCountTitle.text = "Predicted Daily Count (\(dateToday.toYYYYMMDD))"
        }
    }
    @IBSegueAction func toChart(_ coder: NSCoder) -> UIViewController? {
        guard let data else {
            return nil
        }
        return BarChartHostingViewController(coder: coder, data: data)
    }
}

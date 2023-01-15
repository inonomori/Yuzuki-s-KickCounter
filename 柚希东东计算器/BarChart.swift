//
//  BarChart.swift
//  柚希动动计数器
//
//  Created by 王哲夫 on 2023/1/15.
//

import SwiftUI
import Charts

struct BarChart: View {
    var data: [Int]
    var body: some View {
        Chart {
            BarMark(
                x: .value("Time", "5"),
                y: .value("Tap", data[0])
            )
            BarMark(
                x: .value("Time", "10"),
                y: .value("Tap", data[1])
            )
            BarMark(
                x: .value("Time", "15"),
                y: .value("Tap", data[2])
            )
            BarMark(
                x: .value("Time", "20"),
                y: .value("Tap", data[3])
            )
            BarMark(
                x: .value("Time", "25"),
                y: .value("Tap", data[4])
            )
            BarMark(
                x: .value("Time", "30"),
                y: .value("Tap", data[5])
            )
            BarMark(
                x: .value("Time", "35"),
                y: .value("Tap", data[6])
            )
            BarMark(
                x: .value("Time", "40"),
                y: .value("Tap", data[7])
            )
            BarMark(
                x: .value("Time", "45"),
                y: .value("Tap", data[8])
            )
            BarMark(
                x: .value("Time", "50"),
                y: .value("Tap", data[9])
            )
            BarMark(
                x: .value("Time", "55"),
                y: .value("Tap", data[10])
            )
            BarMark(
                x: .value("Time", "60"),
                y: .value("Tap", data[11])
            )
        }
    }
}

class BarChartHostingViewController: UIHostingController<BarChart> {
    init?(coder aDecoder: NSCoder, data: DataModel) {
        let startTime = data.dateStart.timeIntervalSince1970
        var dataCount: [Int] = Array(repeating: 0, count: 12)
        for i in data.rawRecords {
            let index = Int((i - startTime) / (5.0 * 60.0))
            dataCount[index] = dataCount[index] + 1
        }
        super.init(coder: aDecoder, rootView: BarChart(data: dataCount))
    }
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



//
//  BarChart.swift
//  柚希动动计数器
//
//  Created by 王哲夫 on 2023/1/15.
//

import SwiftUI
import Charts

struct BarMarkModel: Identifiable {
    var xName: String
    var value: Int
    var id = UUID()
}

struct BarChartContainer: View {
    @State var data: [BarMarkModel]
    var body: some View {
        BarChart(data: $data)
    }
}

struct BarChart: View {
    @Binding var data: [BarMarkModel]
    var body: some View {
        Chart {
            ForEach(data) { datum in
                BarMark(
                    x: .value("Time", datum.xName),
                    y: .value("Tap", datum.value)
                )
            }
        }
    }
}

class BarChartHostingViewController: UIHostingController<BarChartContainer> {
    init?(coder aDecoder: NSCoder, data: DataModel) {
        let startTime = data.dateStart.timeIntervalSince1970
        var dataCount: [BarMarkModel] = []
        for i in 0..<12 {
            dataCount += BarMarkModel(xName: "\((i + 1) * 5)", value: 0)
        }
        for i in data.rawRecords {
            let index = Int((i - startTime) / (5.0 * 60.0))
            dataCount[index].value += 1
        }
        super.init(coder: aDecoder, rootView: BarChartContainer(data: dataCount))
    }
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



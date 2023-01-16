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

struct BarChart: View {
    @State private var isOnAppeared: Bool = false
    var data: DataModel
    var barMarkData: [BarMarkModel] {
        let startTime = data.dateStart.timeIntervalSince1970
        var dataCount: [BarMarkModel] = []
        for i in 0..<12 {
            dataCount += BarMarkModel(xName: "\((i + 1) * 5)", value: 0)
        }
        for i in data.rawRecords {
            let index = Int((i - startTime) / (5.0 * 60.0))
            dataCount[index].value += 1
        }
        return dataCount
    }
    var body: some View {
        VStack(alignment: .trailing) {
            Text("Total Tap: \(data.rawRecords.count)")
            Chart(barMarkData) {
                BarMark(
                    x: .value("Time", $0.xName),
                    y: .value("Tap", $0.value)
                )
            }.background {
                Text("No Data")
                    .font(.title)
                    .foregroundColor(Color(.systemGray))
                    .opacity(barMarkData.first{ $0.value > 0 } == nil ? 1.0 : 0.0)
            }
        }
        .padding()
        .opacity(isOnAppeared ? 1.0 : 0.0)
        .onAppear {
            withAnimation(Animation.easeInOut.delay(0.5)) {
                isOnAppeared = true
            }
        }
    }
}

class BarChartHostingViewController: UIHostingController<BarChart> {
    init?(coder aDecoder: NSCoder, data: DataModel) {
        super.init(coder: aDecoder, rootView: BarChart(data: data))
    }
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



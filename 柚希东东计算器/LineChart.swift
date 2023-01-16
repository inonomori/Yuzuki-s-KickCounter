//
//  LineChart.swift
//  柚希动动计数器
//
//  Created by 王哲夫 on 2023/1/15.
//

import SwiftUI
import Charts

struct LineMarkModel: Identifiable {
    var date: Date
    var value: Int
    var id = UUID()
    init(dayBefore: Int) {
        let calendar = Calendar.current
        date = calendar.date(byAdding: DateComponents(day: -dayBefore), to: Date()) ?? Date()
        let allD:[DataModel] = GlobalSettings.data[date.toYYYYMMDD] ?? []
        value = allD.predictedDailyCount
    }
}

struct Dot: View {
    var value: Int
    var body: some View {
        Text("\(value)")
            .font(.system(size: 8))
            .frame(width: 20, height: 20, alignment: .center)
            .foregroundColor(.blue)
            .background(
                Circle()
                .fill(.white)
                .shadow(radius: 2)

            )
//        Circle()
//            .fill(.white)
//            .frame(width: 10)
//            .shadow(radius: 2)
    }
}

struct LineChart: View {
    @State var dayBefore: Int = 7
    var strideCount: Int {
        var ret: Int = 3
        if dayBefore < 15 {
            ret = 1
        } else if dayBefore < 30 {
            ret = 2
        }
        return ret
    }
    let curGradient = LinearGradient(
        gradient: Gradient (
            colors: [
                Color(.blue).opacity(0.1),
                Color(.blue).opacity(0.0)
            ]
        ),
        startPoint: .top,
        endPoint: .bottom
    )
    func generate(_ dayBefore: Int) -> [LineMarkModel] {
        var ret: [LineMarkModel] = []
        for i in 0..<dayBefore {
            ret += LineMarkModel(dayBefore: i)
        }
        return ret
    }
    var body: some View {
        VStack {
            Picker("select period", selection: $dayBefore) {
                Text("7d").tag(7)
                Text("15d").tag(15)
                Text("30d").tag(30)
            }.pickerStyle(.segmented).padding()
            Spacer(minLength: 40)
            Chart(generate(dayBefore)) { d in
                AreaMark(
                    x: .value("date", d.date),
                    y: .value("count", d.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(curGradient)
                
                LineMark(
                    x: .value("date", d.date),
                    y: .value("count", d.value)
                )
                .interpolationMethod(.catmullRom)
                .symbol {
                    if strideCount < 3 {
                        Dot(value: d.value)
                    }
                }
            }.chartXAxis {
                AxisMarks(position: .bottom, values: .stride(by: .day, count: strideCount)) { value in
                    AxisValueLabel() {
                        Text(value.as(Date.self)?.toMMDD ?? "")
                    }
                }
            }
        }
    }
}

class LineChartHostingViewController: UIHostingController<LineChart> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: LineChart())
    }
}



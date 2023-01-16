//
//  ViewController.swift
//  柚希东东计算器
//
//  Created by 王哲夫 on 2023/1/13.
//

import UIKit

class ViewController: UIViewController {
    enum State: Int {
        case idle
        case counting
    }
    private static let period: TimeInterval = 60 * 60
    private static let countIgnoreDuration: TimeInterval = 5 * 60
//    private static let period: TimeInterval = 4
//    private static let countIgnoreDuration: TimeInterval = 1

    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelTapped: UILabel!
    @IBOutlet weak var labelCount: UILabel!
    @IBOutlet weak var viewStart: UIView!
    @IBOutlet weak var labelStart: UILabel!
    @IBOutlet weak var buttonHistory: UIButton!
    private var dataModel: DataModel? {
        didSet {
            updateUI()
        }
    }
    private var state: State = .idle {
        didSet {
            guard state != oldValue else {
                return
            }
            if state == .counting {
                startCounting()
            } else {
                endCounting()
            }
        }
    }
    private var dateLastRecord: Date?
    private var timer: Timer?
    private lazy var haptic: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private lazy var hapticHeavy: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

    override func viewDidLoad() {
        super.viewDidLoad()
        fixData()
        haptic.prepare()
        hapticHeavy.prepare()
        update()
    }
    private func startCounting() {
        UIApplication.shared.isIdleTimerDisabled = true
        buttonHistory.isEnabled = false
        labelStart.text = "Tap"
        UIView.animate(withDuration: 0.2) {
            self.viewStart.backgroundColor = .systemPink
        }
        dataModel = DataModel()
        startTimer()
        update()
    }
    private func endCounting() {
        UIApplication.shared.isIdleTimerDisabled = false
        buttonHistory.isEnabled = true
        labelStart.text = "Start"
        labelTime.text = ""
        UIView.animate(withDuration: 0.2) {
            self.viewStart.backgroundColor = .systemTeal
        }
        dateLastRecord = nil
        timer?.invalidate()
        timer = nil
        dataModel?.save()
        performSegue(withIdentifier: "goToEnd", sender: nil)
    }
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        if state == .idle {
            state = .counting
        } else {
            dataModel?.addRecord()
            increaseCountIfNeeded()
            updateUI()
        }
    }
    private func startTimer() {
        timer?.invalidate()
        timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.update()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    private func update() {
        if state == .counting, let dataModel {
            let delta: TimeInterval = Date().timeIntervalSince1970 - dataModel.dateStart.timeIntervalSince1970
            let countDown: Int = Int(Self.period - delta)
            if countDown > 0 {
                let min: Int = countDown / 60
                let sec: Int = countDown % 60
                labelTime.text = "\(String(format: "%02d", min)) : \(String(format: "%02d", sec))"
            } else {
                state = .idle
            }
        } else {
            labelTime.text = ""
        }
    }
    private func updateUI() {
        labelTapped.text = "\(dataModel?.tap ?? 0)"
        labelCount.text = "\(dataModel?.count ?? 0)"
    }
    private func increaseCountIfNeeded() {
        if dateLastRecord == nil || Date().timeIntervalSince1970 - dateLastRecord!.timeIntervalSince1970 > Self.countIgnoreDuration {
            dateLastRecord = Date()
            dataModel?.increaseCount()
            hapticHeavy.impactOccurred()
        } else {
            haptic.impactOccurred()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEnd", let vc: EndViewController = segue.destination as? EndViewController {
            vc.data = dataModel
        }
    }
    private func fixData() {
        let allData: [DataModel] = GlobalSettings.oldData
        guard allData.count > 0 else {
            return
        }
        var newData:[String:[DataModel]] = GlobalSettings.data
        for data in allData {
            var c = newData[data.dateStart.toYYYYMMDD] ?? []
            c += data
            newData[data.dateStart.toYYYYMMDD] = c
        }
        GlobalSettings.data = newData
        GlobalSettings.oldData = []
    }
}


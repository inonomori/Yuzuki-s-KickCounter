//
//  ViewController.swift
//  柚希东东计算器
//
//  Created by 王哲夫 on 2023/1/13.
//

import UIKit

class ViewController: UIViewController {
    enum State: Equatable {
        case idle(Bool)
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
    @IBOutlet weak var buttonHistory: UIBarButtonItem!
    @IBOutlet weak var buttonStop: UIButton!
    private var alc: UIAlertController?
    private var dataModel: DataModel? {
        didSet {
            updateUI()
        }
    }
    private var state: State = .idle(false) {
        didSet {
            guard state != oldValue else {
                return
            }
            switch state {
            case .counting:
                startCounting()
            case .idle(let needSave):
                endCounting(needSave)
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
            self.viewStart.backgroundColor = .systemGreen
            self.buttonStop.alpha = 1.0
        }
        dataModel = DataModel()
        startTimer()
        update()
    }
    private func endCounting(_ needSave: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
        buttonHistory.isEnabled = true
        labelStart.text = "Start"
        labelTime.text = " "
        UIView.animate(withDuration: 0.2) {
            self.viewStart.backgroundColor = .systemTeal
            self.buttonStop.alpha = 0
        }
        dateLastRecord = nil
        timer?.invalidate()
        timer = nil
        if needSave {
            dataModel?.save()
            alc?.dismiss(animated: true)
            performSegue(withIdentifier: "goToEnd", sender: nil)
        }
        dataModel = nil
    }
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        switch state {
        case .idle(_):
            state = .counting
        default:
            dataModel?.addRecord()
            increaseCountIfNeeded()
            updateUI()
        }
    }
    @IBAction func stopTapped(_ sender: UIButton) {
        alc = UIAlertController(title: "Stop", message: "Do you want to save this measurement?", preferredStyle: .actionSheet)
        alc?.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alc?.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            self?.state = .idle(true)
        })
        alc?.addAction(UIAlertAction(title: "Discard", style: .destructive) { [weak self] _ in
            self?.alc?.dismiss(animated: true) { [weak self] in
                self?.alc = UIAlertController(title: "Discard", message: "Are you sure?", preferredStyle: .alert)
                self?.alc?.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self?.alc?.addAction(UIAlertAction(title: "Discard", style: .destructive) { [weak self] _ in
                    self?.state = .idle(false)
                })
                if let alc = self?.alc {
                    self?.present(alc, animated: true)
                }
            }
        })
        if let alc {
            present(alc, animated: true)
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
        updateUI()
        if state == .counting, let dataModel {
            let delta: TimeInterval = Date().timeIntervalSince1970 - dataModel.dateStart.timeIntervalSince1970
            let countDown: Int = Int(Self.period - delta)
            if countDown <= 0 {
                state = .idle(true)
            }
        }
    }
    private func updateUI() {
        labelTapped.text = "\(dataModel?.tap ?? 0)"
        labelCount.text = "\(dataModel?.count ?? 0)"
        labelTime.text = " "
        if state == .counting, let dataModel {
            let delta: TimeInterval = Date().timeIntervalSince1970 - dataModel.dateStart.timeIntervalSince1970
            let countDown: Int = Int(Self.period - delta)
            if countDown > 0 {
                let min: Int = countDown / 60
                let sec: Int = countDown % 60
                labelTime.text = "\(String(format: "%02d", min)) : \(String(format: "%02d", sec))"
            }
        }
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
        // remove no data section
        var newData:[String:[DataModel]] = GlobalSettings.data
        let allKeys = newData.keys
        var needReset: Bool = false
        for k in allKeys {
            if let v = newData[k], v.count == 0 {
                newData[k] = nil
                needReset = true
            }
        }
        if needReset {
            GlobalSettings.data = newData
        }
        //migrate old data to new data if necessary
        let allData: [DataModel] = GlobalSettings.oldData
        guard allData.count > 0 else {
            return
        }
        newData = GlobalSettings.data
        for data in allData {
            var c = newData[data.dateStart.toYYYYMMDD] ?? []
            c += data
            newData[data.dateStart.toYYYYMMDD] = c
        }
        GlobalSettings.data = newData
        GlobalSettings.oldData = []
    }
}


//
//  EndViewController.swift
//  柚希动动计数器
//
//  Created by 王哲夫 on 2023/1/14.
//

import UIKit

class EndViewController: UIViewController {
    var result: Int?
    @IBOutlet weak var labelResult: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        labelResult.text = "\(result ?? 0)"
    }
}

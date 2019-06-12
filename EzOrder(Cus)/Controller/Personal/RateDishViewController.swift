//
//  RateDishViewController.swift
//  EzOrder(Cus)
//
//  Created by Lee Chien Kuan on 2019/6/12.
//  Copyright © 2019 TerryLee. All rights reserved.
//

import UIKit

class RateDishViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var dishNameLabel: UILabel!
    @IBOutlet weak var rateSlider: RateSlider!
    @IBOutlet weak var rateImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    
    var dishName: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.delegate = self
        rateSlider.parentVC = self
        
        commentTextView.layer.borderWidth = 0.5
        commentTextView.layer.borderColor = UIColor.gray.cgColor
        
        let layer = CAShapeLayer()
        layer.frame = .zero
        rateSlider.layer.mask = layer
        
        dishNameLabel.text = dishName
        
        commentTextView.text = "添加些評論吧(選填)"
        commentTextView.textColor = UIColor.lightGray
        // Do any additional setup after loading the view.
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "添加些評論吧(選填)"
            textView.textColor = UIColor.lightGray
        }
    }
    func updateStar(value: Float) {
        let rate = value
        if rate < 2.75 {
            if rate < 0.25 {
                rateImageView.image = UIImage(named: "rate0")
            } else if rate < 0.75 {
                rateImageView.image = UIImage(named: "rate05")
            } else if rate < 1.25 {
                rateImageView.image = UIImage(named: "rate1")
            } else if rate < 1.75 {
                rateImageView.image = UIImage(named: "rate15")
            } else if rate < 2.25 {
                rateImageView.image = UIImage(named: "rate2")
            } else {
                rateImageView.image = UIImage(named: "rate25")
            }
        } else {
            if rate < 3.25 {
                rateImageView.image = UIImage(named: "rate3")
            } else if rate < 3.75 {
                rateImageView.image = UIImage(named: "rate35")
            } else if rate < 4.25 {
                rateImageView.image = UIImage(named: "rate4")
            } else if rate < 4.75 {
                rateImageView.image = UIImage(named: "rate45")
            } else {
                rateImageView.image = UIImage(named: "rate5")
            }
        }
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickSubmit(_ sender: Any) {
        var rate = 0.0
        let sliderValue = rateSlider.value
        if sliderValue < 2.75 {
            if sliderValue < 0.25 {
                rate = 0
            } else if sliderValue < 0.75 {
                rate = 0.5
            } else if sliderValue < 1.25 {
                rate = 1
            } else if sliderValue < 1.75 {
                rate = 1.5
            } else if sliderValue < 2.25 {
                rate = 2
            } else {
                rate = 2.5
            }
        } else {
            if sliderValue < 3.25 {
                rate = 3
            } else if sliderValue < 3.75 {
                rate = 3.5
            } else if sliderValue < 4.25 {
                rate = 4
            } else if sliderValue < 4.75 {
                rate = 4.5
            } else {
                rate = 5
            }
        }
        var comment = ""
        if commentTextView.text != "添加些評論吧(選填)" {
            comment = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        // 上傳rate和comment
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

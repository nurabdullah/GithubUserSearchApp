//
//  DenemeViewController.swift
//  GithubUserSearchApp
//
//  Created by Abdullah Nur on 30.01.2024.
//

import UIKit
import Charts
class DenemeViewController: UIViewController, ChartViewDelegate {
    
    var pieChart = PieChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pieChart.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pieChart.frame = CGRect(x: 0, y: 0,
                                width:
                                    self.view.frame.size.width,
                                height:
                                    self.view.frame.size.width)
        pieChart.center = view.center
        view.addSubview(pieChart)
        
        var entries = [ChartDataEntry]()
        
        for x in 0..<3  {
            entries.append(ChartDataEntry(x: Double(x),
        y: Double (x)))
        
    }
        let set = PieChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.colorful()
        let data = PieChartData(dataSet: set)
        pieChart.data = data
        
    }
    
    
}

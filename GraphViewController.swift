//
//  GraphViewController.swift
//  Calculator
//
//  Created by Hatim Rehman on 2016-05-31.
//  Copyright © 2016 Hatim Rehman. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func function(_ x: CGFloat) -> CGFloat?
}

class GraphViewController: UIViewController, UIScrollViewDelegate, GraphViewDataSource {
    
    var graph = AxesDrawer(color: UIColor.white, contentScaleFactor: 1)

    fileprivate enum functionToGraph{
        case function((Double) -> Double)
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            //scrollView.minimumZoomScale = 0.5
            //scrollView.maximumZoomScale = 5.0
            /* add graphviewzoomgestureheresomewhere */
        }
    }
    
    
    fileprivate var zoomFactor:CGFloat = 0.0
    fileprivate var zoomLocation: CGPoint = CGPoint(x: 0, y: 0)
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        zoomFactor = scrollView.zoomScale
        
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        graphView.scale = graphView.scale*(scrollView.zoomScale/zoomFactor)
        zoomLocation = scrollView.contentOffset
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.contentOffset = zoomLocation
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return graphView
    }
    
    fileprivate var graphView = GraphView()
    
    fileprivate var brain = CalculatorBrain()
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return brain.program
        }
        set {
            brain.program = newValue
        }
    }
    
    func function(_ x: CGFloat) -> CGFloat? {
        let b = CalculatorBrain()
        b.setVariable(Double(x))
        b.program = brain.program
        return CGFloat(b.result.0)
        
    }
    
    override func viewDidLoad() {
        
        let tab = self.tabBarController?.tabBar
        
        tab?.barStyle = UIBarStyle.black
        tab?.isTranslucent = true
        tab?.tintColor = UIColor.white
        
        _ = UISplitViewControllerDisplayMode.allVisible
        
        let width = scrollView.bounds.maxX
        let height = scrollView.bounds.maxY
        
        graphView.dataSource = self
        graphView.frame = CGRect(x: 0, y: 0, width: width*2, height: height*2)
        
        graphView.backgroundColor = UIColor(red: 36/255, green: 36/255, blue: 36/255, alpha: 1.0)
        
        scrollView.backgroundColor = UIColor.orange
        
        scrollView.addSubview(graphView)
        
        scrollView.contentSize = graphView.frame.size
        
        scrollView.contentOffset = CGPoint(x: 5/3*scrollView.bounds.midX,y: scrollView.bounds.midY)
        
        
    }
    
    
}

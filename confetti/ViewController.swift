//
//  ViewController.swift
//  confetti
//
//  Created by Sebastián Fernández on 15-07-20.
//  Copyright © 2020 Sebastián Fernández. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    var confetti: ConfettiLayer!
   
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Load")
        // Do any additional setup after loading the view.
        confetti = ConfettiLayer(view: view)
        view.layer.addSublayer(confetti!.confettiLayer)
        self.confetti!.addBehaviors()
        
    }
    
   
    
    @IBAction func tapped(_ sender: Any) {
        self.confetti!.stopConfetti()
        print("Tapped!!")
    }
    

}

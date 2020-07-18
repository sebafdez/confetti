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
        confetti.startConfetti()
        
    }
    
   
    
    @IBAction func tapped(_ sender: Any) {
        confetti.startConfetti()
        print("Tapped!!")
        
    }
    

}

//
//  ViewController.swift
//  MovieKita
//
//  Created by Stevanus Prasetyo Soemadi on 01/07/20.
//  Copyright © 2020 Stevanus Prasetyo Soemadi. All rights reserved.
//

import UIKit
import netfox_ios

class ViewController: UIViewController {
	@IBOutlet weak var button: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		button.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)

		NFX.sharedInstance().start()

		// Do any additional setup after loading the view.
	}

	@objc func buttonTapped(sender : UIButton) {
		print("haloo")
		
		ServiceAPI.requestToken()
		.startWithResult({ result in
			print(result)
		})

		//Write button action here
	}
}


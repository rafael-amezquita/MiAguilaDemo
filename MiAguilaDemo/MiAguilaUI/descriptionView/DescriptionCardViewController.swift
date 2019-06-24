//
//  DescriptionCardViewController.swift
//  MiAguilaDemo
//
//  Created by Rafael Andres Amezquita Mejia on 6/23/19.
//  Copyright © 2019 Rafael Andres Amezquita Mejia. All rights reserved.
//

import UIKit

class DescriptionCardViewController: UIViewController {
  
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var originTimeLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var etaLabel: UILabel!
  
  var descriptionPresenter: DescriptionCardPresenter?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLabels()
  }
  
  private func setupLabels() {
    if let presenter = descriptionPresenter {
      self.originLabel.text = presenter.pathDescription?.originAddress
      self.originTimeLabel.text = presenter.pathDescription?.startTime
      self.destinationLabel.text = presenter.pathDescription?.destinationAddress
      self.etaLabel.text = presenter.pathDescription?.formatedETA
    }
    
  }
  
  @IBAction func dismiss(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
}

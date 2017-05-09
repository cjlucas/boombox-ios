//
//  ViewController.swift
//  BoomboxiOSExample
//
//  Created by Christopher Lucas on 6/19/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

import UIKit

import Boombox

class ViewController: UIViewController {
    fileprivate var boombox : BBXPlayer {
        get {
            let appd = UIApplication.shared.delegate as! AppDelegate
            return appd.player
        }
    }
    @IBOutlet weak var playPausedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addSourcesButtonPressed(_ sender: UIButton) {
        var bundle = Bundle.main
        for s in ["http://media.cjlucas.net/01.flac"] {
            boombox.add(URL(string: s))
            self.playPausedControl.setEnabled(true, forSegmentAt: 0)
        }
    }

    @IBAction func playPauseControlChanged(_ sender: UISegmentedControl) {
        print("rawr")
        switch (sender.selectedSegmentIndex) {
        case 0:
            boombox.play()
        case 1:
            boombox.pause()
        default:
            print("never should happen")
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        boombox.next()
    }
    @IBAction func prevButtonPressed(_ sender: AnyObject) {
        boombox.prev()
    }
}


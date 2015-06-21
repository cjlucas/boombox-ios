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
    private var boombox : BBXPlayer {
        get {
            let appd = UIApplication.sharedApplication().delegate as! AppDelegate
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

    @IBAction func addSourcesButtonPressed(sender: UIButton) {
        var bundle = NSBundle.mainBundle()
        for s in ["1", "2"] {
            println(s)
            if let url = bundle.URLForResource(s, withExtension: "mp3") {
                println("here")
                boombox.addURL(url)
                self.playPausedControl.setEnabled(true, forSegmentAtIndex: 0)
            }
        }
    }

    @IBAction func playPauseControlChanged(sender: UISegmentedControl) {
        println("rawr")
        switch (sender.selectedSegmentIndex) {
        case 0:
            boombox.play()
        case 1:
            boombox.pause()
        default:
            println("never should happen")
        }
    }
    
    @IBAction func nextButtonPressed(sender: AnyObject) {
        boombox.next()
    }
    @IBAction func prevButtonPressed(sender: AnyObject) {
        boombox.prev()
    }
}


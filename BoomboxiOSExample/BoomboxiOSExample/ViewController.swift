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
        for s in ["https://archive.org/download/johnmayer2008-08-02.DPA4023.flac16/John_Mayer_2008-08-02_t04.mp3", "https://archive.org/download/johnmayer2008-08-02.DPA4023.flac16/John_Mayer_2008-08-02_t05.mp3"] {
            boombox.addURL(NSURL(string: s))
            self.playPausedControl.setEnabled(true, forSegmentAtIndex: 0)
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


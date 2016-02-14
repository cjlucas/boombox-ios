//
//  PlaylistTableViewController.swift
//  BoomboxiOSExample
//
//  Created by Christopher Lucas on 6/21/15.
//  Copyright (c) 2015 Christopher Lucas. All rights reserved.
//

import UIKit

import Boombox

class PlaylistTableViewController: UITableViewController {
    
    func player() -> BBXPlayer {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).player
    }
    
    func playlistItem(indexPath: NSIndexPath) -> BBXPlaylistItem {
        return player().playlist.items()[indexPath.row] as! BBXPlaylistItem;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return player().playlist.items().count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell")
        cell?.textLabel?.text = playlistItem(indexPath).url().lastPathComponent
        return cell!
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        player().playItem(playlistItem(indexPath))
    }
}

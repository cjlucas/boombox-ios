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
        return (UIApplication.shared.delegate as! AppDelegate).player
    }
    
    func playlistItem(_ indexPath: IndexPath) -> BBXPlaylistItem {
        return player().playlist.items()[indexPath.row] as! BBXPlaylistItem;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return player().playlist.items().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = playlistItem(indexPath).url().lastPathComponent
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        player().play(playlistItem(indexPath))
    }
}

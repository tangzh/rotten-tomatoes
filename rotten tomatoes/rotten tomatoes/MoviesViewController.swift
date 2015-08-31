//
//  MoviesViewController.swift
//  rotten tomatoes
//
//  Created by Tang Zhang on 8/25/15.
//  Copyright (c) 2015 Tang Zhang. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrView: UIView!
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var hud: JGProgressHUD!
    
    func refresh(sender:AnyObject) {
        
        let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apiKey=dagqdghwaq3e3mxyrp7kmmj5&limit=50&country=us")!
        let request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()){ (response: NSURLResponse?, data: NSData!, error: NSError!) -> Void in
            if let response = response {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                if let json = json{
                    self.movies = json["movies"] as? [NSDictionary]
                    self.tableView.reloadData()
                    self.networkErrView.hidden = true
                }else {
                }
            }else {
               self.networkErrView.hidden = false
            }
            self.refreshControl.endRefreshing()
            self.hud.indicatorView.setProgress(1.0, animated: true)
            self.hud.dismiss()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        hud.textLabel.text = "loading"
        hud.indicatorView = JGProgressHUDPieIndicatorView(HUDStyle: hud.style)
        hud.showInView(self.view)
        hud.indicatorView.setProgress(0.0, animated: true)

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        refresh(self)
        tableView.dataSource = self
        tableView.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        }else {
            return 0
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieTableViewCell
        let movie = movies![indexPath.row]
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        var urlString = movie.valueForKeyPath("posters.thumbnail") as! String!
        var range = urlString.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            urlString = urlString.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        let url = NSURL(string: urlString)!
//        let imageHud = JGProgressHUD(style: JGProgressHUDStyle.ExtraLight)
//        imageHud.showInView(cell.posterView)
        
        cell.posterView.setImageWithURL(url)
    
//        imageHud.dismiss()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }

    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var vc = segue.destinationViewController as? MovieDetailsViewController
        var indexPath = tableView.indexPathForCell(sender as! MovieTableViewCell)
        
        let movie = movies![indexPath!.row]
        vc?.movie = movie
    }

}

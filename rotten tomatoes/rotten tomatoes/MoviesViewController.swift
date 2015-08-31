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
        let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apiKey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us")!
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
               self.networkErrView.layer.zPosition = 10
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        }else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieTableViewCell
        let movie = movies![indexPath.row]
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        var urlString = movie.valueForKeyPath("posters.thumbnail") as! String!
        let lowFiImageUrl = NSURL(string: urlString)!
        
        cell.posterView.setImageWithURLRequest(NSURLRequest(URL: lowFiImageUrl), placeholderImage: nil, success: {
            (request: NSURLRequest, response:NSHTTPURLResponse!, image: UIImage!) -> Void in
                if let image = image {
                    UIView.transitionWithView(cell.posterView, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                        cell.posterView.image = image
                    }, completion: nil)
                    var range = urlString.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
                    if let range = range {
                        urlString = urlString.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
                    }
                    let url = NSURL(string: urlString)!
                    cell.posterView.setImageWithURL(url)
                }
            }, failure: {
                (request:NSURLRequest!,response:NSHTTPURLResponse!, error:NSError!) -> Void in
                println(error)
                
        })

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

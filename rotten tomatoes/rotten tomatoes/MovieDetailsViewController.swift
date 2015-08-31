//
//  MovieDetailsViewController.swift
//  rotten tomatoes
//
//  Created by Tang Zhang on 8/30/15.
//  Copyright (c) 2015 Tang Zhang. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var movie: NSDictionary?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let movie = movie {
            titleLabel.text = movie["title"] as? String
            synopsisLabel.text = movie["synopsis"] as? String
            var urlString = movie.valueForKeyPath("posters.thumbnail") as! String!
            let lowFiImageUrl = NSURL(string: urlString)!
            
            imageView.setImageWithURLRequest(NSURLRequest(URL: lowFiImageUrl), placeholderImage: nil, success: {
                (request: NSURLRequest, response:NSHTTPURLResponse!, image: UIImage!) -> Void in
                    if let image = image {
                        self.imageView.image = image
                        var range = urlString.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
                        if let range = range {
                            urlString = urlString.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
                        }
                    }
                }, failure: {
                    (request:NSURLRequest!,response:NSHTTPURLResponse!, error:NSError!) -> Void in
                    println(error)
                    
            })
            
            let url = NSURL(string: urlString)!
            imageView.setImageWithURL(url)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

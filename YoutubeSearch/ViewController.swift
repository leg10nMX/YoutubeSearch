//
//  ViewController.swift
//  YoutubeSearch
//
//  Created by Emanuel Peña Aguilar on 15/10/14.
//  Copyright (c) 2014 Macrominds. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, ViewModelDelegate, UISearchBarDelegate {
  private struct Constants {
    static let CellIdentifier = "ViewController.Cell"
  }

  let model: ViewModel!
  
  override init() {
    super.init()
    self.model = ViewModel(delegate: self)
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.model = ViewModel(delegate: self)
  }
  
  func searchResultsDidChange() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.tableView.reloadData()
    })
  }
  
  func searchDidFailWithError(error: NSError) {
    let alert = UIAlertController(title: "Error", message: error.description, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    self.model.query = searchBar.text
    searchBar.resignFirstResponder()
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.model.itemCount()
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier) as UITableViewCell?
    if cell == nil {
      cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: Constants.CellIdentifier)
    }
    let item = self.model.itemAtIndex(indexPath.row)
    cell?.textLabel.text = item.title
    cell?.detailTextLabel?.text = item.videoDescription
    return cell!
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}


//
//  RulesController.swift
//  pblock
//
//  Created by Will Fleming on 8/29/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class RulesController: UITableViewController, NSFetchedResultsControllerDelegate, DetailViewController {
  private let batchSize = 50
  private let cacheName = "ThirdPartyRuleListCache"

  var ruleSource: RuleSource? {
    didSet {
      _fetchedResultsController = nil
      if let _ = fetchedResultsController {
        if let rs = ruleSource {
          self.navigationItem.title = rs.name
        } else {
          self.navigationItem.title = "Rules"
        }
      }
    }
  }
  var detailItem: AnyObject? {
    get {
      return ruleSource
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }


  // MARK: - Table View

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.fetchedResultsController?.sections?.count ?? 0
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sectionInfo = self.fetchedResultsController!.sections![section]
    return sectionInfo.numberOfObjects
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    self.configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let rule = self.fetchedResultsController!.objectAtIndexPath(indexPath) as? Rule
    cell.textLabel?.text = rule?.actionType.jsonValue()
  }

  // MARK: - Fetched results controller

  private var fetchedResultsController: NSFetchedResultsController? {
    get {
      if nil == _fetchedResultsController {
        if let ruleSource = ruleSource {
          let fetchRequest: NSFetchRequest? = CoreDataManager.sharedInstance.managedObjectModel?
            .fetchRequestFromTemplateWithName("RulesInSource",
              substitutionVariables: [ "SOURCE": ruleSource.objectID ]
            )
          fetchRequest?.sortDescriptors = [ NSSortDescriptor(key: "sourceText", ascending: true) ]
          fetchRequest?.shouldRefreshRefetchedObjects = true
          fetchRequest?.fetchBatchSize = batchSize
          if let fr = fetchRequest {
            NSFetchedResultsController.deleteCacheWithName(cacheName)
            _fetchedResultsController = NSFetchedResultsController(
              fetchRequest: fr,
              managedObjectContext: CoreDataManager.sharedInstance.managedObjectContext!,
              sectionNameKeyPath: nil,
              cacheName: cacheName
            )
            _fetchedResultsController?.delegate = self

            do {
              try _fetchedResultsController?.performFetch()
              dlog("rules fetched: \(_fetchedResultsController?.fetchedObjects?.count)")
            } catch {
              dlog("Failed fetch \(error)")
              abort() // crash!
            }
          }
        }
      }

      return _fetchedResultsController
    }

    set(val) {
      _fetchedResultsController = val
    }
  }
  private var _fetchedResultsController: NSFetchedResultsController?

  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    self.tableView.beginUpdates()
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    self.tableView.endUpdates()
  }

}
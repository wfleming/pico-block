//
//  FirstViewController.swift
//  pblock
//
//  Created by Will Fleming on 7/9/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import UIKit
import CoreData

class RuleSourcesController: UITableViewController, NSFetchedResultsControllerDelegate {

  private var coreDataMgr: CoreDataManager? = nil

  override func viewDidLoad() {
    super.viewDidLoad()

    coreDataMgr = CoreDataManager.sharedInstance
  }


  // MARK: - Segues

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if "showRuleSourceRules" == segue.identifier {
      if let indexPath = self.tableView.indexPathForSelectedRow {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        let navController = segue.destinationViewController as! UINavigationController
        let controller = navController.topViewController as! RulesController
        controller.ruleSource = object as? RuleSource
        controller.navigationItem.leftBarButtonItem = self.splitViewController?
          .displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }


  // MARK: - Table View

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.fetchedResultsController.sections?.count ?? 0
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sectionInfo = self.fetchedResultsController.sections![section]
    return sectionInfo.numberOfObjects
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    self.configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }

  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      let context = self.fetchedResultsController.managedObjectContext
      context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)

      do {
        try context.save()
      } catch {
        dlog("failed to save \(error)")
        abort() // crash!
      }
    }
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let ruleSource = self.fetchedResultsController.objectAtIndexPath(indexPath) as? RuleSource
    cell.textLabel?.text = ruleSource?.name
    cell.detailTextLabel?.text = ruleSource?.url
  }

  // MARK: - Fetched results controller

  lazy private var fetchedResultsController: NSFetchedResultsController = {
    var fetchRequest: NSFetchRequest = (self.coreDataMgr?.managedObjectModel?
      .fetchRequestTemplateForName("ThirdPartyRuleSources")?.copy() as! NSFetchRequest)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    let controller = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: self.coreDataMgr!.managedObjectContext!,
      sectionNameKeyPath: nil,
      cacheName: nil
    )
    controller.delegate = self

    do {
      try controller.performFetch()
    } catch {
      dlog("Failed fetch \(error)")
      abort() // crash!
    }

    return controller
  }()
  var _fetchedResultsController: NSFetchedResultsController? = nil

  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    self.tableView.beginUpdates()
  }

  func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    switch type {
    case .Insert:
      self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    case .Delete:
      self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    default:
      return
    }
  }

  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    switch type {
    case .Insert:
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    case .Delete:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
    case .Update:
      self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
    case .Move:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    }
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    self.tableView.endUpdates()
  }
}

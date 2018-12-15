//
//  ModuleListViewController.swift
//  Carrier Game
//
//  Created by Sean G Young on 10/28/18.
//  Copyright © 2018 Sean G Young. All rights reserved.
//

import UIKit
import CoreData
import SGYSwiftUtility

protocol ModuleListViewControllerDelegate: AnyObject {
    func moduleListViewController(_: ModuleListViewController, selectedModule: ModuleBlueprint)
}

class ModuleListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Initialization
    
    // MARK: - Properties
    
    weak var delegate: ModuleListViewControllerDelegate?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<ModuleBlueprint> = {
        let request = ModuleBlueprint.makeFetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ModuleBlueprint.identifier, ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: NSPersistentContainer.model.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        try! fetchedResultsController.performFetch()
    }

    // MARK: UITableView DataSource/Delegate Implementation

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let module = fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = module.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.moduleListViewController(self, selectedModule: fetchedResultsController.object(at: indexPath))
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

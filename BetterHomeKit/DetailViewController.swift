//
//  DetailViewController.swift
//  BetterHomeKit
//
//  Created by Khaos Tian on 6/4/14.
//  Copyright (c) 2014 Oltica. All rights reserved.
//

import UIKit
import HomeKit

class DetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,HMAccessoryDelegate {

    @IBOutlet var servicesTableView : UITableView?
    var services = [HMService]()

    var detailItem: HMAccessory? {
        didSet {
            self.title = detailItem!.name
            // Update the view.
            self.configureView()
        }
    }
    
    @IBAction func renameService(sender : AnyObject) {
        let alert:UIAlertController = UIAlertController(title: "Rename Accessory", message: "Enter the name you want for this accessory", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        alert.addAction(UIAlertAction(title: "Rename", style: UIAlertActionStyle.Default, handler:
            {
                (action:UIAlertAction!) in
                let textField = alert.textFields[0] as UITextField
                self.detailItem!.updateName(textField.text, completionHandler:
                    {
                        (error:NSError!) in
                        if !error {
                            self.title = textField.text
                        } else {
                            NSLog("Error:\(error)")
                        }
                    }
                )
            }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        dispatch_async(dispatch_get_main_queue(),
            {
                self.presentViewController(alert, animated: true, completion: nil)
            })
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        for service in detailItem!.services as [HMService] {
            if !contains(services, service) {
                services += service
                servicesTableView?.insertRowsAtIndexPaths([NSIndexPath(forRow:0, inSection:0)], withRowAnimation: .Automatic)
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCharacteristic" {
            let indexPath = servicesTableView?.indexPathForSelectedRow()
            if let indexPath = indexPath {
                let object = services[indexPath.row] as HMService
                servicesTableView?.deselectRowAtIndexPath(indexPath, animated: true)
                (segue.destinationViewController as CharacteristicViewController).detailItem = object
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let object = services[indexPath.row] as HMService
        if object.name {
            cell.textLabel.text = object.name
            if let serviceDesc = HomeKitUUIDs[object.serviceType] as? String {
                cell.detailTextLabel.text = serviceDesc
            }else{
                cell.detailTextLabel.text = object.serviceType
            }
        }else{
            if let serviceDesc = HomeKitUUIDs[object.serviceType] as? String {
                cell.detailTextLabel.text = serviceDesc
            }else{
                cell.detailTextLabel.text = object.serviceType
            }
            cell.detailTextLabel.text = ""
        }
        return cell
    }
    
    func accessoryDidUpdateName(accessory: HMAccessory!) {
        NSLog("accessoryDidUpdateName \(accessory)")
    }
    
    func accessory(accessory: HMAccessory!, didUpdateNameForService service: HMService!) {
        NSLog("\(accessory) didUpdateNameForService \(service.name)")
    }
    
    func accessoryDidUpdateServices(accessory: HMAccessory!) {
        NSLog("accessoryDidUpdateServices \(accessory.services)")
    }
    
    func accessoryDidUpdateReachability(accessory: HMAccessory!) {
        NSLog("accessoryDidUpdateReachability \(accessory.reachable)")
    }
    
    func accessory(accessory: HMAccessory!, service: HMService!, didUpdateValueForCharacteristic characteristic: HMCharacteristic!) {
        NSLog("didUpdateValueForCharacteristic \(characteristic)")
    }

}


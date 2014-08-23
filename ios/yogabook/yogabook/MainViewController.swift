//
//  MainViewController.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 7/19/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.reload()
        
//        🐢(5){
//            println("hello!")
//        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        
        let identifier: String = segue.identifier
        switch identifier {
            
        case "BuildSequenceID":
            
            if sender != nil {
                // Editing
                let yogaSequence = sender as YogaSequence
                let nsVC = segue.destinationViewController as BuildSequenceViewController
                nsVC.yogaSequence = yogaSequence
            }
        
        case "PlaySequenceID":
            let yogaSequence = sender as YogaSequence
            let pqVC = segue.destinationViewController as PlaySequenceViewController
            pqVC.yogaSequence = yogaSequence
        default:
             println("nothing")
            
        }
        

        
    }
    
    // UICollectionViewDelegate
    func collectionView(_collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return Data.sharedInstance.mySequences.count + 1
    }
    
    func collectionView(_collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let cell = _collectionView.dequeueReusableCellWithReuseIdentifier("YogaSequenceViewCellID", forIndexPath: indexPath) as YogaSequenceViewCell
        
        if Data.sharedInstance.mySequencesDict.count > 0 && indexPath.row < Data.sharedInstance.mySequencesDict.count{
            let sequence = Data.sharedInstance.mySequences[indexPath.row]
            
            cell.data = sequence
            
            cell.editAction = {
                [weak self] (yogaSequence: YogaSequence) -> () in
                self!.performSegueWithIdentifier("BuildSequenceID", sender: yogaSequence)
            }
            
            cell.removeAction = {
                [weak self] (yogaSequence: YogaSequence) -> () in
                let removed = Data.sharedInstance.mySequencesDict.removeValueForKey(yogaSequence.key)
                Data.sharedInstance.saveAll()
                self!.reload()
            }
            
        } else {
            cell.renderLast()
        }
        
        return cell
    }
    
    func reload() {
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        let t = (Data.sharedInstance.mySequences.count, indexPath.row)
        switch t {
        case (let count, let row) where count > 0 && row < count:
            let sequence = Data.sharedInstance.mySequences[row]
            self.performSegueWithIdentifier("PlaySequenceID", sender: sequence)
        default:
            self.performSegueWithIdentifier("BuildSequenceID", sender: nil)
        }
        
    }

}


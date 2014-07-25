//
//  MainViewController.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 7/19/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView
    
    let mySequencesKey = "mySequencesKey"
    var mySequences = [YogaSequence]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _mySequences: AnyObject! = Data.sharedInstance.unarchiveObjectForKey(mySequencesKey)
        if _mySequences {
            mySequences = _mySequences as [YogaSequence]
        }
        
        let y = YogaSequence()
        y.title = "HELLOW WORLD"
        mySequences.append(y)
    
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // UICollectionViewDelegate
    func collectionView(_collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return mySequences.count + 1
    }
    
    func collectionView(_collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let cell = _collectionView.dequeueReusableCellWithReuseIdentifier("MainCellIdentifier", forIndexPath: indexPath) as MainUICollectionViewCell
        
        if self.mySequences.count > 0 && indexPath.row < self.mySequences.count{
            let sequence = mySequences[indexPath.row]
            cell.data = sequence
            cell.editAction = { (yogaSequence: YogaSequence) -> Void in
                println(yogaSequence.title)
            }
        } else {
            cell.renderLast()
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        let t = (self.mySequences.count, indexPath.row)
        switch t {
        case (let count, let row) where count > 0 && row < count:
            let sequence = self.mySequences[row]
            println("count = \(count) | row = \(row)")
        default:
            self.performSegueWithIdentifier("NewSequenceModal", sender: nil)
        }
        
    }

}


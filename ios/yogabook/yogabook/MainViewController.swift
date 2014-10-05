//
//  MainViewController.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 7/19/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var sequences : [YogaSequence] = [YogaSequence]()
    
    override func viewDidLoad() {
        AudioPlayer.sharedInstance.speakText("Hello")
        sequences = Data.sharedInstance.mySequences
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let countBefore = sequences.count
        self.reload()
        let countAfter = sequences.count
        
        if countAfter > countBefore {
            let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
        }
        
//        🐢(2){
//            println("hello!")
//            AudioPlayer.sharedInstance.speakText("5 seconds remaining")
//
//        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        let identifier = segue.identifier
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
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sequences.count + 1
    }
    
    func collectionView(_collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = _collectionView.dequeueReusableCellWithReuseIdentifier("YogaSequenceViewCellID", forIndexPath: indexPath) as YogaSequenceViewCell
        
        if sequences.count > 0 && indexPath.item < sequences.count{
            let sequence = sequences[indexPath.item]
            
            cell.data = sequence
            
            cell.editAction = {
                [weak self] (yogaSequence: YogaSequence) -> () in
                self!.performSegueWithIdentifier("BuildSequenceID", sender: yogaSequence)
            }
            
        } else {
            cell.renderLast()
        }
        
        return cell
    }
    
    func reload() {
        self.sequences = Data.sharedInstance.mySequences
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        let t = (sequences.count, indexPath.item)
        switch t {
        case (let count, let row) where count > 0 && row < count:
            let sequence = sequences[row]
            self.performSegueWithIdentifier("PlaySequenceID", sender: sequence)
        default:
            self.performSegueWithIdentifier("BuildSequenceID", sender: nil)
        }
        
    }
    
    // Reordering
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, willMoveToIndexPath toIndexPath: NSIndexPath!) {
        let sequence = sequences[fromIndexPath.item]
        sequences.removeAtIndex(fromIndexPath.item)
        sequences.insert(sequence, atIndex: toIndexPath.item)
    }
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, canMoveToIndexPath toIndexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView!, canMoveItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didEndDraggingItemAtIndexPath indexPath: NSIndexPath!) {
        // Update sortingIndex
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            [weak self] in
            var i = 0
            for sequence in self!.sequences {
                sequence.sortingIndex = i
                i++
            }
            Data.sharedInstance.saveAll()
            Data.sharedInstance.updateAll()
        })
    }
    
}


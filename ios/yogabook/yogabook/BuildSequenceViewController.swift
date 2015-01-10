//
//  BuildSequenceViewController.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 7/22/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import UIKit
import Foundation

class BuildSequenceViewController: UIViewController, UICollectionViewDelegate, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var posesCollectionView: UICollectionView!
    @IBOutlet weak var sequenceCollectionView: UICollectionView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var filteringControl: UISegmentedControl!
    
    var yogaSequence: YogaSequence = YogaSequence()
    
    var filteringSortedKeys : [String] = [String]()
    var filteringPosesDict : Dictionary<String, [Pose]> = Dictionary<String, [Pose]>()
    
    enum FilteringType : Int {
        case Alphabetic, ByType, ByGroup
    }
    
    var currentFilteringType: FilteringType = .Alphabetic
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Double tap for adding pose to sequences
        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "processDoubleTap:")
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        doubleTapGesture.delaysTouchesBegan = true
        self.posesCollectionView?.addGestureRecognizer(doubleTapGesture)
        
        if !self.yogaSequence.title.isEmpty {
            self.titleTextField.text = self.yogaSequence.title
        }
        
        updateUI()
        applyCurrentFilter()
        
    }
    
    func applyCurrentFilter() {
        
        // init values
        filteringPosesDict = Dictionary<String, [Pose]>()
        let poses = Data.sharedInstance.poses
        
        // filtering
        switch currentFilteringType {
        case .Alphabetic:
            for pose in poses {
                let key = pose.key.substringToIndex(advance(pose.key.startIndex, 1)).uppercaseString
                var posesForKey = filteringPosesDict[key]
                if posesForKey == nil {
                    posesForKey = [Pose]()
                }
                posesForKey!.append(pose)
                filteringPosesDict[key] = posesForKey
            }
            
            
            
//            var c = 0
//            for key in filteringPosesDict.keys.array {
//                if let poses = filteringPosesDict[key] {
//                    c += poses.count
//                    println("Key: \(key) -> \(poses.count) poses")
//                } else {
//                    println("Key: \(key) -> 0 poses")
//                }
//                
//            }
//            
//            println("total \(c) poses vs \(Data.sharedInstance.poses.count) real")
            
            
        case .ByGroup:
            print("")
            
        case .ByType:
            // Category: ie. Backbends, etc
            for pose in poses {
                let key = pose.category.uppercaseString
                var posesForKey = filteringPosesDict[key]
                if posesForKey == nil {
                    posesForKey = [Pose]()
                }
                posesForKey!.append(pose)
                filteringPosesDict[key] = posesForKey
            }
            
        }
    
        // keys
        filteringSortedKeys = filteringPosesDict.keys.array
        filteringSortedKeys.sort({$0 < $1})
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onDone() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onDelete(sender: AnyObject) {
        
        var alert = UIAlertController(title: "Delete this sequence?", message: "Are you sure you want to delete this sequence", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { [weak self] (action) -> Void in
            Data.sharedInstance.removeSequenceWithKey(self!.yogaSequence.key)
            self!.dismissViewControllerAnimated(true, completion: { () -> Void in
                self!.dismissViewControllerAnimated(true, completion: nil)
            })
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func onSave() {
        if self.yogaSequence.poses.count > 0 {
            if !self.titleTextField.text.isEmpty {
                self.yogaSequence.title = self.titleTextField.text
                Data.sharedInstance.insertSequence(yogaSequence)
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.titleTextField.becomeFirstResponder()
            }
            
        }
    }
    
    @IBAction func onFilteringTypeChanged(sender: AnyObject) {
        
        if let currentFilteringType = FilteringType(rawValue: filteringControl.selectedSegmentIndex) {
            self.currentFilteringType = currentFilteringType
            applyCurrentFilter()
            posesCollectionView.reloadData()
        }
        
        
        
    }

    func processDoubleTap(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            let point: CGPoint = gesture.locationInView(self.posesCollectionView)
            if point.x >= 0 && point.y >= 0 {
                if let indexPath: NSIndexPath = self.posesCollectionView.indexPathForItemAtPoint(point) {
                    let cell: PoseViewCell = self.posesCollectionView.cellForItemAtIndexPath(indexPath) as PoseViewCell
                    let poseInSequence = PoseInSequence(poseKey: cell.data.key)
                    self.yogaSequence.poses.append(poseInSequence)
                    let insertionIndexPath = NSIndexPath(forItem: self.yogaSequence.poses.count-1, inSection: 0)
                    self.sequenceCollectionView.insertItemsAtIndexPaths([insertionIndexPath])
                    self.sequenceCollectionView.scrollToItemAtIndexPath(insertionIndexPath, atScrollPosition: .Bottom, animated: true)
                    updateUI()
                }
            }
        }
    }
    
    func updateUI() {
        updateTotalTime()
        if self.yogaSequence.poses.count > 0 {
            self.saveButton.enabled = true
        } else {
            self.saveButton.enabled = false
        }
        filteringControl.selectedSegmentIndex = currentFilteringType.rawValue
    }
    
    func updateTotalTime() {
        let (minutes, seconds) = self.yogaSequence.getMinutesSeconds()
        self.totalTimeLabel.text = String(format: "%.2d m %.2d s", minutes, seconds)
    }
    

}

extension BuildSequenceViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if collectionView == posesCollectionView {
            return filteringSortedKeys.count
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.posesCollectionView {
            let groupKey = filteringSortedKeys[section]
            if let poses = filteringPosesDict[groupKey] {
                return poses.count
            }
        } else if collectionView == self.sequenceCollectionView {
            return self.yogaSequence.poses.count
        }
        
        return 0;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cellID : String = ""
        if collectionView == self.posesCollectionView {
            cellID = "PoseViewCellID"
        } else if collectionView == self.sequenceCollectionView {
            cellID = "PoseSequenceViewCellID"
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as UICollectionViewCell
        
        if collectionView == self.posesCollectionView { // Right Column Collection
            
            let _cell = cell as PoseViewCell
            let groupKey = filteringSortedKeys[indexPath.section]
            if let poses = filteringPosesDict[groupKey] {
                _cell.data = poses[indexPath.row]
            }
            
            
        } else if collectionView == self.sequenceCollectionView { // Main Collection
            let _cell = cell as PoseSequenceViewCell
            let poseInSequence = self.yogaSequence.poses[indexPath.row]
            _cell.data = poseInSequence
            _cell.onTimeChanged = {
                [weak self] in
                self!.updateTotalTime()
            }
            _cell.onItemRemove = {
                [weak self, weak _cell] in
                if let ipath = self!.sequenceCollectionView.indexPathForCell(_cell!) {
                    self!.yogaSequence.poses.removeAtIndex(indexPath.row)
                    self!.sequenceCollectionView.deleteItemsAtIndexPaths([ipath])
                    self!.updateUI()
                }
            }
        }
        
        return cell;

    }
    
 
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "PosesCollectionHeaderID", forIndexPath: indexPath) as PosesCollectionSectionHeader
        
        header.titleLabel.text = filteringSortedKeys[indexPath.section]
        
        return header
    }

}

extension BuildSequenceViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        
    }
    
    // Reordering
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, willMoveToIndexPath toIndexPath: NSIndexPath!) {
        if collectionView == sequenceCollectionView {
            let poseInSequence = yogaSequence.poses[fromIndexPath.item]
            yogaSequence.poses.removeAtIndex(fromIndexPath.item)
            yogaSequence.poses.insert(poseInSequence, atIndex: toIndexPath.item)
        }
    }
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, canMoveToIndexPath toIndexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView!, canMoveItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    

}

extension BuildSequenceViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField!) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField!) -> Bool {
        return true
    }
    
}



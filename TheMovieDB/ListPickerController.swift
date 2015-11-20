//
//  ListPickerController.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/20/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import UIKit

class ListPickerController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, ListsDelegate {
    
    var itemId: String?
    var itemType: String?
    var lists = [ListInfo]()
    var accountManager: AccountManager?
    
    @IBOutlet weak var listImageView: UIImageView!
    @IBOutlet weak var listsPicker: UIPickerView!
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func doneButtonClicked(sender: AnyObject) {
        print("Picked item is \(lists[listsPicker.selectedRowInComponent(0)].listName)")
    }
    
    override func viewDidLoad() {
        print("Item with id \(itemId ?? "none") and of type \(itemType ?? "none")")
        let sessionId = SessionCache.restoreSession()?.sessionToken
        if let session = sessionId {
            accountManager = AccountManager(session: session, accountDelegate: nil, listsDelegate: self)
            accountManager?.loadAccountData()
        }
        
        listsPicker.dataSource = self
        listsPicker.delegate = self
    }
    
    func userFetched() {
        accountManager?.loadSegment(.List)
    }
    
    func userListsLoadedSuccessfully(pages: ListInfoPages) {
        if let results = pages.results {
            lists += results
            listsPicker.reloadAllComponents()
        }
    }
    
    func userListsLoadingFailed(error: NSError) {
        print(error)
    }
    
    func userSegmentLoadedSuccessfully(results: SegmentList) { }
    
    func userSegmentLoadingFailed(error: NSError) { }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lists.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return lists[row].listName
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        listImageView.sd_setImageWithURL(NSURL(imagePath: lists[row].posterPath, size: 4), placeholderImage: UIImage.placeholder())
    }
    
}

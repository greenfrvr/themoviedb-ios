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
    var lists = [CompilationInfo]()
    var accountManager: AccountManager?
    var selectedList: CompilationInfo {
        let index = listsPicker.selectedRowInComponent(0)
        return lists[index]
    }
    
    @IBOutlet weak var listImageView: UIImageView!
    @IBOutlet weak var listsPicker: UIPickerView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var itemsCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonClicked(sender: AnyObject) {
        if let listId = selectedList.id, id = Int(self.itemId!) {
            accountManager?.addToList(listId: listId, itemId: id)
        }
    }
    
    override func viewDidLoad() {
        if let session = Cache.restoreSession() {
            accountManager = AccountManager(session: session, accountDelegate: nil, listsDelegate: self)
            accountManager?.loadAccountData()
        }
        
        listsPicker.dataSource = self
        listsPicker.delegate = self
    }
    
    func userFetched() {
        accountManager?.loadSegment(.List)
    }
    
    func userListsLoadedSuccessfully(pages: CompilationInfoPages) {
        if let results = pages.results {
            lists += results
            listsPicker.reloadAllComponents()
            if let item = lists.first {
                displayListInfo(item)
            }
        }
    }
    
    func userListsLoadingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
    }
    
    func listItemUpdatedSuccessfully() {
        notifyListsUpdate()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func notifyListsUpdate() {
        guard let listId = selectedList.id else { return }

        let dictionary = [ "listId" : listId]
        NSNotificationCenter.defaultCenter().postNotificationName(Notify.ListUpdate.rawValue, object: nil, userInfo: dictionary)
    }
    
    func listItemUpdatingFailed(error: NSError) {
        if let error = error.apiError {
            error.printError()
        }
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
        animateInfo(alpha: 0,
            completion: { completed in
            if completed {
                self.displayListInfo(self.lists[row])
                self.animateInfo(alpha: 1)
            }
        })
    }
    
    func displayListInfo(item: CompilationInfo){
        listImageView.sd_setImageWithURL(NSURL(posterPath: item.posterPath, size: 4), placeholderImage:  UIImage(res: .Placeholder))
        descriptionLabel.text = item.representDescription
        
        if let count = item.itemsInList where count > 0 {
            itemsCountLabel.text = "Totally \(count) item\(count > 1 ? "s" : "") in list"
        } else {
            itemsCountLabel.text = "No items have been added yet."
        }
        
        if let count = item.favoriteCount where count > 0 {
            favoriteCountLabel.text = "Contains \(count) favorite\(count > 1 ? "s" : "")"
        } else {
            favoriteCountLabel.text = ""
        }
    }
    
    private func animateInfo(alpha alpha: CGFloat, completion: ((Bool) -> Void)? = nil){
        let animations = {
            self.listImageView.alpha = alpha
            self.descriptionLabel.alpha = alpha
            self.itemsCountLabel.alpha = alpha
            self.favoriteCountLabel.alpha = alpha
        }
        
        UIView.animateWithDuration(0.3, animations: animations, completion: completion)
    }
}

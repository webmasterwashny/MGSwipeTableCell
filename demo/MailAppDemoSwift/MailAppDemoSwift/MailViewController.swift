//
//  ViewController.swift
//  MailAppDemoSwift
//
//  Created by Imanol Fernandez Gorostizag on 17/11/14.
//  Copyright (c) 2014 Imanol Fernandez. All rights reserved.
//

import UIKit

class MailData {
    var from: String!;
    var subject: String!;
    var message: String!;
    var date: String!;
    var read = false;
    var flag = false;
}

typealias MailActionCallback = (cancelled: Bool, deleted: Bool, actionIndex: Int) -> Void

class MailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate, UIActionSheetDelegate {
    
    var tableView: UITableView!;
    var demoData = [MailData]();
    var refreshControl: UIRefreshControl!;
    var actionCallback: MailActionCallback?;
    
    func prepareDemoData() {
        var from = [
        "Vincent",
        "Mr Glass",
        "Marsellus",
        "Ringo",
        "Sullivan",
        "Mr Wolf",
        "Butch Coolidge",
        "Marvin",
        "Captain Koons",
        "Jules",
        "Jimmie Dimmick"
        ];
        
        var subjects = [
       "You think water moves fast?",
       "They called me Mr Glass",
       "The path of the righteous man",
       "Do you see any Teletubbies in here?",
       "Now that we know who you are",
       "My money's in that office, right?",
       "Now we took an oath",
       "That show's called a pilot",
       "I know who I am. I'm not a mistake",
       "It all makes sense!",
       "The selfish and the tyranny of evil men",
        ];
        
        var messages = [
        "You should see ice. It moves like it has a mind. Like it knows it killed the world once and got a taste for murder. After the avalanche, it took us a week to climb out.",
        "And I will strike down upon thee with great vengeance and furious anger those who would attempt to poison and destroy My brothers.",
        "Look, just because I don't be givin' no man a foot massage don't make it right for Marsellus to throw Antwone into a glass motherfuckin' house",
        "No? Well, that's what you see at a toy store. And you must think you're in a toy store, because you're here shopping for an infant named Jeb.",
        "In a comic, you know how you can tell who the arch-villain's going to be? He's the exact opposite of the hero",
        "If she start giving me some bullshit about it ain't there, and we got to go someplace else and get it, I'm gonna shoot you in the head then and there.",
        "that I'm breaking now. We said we'd say it was the snow that killed the other two, but it wasn't. Nature is lethal but it doesn't hold a candle to man.",
        "Then they show that show to the people who make shows, and on the strength of that one show they decide if they're going to make more shows.",
        "And most times they're friends, like you and me! I should've known way back when...",
        "After the avalanche, it took us a week to climb out. Now, I don't know exactly when we turned on each other, but I know that seven of us survived the slide",
        "Blessed is he who, in the name of charity and good will, shepherds the weak through the valley of darkness, for he is truly his brother's keeper and the finder of lost children",
        ];
        
        
        for var i = 0; i < messages.count; ++i {
            let mail = MailData();
            mail.from = from[i];
            mail.subject = subjects[i];
            mail.message = messages[i];
            mail.date = String(format: "11:%d", arguments: [43 - i]);
            demoData.append(mail);
        }
    }
    
    func mailForIndexPath(path: NSIndexPath) -> MailData {
        return demoData[path.row];
    }
    
    func refreshCallback() {
        prepareDemoData();
        tableView.reloadData();
        refreshControl.endRefreshing();
    }
    
    func deleteMail(path:NSIndexPath) {
        demoData.removeAtIndex(path.row);
        tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Left);
    }
    
    func updateCellIndicator(mail: MailData, cell: MailTableCell) {
        var color: UIColor;
        var innerColor : UIColor?;
        
        if mail.read && mail.flag {
            color = UIColor.init(red: 1.0, green: 149/255.0, blue: 0.05, alpha: 1.0);
            innerColor = UIColor.init(red: 0.0, green: 122/255.0, blue: 1.0, alpha: 1.0);
        }
        else if mail.flag {
            color = UIColor.init(red: 1.0, green: 149/255.0, blue: 0.05, alpha: 1.0);
        }
        else if mail.read {
            color = UIColor.clearColor();
        }
        else {
            color = UIColor.init(red: 1.0, green: 122/255.0, blue: 1.0, alpha: 1.0);
        }
        
        cell.indicatorView.indicatorColor = color;
        cell.indicatorView.innerColor = innerColor;
    }
    
    func showMailActions(mail: MailData, callback: MailActionCallback) {
        actionCallback = callback;
        let sheet = UIActionSheet.init(title: "Actions", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Trash");
        sheet.addButtonWithTitle("Mark as unread");
        sheet.addButtonWithTitle("Mark as read");
        sheet.addButtonWithTitle("Flag");

        sheet.showInView(self.view);
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex index: Int) {
        if let action = actionCallback {
            action(cancelled: index == actionSheet.cancelButtonIndex,
                   deleted:index == actionSheet.destructiveButtonIndex,
                   actionIndex: index);
            actionCallback = nil;
        }
    }
    
    func readButtonText(read:Bool) -> String {
        return read ? "Mark as\nunread" : "Mark as\nread";
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.bounds, style: UITableViewStyle.Plain);
        tableView.delegate = self;
        tableView.dataSource = self;
        view.addSubview(tableView);
        
        self.title = "MSwipeTableCell MailApp";
        
        refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: #selector(refreshCallback), forControlEvents: UIControlEvents.ValueChanged);
        tableView.addSubview(refreshControl);
        prepareDemoData();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return demoData.count;
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "MailCell";
        
        var cell: MailTableCell! = tableView.dequeueReusableCellWithIdentifier(identifier) as? MailTableCell;
        if cell == nil {
            cell = MailTableCell(style: UITableViewCellStyle.Default, reuseIdentifier: identifier);
        }
        cell.delegate = self;
        
        let data: MailData = demoData[indexPath.row];
        cell!.mailFrom.text = data.from;
        cell!.mailSubject.text = data.subject;
        cell!.mailMessage.text = data.message;
        cell!.mailTime.text = data.date;
        updateCellIndicator(data, cell: cell);
        return cell;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110;
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true;
    }
    
    //-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
    //             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
    //{
    //
    //    swipeSettings.transition = MGSwipeTransitionBorder;
    //    expansionSettings.buttonIndex = 0;
    //
    //    __weak MailViewController * me = self;
    //    MailData * mail = [me mailForIndexPath:[self.tableView indexPathForCell:cell]];
    //
    //    if (direction == MGSwipeDirectionLeftToRight) {
    //
    //        expansionSettings.fillOnTrigger = NO;
    //        expansionSettings.threshold = 2;
    //        return @[[MGSwipeButton buttonWithTitle:[me readButtonText:mail.read] backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0] padding:5 callback:^BOOL(//MGSwipeTableCell *sender) {
    //
    //            MailData * mail = [me mailForIndexPath:[me.tableView indexPathForCell:sender]];
    //            mail.read = !mail.read;
    //            [me updateCellIndicactor:mail cell:(MailTableCell*)sender];
    //            [cell refreshContentView]; //needed to refresh cell contents while swipping
    //
    //            //change button text
    //            [(UIButton*)[cell.leftButtons objectAtIndex:0] setTitle:[me readButtonText:mail.read] forState:UIControlStateNormal];
    //
    //            return YES;
    //        }]];
    //    }
    //    else {
    //
    //        expansionSettings.fillOnTrigger = YES;
    //        expansionSettings.threshold = 1.1;
    //
    //        CGFloat padding = 15;
    //
    //        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"Trash" backgroundColor:[UIColor colorWithRed:1.0 green:59/255.0 blue:50/255.0 alpha:1.0] padding:padding callback:^BOOL(//MGSwipeTableCell *sender) {
    //
    //            NSIndexPath * indexPath = [me.tableView indexPathForCell:sender];
    //            [me deleteMail:indexPath];
    //            return NO; //don't autohide to improve delete animation
    //        }];
    //        MGSwipeButton * flag = [MGSwipeButton buttonWithTitle:@"Flag" backgroundColor:[UIColor colorWithRed:1.0 green:149/255.0 blue:0.05 alpha:1.0] padding:padding callback:^BOOL(//MGSwipeTableCell *sender) {
    //
    //            MailData * mail = [me mailForIndexPath:[me.tableView indexPathForCell:sender]];
    //            mail.flag = !mail.flag;
    //            [me updateCellIndicactor:mail cell:(MailTableCell*)sender];
    //            [cell refreshContentView]; //needed to refresh cell contents while swipping
    //            return YES;
    //        }];
    //        MGSwipeButton * more = [MGSwipeButton buttonWithTitle:@"More" backgroundColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:205/255.0 alpha:1.0] padding:padding callback:^BOOL(//MGSwipeTableCell *sender) {
    //
    //            NSIndexPath * indexPath = [me.tableView indexPathForCell:sender];
    //            MailData * mail = [me mailForIndexPath:indexPath];
    //            MailTableCell * cell = (MailTableCell*) sender;
    //            [me showMailActions:mail callback:^(BOOL cancelled, BOOL deleted, NSInteger actionIndex) {
    //                if (cancelled) {
    //                    return;
    //                }
    //                if (deleted) {
    //                    [me deleteMail:indexPath];
    //                }
    //                else if (actionIndex == 1) {
    //                    mail.read = !mail.read;
    //                    [(UIButton*)[cell.leftButtons objectAtIndex:0] setTitle:[me readButtonText:mail.read] forState:UIControlStateNormal];
    //                    [me updateCellIndicactor:mail cell:cell];
    //                    [cell refreshContentView]; //needed to refresh cell contents while swipping
    //                }
    //                else if (actionIndex == 2) {
    //                    mail.flag = !mail.flag;
    //                    [me updateCellIndicactor:mail cell:cell];
    //                    [cell refreshContentView]; //needed to refresh cell contents while swipping
    //                }
    //                
    //                [cell hideSwipeAnimated:YES];
    //                
    //            }];
    //            
    //            return NO; //avoid autohide swipe
    //        }];
    //        
    //        return @[trash, flag, more];
    //    }
    //    
    //    return nil;
    //    
    //}

    
    
    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        
        swipeSettings.transition = MGSwipeTransition.Border;
        expansionSettings.buttonIndex = 0;
        
        
        let mail = mailForIndexPath(tableView.indexPathForCell(cell)!);
        
        if direction == MGSwipeDirection.LeftToRight {
            expansionSettings.fillOnTrigger = false;
            expansionSettings.threshold = 2;
            
            return [
                MGSwipeButton(title: readButtonText(mail.read), backgroundColor: UIColor.init(red:1.0, green:59/255.0, blue:50/255.0, alpha:1.0), callback: { (cell) -> Bool in
                    mail.read = !mail.read;
                    self.updateCellIndicator(mail, cell: cell as! MailTableCell);
                    cell.refreshContentView();
                    
                    (cell.leftButtons[0] as! UIButton).setTitle(self.readButtonText(mail.read), forState: .Normal);
                    
                    return true;
                })
            ]
        }
        
        return [];
    }



}

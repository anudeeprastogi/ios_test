//
//  ViewController.h
//  YakinmbiICT
//
//  Created by Anudeep Rastogi on 2/19/13.
//  Copyright (c) 2013 Anudeep Rastogi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SBJsonStreamParser;
@class SBJsonStreamParserAdapter;
@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,SBJsonStreamParserAdapterDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentCtrl;
@property (weak, nonatomic) IBOutlet UITableView *filesTableView;
- (IBAction)segmentCtrlClicked:(id)sender;

@end

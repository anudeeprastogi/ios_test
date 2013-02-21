//
//  CustomCell.h
//  YakinmbiICT
//
//  Created by Anudeep Rastogi on 2/19/13.
//  Copyright (c) 2013 Anudeep Rastogi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;
@property (weak, nonatomic) IBOutlet UILabel *linkLbl;
@property (weak, nonatomic) IBOutlet UILabel *isSharedLbl;
@property (weak, nonatomic) IBOutlet UILabel *sharedIDLbl;
@property (weak, nonatomic) IBOutlet UILabel *userIDLbl;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *sharedByLbl;
@property (weak, nonatomic) IBOutlet UILabel *sharedDateLbl;
@property (weak, nonatomic) IBOutlet UILabel *shareLevelLbl;
@property (weak, nonatomic) IBOutlet UILabel *parentIDLbl;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedDateLbl;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedByLbl;
@property (weak, nonatomic) IBOutlet UILabel *createdDateLbl;
@property (weak, nonatomic) IBOutlet UILabel *itemIDLbl;
@property (weak, nonatomic) IBOutlet UILabel *pathLbl;
@property (weak, nonatomic) IBOutlet UILabel *pathByIDLbl;
@property (weak, nonatomic) IBOutlet UILabel *typeLbl;
@property (weak, nonatomic) IBOutlet UILabel *mimeTypeLbl;
@property (weak, nonatomic) IBOutlet UILabel *sizeLbl;
@property (weak, nonatomic) IBOutlet UILabel *loadMoreLbl;

@end

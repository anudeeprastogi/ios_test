//
//  PopTableCell.m
//  YakinmbiICT
//
//  Created by Anudeep Rastogi on 2/21/13.
//  Copyright (c) 2013 Anudeep Rastogi. All rights reserved.
//

#import "PopTableCell.h"

@implementation PopTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

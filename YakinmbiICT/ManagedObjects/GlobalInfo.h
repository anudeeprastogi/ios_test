//
//  GlobalInfo.h
//  YakinmbiICT
//
//  Created by Anudeep Rastogi on 2/19/13.
//  Copyright (c) 2013 Anudeep Rastogi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GlobalInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * totalSpace;
@property (nonatomic, retain) NSNumber * lastRevID;
@property (nonatomic, retain) NSNumber * usedSpace;
@property (nonatomic, retain) NSNumber * availableSpace;
@property (nonatomic, retain) NSString * mode;
@property (nonatomic, retain) NSNumber * pendingRequests;
@property (nonatomic, retain) NSNumber * revID;

@end

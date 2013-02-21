//
//  Files.h
//  YakinmbiICT
//
//  Created by Anudeep Rastogi on 2/20/13.
//  Copyright (c) 2013 Anudeep Rastogi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Files : NSManagedObject

@property (nonatomic, retain) NSString * createdDate;
@property (nonatomic, retain) NSNumber * fileSize;
@property (nonatomic, retain) NSString * isShared;
@property (nonatomic, retain) NSNumber * itemID;
@property (nonatomic, retain) NSString * lastUpdatedBy;
@property (nonatomic, retain) NSString * lastUpdatedDate;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * mimeType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * parentID;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * pathByID;
@property (nonatomic, retain) NSNumber * sharedBy;
@property (nonatomic, retain) NSString * sharedDate;
@property (nonatomic, retain) NSString * sharedID;
@property (nonatomic, retain) NSNumber * shareLevel;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * fileType;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSNumber * localType;

@end

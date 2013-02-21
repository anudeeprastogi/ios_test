//
//  ViewController.m
//  YakinmbiICT
//
//  Created by Anudeep Rastogi on 2/19/13.
//  Copyright (c) 2013 Anudeep Rastogi. All rights reserved.
//

#import "ViewController.h"
#import "CustomCell.h"
#import "Files.h"
#import "GlobalInfo.h"

@interface ViewController (){
    SBJsonStreamParser *parser;
    SBJsonStreamParserAdapter *adapter;
}

@property BOOL areMoreFilesAvailable;
@property BOOL areMoreSharedFilesAvailable;
@property int loadCounter;
@property int sharedLoadCounter;
@property (strong,nonatomic) NSMutableArray *myFilesArray;
@property (strong,nonatomic) NSMutableArray *sharedFilesArray;
@end

@implementation ViewController

@synthesize areMoreFilesAvailable;
@synthesize areMoreSharedFilesAvailable;
@synthesize loadCounter;
@synthesize sharedLoadCounter;
@synthesize myFilesArray;
@synthesize sharedFilesArray;

#pragma mark- 
#pragma mark- Core Data Methods

-(BOOL)isCoreDataEmpty:(NSString *)entityName andType:(NSNumber *)type{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[RootDelegate managedObjectContext]];
    [request setEntity:entity];
    request.predicate = [NSPredicate predicateWithFormat: @"localType == %@",type];
    request.fetchLimit = 1;
    NSError *error = nil;
    NSArray *entries = [[RootDelegate managedObjectContext] executeFetchRequest:request error:&error];
    if ([entries count])return NO;
    else return YES;
}
-(Files *)isAlreadyAddedFile:(NSString *)entityName andMatchDict:(NSDictionary *)vDict andType:(NSNumber *)type{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[RootDelegate managedObjectContext]];
    [request setEntity:entity];
    //request.predicate = [NSPredicate predicateWithFormat: @"localType == %@ AND itemID == %@ AND fileSize == %@",type,vDict[@"item_id"],vDict[@"size"],vDict[@"status"]];
    request.predicate = [NSPredicate predicateWithFormat: @"localType == %@ AND itemID == %@ AND fileSize == %@ AND status MATCHES %@",type,vDict[@"item_id"],vDict[@"size"],vDict[@"status"]];

    request.fetchLimit = 1;
    NSError *error = nil;
    NSArray *entries = [[RootDelegate managedObjectContext] executeFetchRequest:request error:&error];
    if ([entries count]>0)return [entries objectAtIndex:0];
    else return nil;
}
-(GlobalInfo *)globalInfoForEntity:(NSString *)entityName andRevID:(NSNumber *)revID{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[RootDelegate managedObjectContext]];
    [request setEntity:entity];
    request.predicate = [NSPredicate predicateWithFormat: @"revID == %@",revID];
    request.fetchLimit = 1;
    NSError *error = nil;
    NSArray *entries = [[RootDelegate managedObjectContext] executeFetchRequest:request error:&error];
    if ([entries count])return [entries objectAtIndex:0];
    else return nil;
}
-(NSArray *)coreDataEntriesForEntity:(NSString *)entityName andType:(NSNumber *)type{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[RootDelegate managedObjectContext]];
    [request setEntity:entity];
    request.predicate = [NSPredicate predicateWithFormat: @"localType == %@",type];
    NSError *error = nil;
    NSArray *entries = [[RootDelegate managedObjectContext] executeFetchRequest:request error:&error];
    NSLog(@"Entries %d",[entries count]);

    if ([entries count])return entries;    
    else return nil;
}

#pragma mark-
#pragma mark- Core Data Methods end

- (void)viewDidUnload{
    
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"First View";
    
    self.myFilesArray = [[NSMutableArray alloc]init];
    self.sharedFilesArray = [[NSMutableArray alloc]init];
    
    adapter = [[SBJsonStreamParserAdapter alloc] init];
    adapter.delegate = self;
    
    parser = [[SBJsonStreamParser alloc] init];
    parser.delegate = adapter;
    parser.supportMultipleDocuments = YES;
 
    self.loadCounter = 20;
    self.sharedLoadCounter = 20;
    
    self.areMoreFilesAvailable = YES;
    self.areMoreSharedFilesAvailable = YES;
    [self setupFilesTableWithType:MYFILESTYPE];
}

-(void)setupFilesTableWithType:(NSString *)fileType{
    
    self.segmentCtrl.userInteractionEnabled = NO;
    NSNumber *localType;
    if ([fileType isEqualToString:MYFILESTYPE]) {
        localType = [NSNumber numberWithInt:10];
    }
    if ([fileType isEqualToString:SHAREDFILESTYPE]) {
        localType = [NSNumber numberWithInt:20];
    }
    
    BOOL areFilesEmpty = [self isCoreDataEmpty:@"Files" andType:localType];
    if (areFilesEmpty == NO ) {
        NSArray *coreDataEntries = [self coreDataEntriesForEntity:@"Files" andType:localType];
        for (Files *fileOb in coreDataEntries) {
            if ([fileType isEqualToString:MYFILESTYPE]) {
                NSIndexPath *myFileIndexPath = [NSIndexPath indexPathForRow:[self.myFilesArray count] inSection:0];
                [self.myFilesArray addObject:fileOb];
                [self.filesTableView beginUpdates];
                [self.filesTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:myFileIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.filesTableView endUpdates];
            }
            if ([fileType isEqualToString:SHAREDFILESTYPE]) {
                NSIndexPath *sharedFileIndex = [NSIndexPath indexPathForRow:[self.sharedFilesArray count] inSection:0];
                [self.sharedFilesArray addObject:fileOb];
                [self.filesTableView beginUpdates];
                [self.filesTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:sharedFileIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.filesTableView endUpdates];
            }
        }
        
        int addedMyFileBound = 0;
        int addedSharedFileBound = 0;
        if ([self.myFilesArray count]%20 ==0) {
            addedMyFileBound = 1;
        }
        if ([self.sharedFilesArray count]%20 ==0) {
            addedSharedFileBound = 1;
        }
        
        int myFilePage = [self.myFilesArray count]/20+addedSharedFileBound;
        int sharedFilePage = [self.sharedFilesArray count]/20+addedSharedFileBound;
        self.loadCounter = myFilePage*20;
        self.sharedLoadCounter = sharedFilePage*20;
        self.segmentCtrl.userInteractionEnabled = YES;
    }
    else{
        [self callServerToGetData];
    }
}

-(void)callServerToGetData{
    self.areMoreFilesAvailable = YES;
    self.areMoreSharedFilesAvailable = YES;
    NSURL *url = [[NSURL alloc] initWithString:@"https://gist.github.com/anonymous/4680060/raw/aac6d818e7103edfe721e719b1512f707bcfb478/sample.json"];
    [self populateFromServerWithRequestURLKey:url andJSONRequest:nil andHTTPMethod:@"GET"];
}

#pragma -
#pragma TableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (section == 0) {
        int rowCount = 0;
        if (self.segmentCtrl.selectedSegmentIndex == 0) {
            rowCount = [self.myFilesArray count];
        }
        else{
            rowCount = [self.sharedFilesArray count];
        }
        return rowCount;
    }
    else{
        return 1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float retH = 165.0f;
    if (indexPath.section == 1) {
        retH = 80.0f;
    }
    return retH;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"CustomCell";
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.parentIDLbl.text = @"";
    cell.itemIDLbl.text =@"";
    cell.sharedByLbl.text =@"";
    cell.shareLevelLbl.text =@"";
    cell.userIDLbl.text = @"";
    cell.sizeLbl.text = @"";
    cell.nameLbl.text = @"";
    cell.sharedIDLbl.text = @"";
    cell.isSharedLbl.text = @"";
    cell.statusLbl.text = @"";
    cell.sharedDateLbl.text = @"";
    cell.pathLbl.text = @"";
    cell.pathByIDLbl.text = @"";
    cell.typeLbl.text = @"";
    cell.mimeTypeLbl.text = @"";
    cell.lastUpdatedDateLbl.text = @"";
    cell.lastUpdatedByLbl.text = @"";
    cell.createdDateLbl.text = @"";
    cell.linkLbl.text = @"";
    
    cell.loadMoreLbl.text = @"";
    
    if (indexPath.section == 0) {
        Files *showFile = NULL;
        if (self.segmentCtrl.selectedSegmentIndex == 0) {
            showFile = [self.myFilesArray objectAtIndex:indexPath.row];
        }
        else if (self.segmentCtrl.selectedSegmentIndex == 1){
            showFile = [self.sharedFilesArray objectAtIndex:indexPath.row];
        }
        if (showFile!=NULL) {
            cell.parentIDLbl.text = [NSString stringWithFormat:@"%@",[showFile parentID]] ;
            cell.itemIDLbl.text = [NSString stringWithFormat:@"%@",[showFile itemID]] ;
            cell.sharedByLbl.text = [NSString stringWithFormat:@"%@",[showFile sharedBy]] ;
            cell.shareLevelLbl.text = [NSString stringWithFormat:@"%@",[showFile shareLevel]] ;
            cell.userIDLbl.text = [NSString stringWithFormat:@"%@",[showFile userID]] ;
            cell.sizeLbl.text = [NSString stringWithFormat:@"%@",[showFile fileSize]] ;
            
            cell.nameLbl.text = [showFile name];
            cell.sharedIDLbl.text = [showFile sharedID];
            cell.isSharedLbl.text = [showFile isShared];
            cell.statusLbl.text = [showFile status];
            cell.sharedDateLbl.text = [showFile sharedDate];
            cell.pathLbl.text = [showFile path];
            cell.pathByIDLbl.text = [showFile pathByID];
            cell.typeLbl.text = [showFile fileType];
            cell.mimeTypeLbl.text = [showFile mimeType];
            cell.lastUpdatedDateLbl.text = [showFile lastUpdatedDate];
            cell.lastUpdatedByLbl.text = [showFile lastUpdatedBy];
            cell.createdDateLbl.text = [showFile createdDate];
            
            cell.linkLbl.text = [showFile link];
 
        }
    }
    if (indexPath.section == 1) {
        if ([self.myFilesArray count]>0 || [self.sharedFilesArray count]>0) {
            if (self.segmentCtrl.selectedSegmentIndex == 0) {
                if (self.areMoreFilesAvailable) {
                    cell.loadMoreLbl.text = @"Load More Files";
                }
                else{
                    cell.loadMoreLbl.text = @"All Files Loaded";
                }
            }
            else{
                if (self.areMoreSharedFilesAvailable) {
                    cell.loadMoreLbl.text = @"Load More Files";
                }
                else{
                    cell.loadMoreLbl.text = @"All Files Loaded";
                }
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.filesTableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        UINavigationController *popNavController = [self.storyboard instantiateViewControllerWithIdentifier:@"TableNav"];
        [self presentViewController:popNavController animated:YES completion:nil];
    }
    else if (indexPath.section == 1){
        NSLog(@"Clicked Load More");
        BOOL shouldCallServer = NO;
        if (self.segmentCtrl.selectedSegmentIndex == 0) {
            shouldCallServer = self.areMoreFilesAvailable;
        }
        else{
            shouldCallServer = self.areMoreSharedFilesAvailable;
        }
        if (shouldCallServer) {
            if ([self.myFilesArray count]>0 || [self.sharedFilesArray count]>0) {
                [self.filesTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self callServerToGetData];
            }
        }
    }
}

- (IBAction)segmentCtrlClicked:(id)sender {

    NSLog(@"Selected Segment %d",self.segmentCtrl.selectedSegmentIndex);
    
    if (self.segmentCtrl.selectedSegmentIndex == 0) {
        [self.myFilesArray removeAllObjects];
        [self.filesTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationAutomatic];
        NSLog(@"Calling My Files");
        [self setupFilesTableWithType:@"1"];
    }
    else if (self.segmentCtrl.selectedSegmentIndex == 1){
        [self.sharedFilesArray removeAllObjects];
        [self.filesTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationAutomatic];
        NSLog(@"Calling Shared Files");
        [self setupFilesTableWithType:@"0"];
    }
}

-(void)populateFromServerWithRequestURLKey:(NSURL *)url andJSONRequest:(NSString *)jsonRequest andHTTPMethod:(NSString *)method{

    NSData *requestData = [jsonRequest dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:method];
    [request setHTTPBody:requestData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPShouldUsePipelining:YES];
    
    NSLog(@"Request %@\n Json %@",request,jsonRequest);
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] >0 && error == nil){
             [parser parse:data];
         }
         else if ([data length] == 0 && error == nil){
             NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             NSLog(@"Error = %@", error);
         }
     }];
}

#pragma mark -
#pragma mark SBJsonStreamParserAdapterDelegate methods

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
    [NSException raise:@"unexpected" format:@"Should not get here"];
}

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
 
    NSLog(@"Keys %@",[dict allKeys]);
    GlobalInfo *savedGlobal = NULL;
    NSNumber *revID;
    for (NSString *key in [dict allKeys]) {
        if ([key rangeOfString:@"rev_id"].location!=NSNotFound){
            revID = dict[key];
            savedGlobal = [self globalInfoForEntity:@"GlobalInfo" andRevID:revID];
            if (!savedGlobal) {
                savedGlobal = [NSEntityDescription insertNewObjectForEntityForName:@"GlobalInfo" inManagedObjectContext:[RootDelegate managedObjectContext]];
            }
        }
    }
    for (NSString *saveKey in [dict allKeys]) {
        if ([saveKey rangeOfString:@"last_rev_id"].location!=NSNotFound){
            if((id)dict[@"last_rev_id"]!=[NSNull null]) [savedGlobal setLastRevID:dict[@"last_rev_id"]];
        }
        if ([saveKey rangeOfString:@"availableSpace"].location!=NSNotFound){
            if((id)dict[@"availableSpace"]!=[NSNull null]) [savedGlobal setAvailableSpace:dict[@"availableSpace"]];
        }
        if ([saveKey rangeOfString:@"pendingRequests"].location!=NSNotFound){
            if((id)dict[@"pendingRequests"]!=[NSNull null]) [savedGlobal setPendingRequests:dict[@"pendingRequests"]];
        }
        if ([saveKey rangeOfString:@"mode"].location!=NSNotFound){
            if([dict[@"mode"] length]>0) [savedGlobal setMode:dict[@"mode"]];
        }
        if ([saveKey rangeOfString:@"totalSpace"].location!=NSNotFound){
            if((id)dict[@"totalSpace"]!=[NSNull null]) [savedGlobal setTotalSpace:dict[@"totalSpace"]];
        }
        if ([saveKey rangeOfString:@"usedSpace"].location!=NSNotFound){
            if((id)dict[@"usedSpace"]!=[NSNull null]) [savedGlobal setUsedSpace:dict[@"usedSpace"]];
        }
        
        if ([saveKey rangeOfString:@"my_files"].location!=NSNotFound){
            if (self.segmentCtrl.selectedSegmentIndex == 0) {
                NSArray *serverFilesArray = dict[@"my_files"][@"content"];
                int start = 0,end = 0;
                int initialCheckCount = [serverFilesArray count] - [self.myFilesArray count];

                if ([self.myFilesArray count]>1) {
                    start = [self.myFilesArray count]-1;
                }
                
                NSLog(@"Initial Check Count %d",initialCheckCount);
                if (initialCheckCount<=20) {
                    end = [serverFilesArray count];
                    self.areMoreFilesAvailable = NO;
                    [self.filesTableView reloadData];
                }
                else{
                    end = self.loadCounter;
                }
                
                if ([serverFilesArray count]>[self.myFilesArray count]) {
                    for (int i = start; i<end; i++) {
                        NSDictionary *myFileDict = [serverFilesArray objectAtIndex:i];
                        NSNumber *myFilesNumber = [NSNumber numberWithInt:10];
                        Files *myFileOb = [self isAlreadyAddedFile:@"Files" andMatchDict:myFileDict andType:myFilesNumber];
                        [self createOrUpdateFileWithDict:myFileDict andType:MYFILESTYPE andSavedObject:myFileOb];
                    }
                    self.loadCounter+=20;
                }
                
                NSLog(@"My Files Count %d Local Count %d",[serverFilesArray count],[self.myFilesArray count]);
                self.segmentCtrl.userInteractionEnabled = YES;
            }
        }
        if ([saveKey rangeOfString:@"shared_files"].location!=NSNotFound){
            if (self.segmentCtrl.selectedSegmentIndex == 1) {
                NSArray *serverFilesArray = dict[@"shared_files"][@"content"];
                int start = 0,end = 0;
                int checkCount = [serverFilesArray count] - [self.sharedFilesArray count];
                if ([self.sharedFilesArray count]>1) {
                    start = [self.sharedFilesArray count]-1;
                }

                if (checkCount<=20) {
                    end = checkCount;
                    self.areMoreSharedFilesAvailable = NO;
                    [self.filesTableView reloadData];
                }
                else{
                    end = self.sharedLoadCounter;
                }
                if ([serverFilesArray count]>[self.sharedFilesArray count]) {
                    for (int i = start; i<end; i++) {
                        NSDictionary *sharedFileDict = [serverFilesArray objectAtIndex:i];
                        NSNumber *sharedFileNumber = [NSNumber numberWithInt:20];
                        Files *sharedFileOb = [self isAlreadyAddedFile:@"Files" andMatchDict:sharedFileDict andType:sharedFileNumber];
                        [self createOrUpdateFileWithDict:sharedFileDict andType:SHAREDFILESTYPE andSavedObject:sharedFileOb];
                    }
                    self.sharedLoadCounter+=20;
                }
                self.segmentCtrl.userInteractionEnabled = YES;
            }
        }
    }
}

#pragma mark - 
#pragma mark - Core Data Create

-(void)createOrUpdateFileWithDict:(NSDictionary *)fDict andType:(NSString *)type andSavedObject:(Files *)addedFile{
    if (!addedFile) {
        //NSLog(@"Adding From Server");
        addedFile = [NSEntityDescription insertNewObjectForEntityForName:@"Files" inManagedObjectContext:[RootDelegate managedObjectContext]];
    }
    
    if([fDict[@"status"] length]>0)
        [addedFile setStatus:fDict[@"status"]];
    
    if([fDict[@"is_shared"] length]>0)
        [addedFile setIsShared:fDict[@"is_shared"]];
    
    if([fDict[@"share_id"] length]>0)
        [addedFile setSharedID:fDict[@"share_id"]];
    
    if([fDict[@"name"] length]>0)
        [addedFile setName:fDict[@"name"]];
    
    if([fDict[@"last_updated_by"] length]>0)
        [addedFile setLastUpdatedBy:fDict[@"last_updated_by"]];
    
    if([fDict[@"link"] length]>0)
        [addedFile setLink:fDict[@"link"]];
    
    if([fDict[@"path"] length]>0)
        [addedFile setPath:fDict[@"path"]];
    
    if([fDict[@"path_by_id"] length]>0)
        [addedFile setPathByID:fDict[@"path_by_id"]];
    
    if([fDict[@"mime_type"] length]>0)
        [addedFile setMimeType:fDict[@"mime_type"]];
    
    if([fDict[@"type"] length]>0)
        [addedFile setFileType:fDict[@"type"]];
    
    if([fDict[@"created_date"] length]>0)
        [addedFile setCreatedDate:fDict[@"created_date"]];
    
    if([fDict[@"last_updated_date"] length]>0)
        [addedFile setLastUpdatedDate:fDict[@"last_updated_date"]];
    
    if([fDict[@"shared_date"] length]>0)
        [addedFile setSharedDate:fDict[@"shared_date"]];
    
    if((id)fDict[@"item_id"]!=[NSNull null])
        [addedFile setItemID:fDict[@"item_id"]];
    
    if((id)fDict[@"parent_id"]!=[NSNull null])
        [addedFile setParentID:fDict[@"parent_id"]];
    
    if((id)fDict[@"shared_by"]!=[NSNull null])
        [addedFile setSharedBy:fDict[@"shared_by"]];
    
    NSNumber *sharedLevel;
    if ([type isEqualToString:MYFILESTYPE]) {
        [addedFile setLocalType:[NSNumber numberWithInt:10]];
        if([fDict[@"share_level"] length]>0)
            sharedLevel = [NSNumber numberWithInt:[fDict[@"share_level"] intValue]];
    }
    else if ([type isEqualToString:SHAREDFILESTYPE]){
        [addedFile setLocalType:[NSNumber numberWithInt:20]];
        if((id)fDict[@"shared_by"]!=[NSNull null])
            sharedLevel = fDict[@"share_level"];
    }
        [addedFile setShareLevel:sharedLevel];

    if((id)fDict[@"user_id"]!=[NSNull null])
        [addedFile setUserID:fDict[@"user_id"]];

    if((id)fDict[@"size"]!=[NSNull null])
        [addedFile setFileSize:fDict[@"size"]];


    
    NSError *error = nil;
    if(![[RootDelegate managedObjectContext] save:&error]){
        NSLog(@"Error saving Editions - error:%@",error);
    }
    else{
        if ([type isEqualToString:MYFILESTYPE]) {
            if (![self.myFilesArray containsObject:addedFile]) {
                dispatch_async( dispatch_get_main_queue(), ^{
                    NSIndexPath *myFileIndexPath = [NSIndexPath indexPathForRow:[self.myFilesArray count] inSection:0];
                    [self.myFilesArray addObject:addedFile];
                    [self.filesTableView beginUpdates];
                    [self.filesTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:myFileIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.filesTableView endUpdates];
                });
            }
        }
        if ([type isEqualToString:SHAREDFILESTYPE]){
            if (![self.sharedFilesArray containsObject:addedFile]) {
                
                dispatch_async( dispatch_get_main_queue(), ^{
                    NSIndexPath *myFileIndexPath = [NSIndexPath indexPathForRow:[self.sharedFilesArray count] inSection:0];
                    [self.sharedFilesArray addObject:addedFile];
                    [self.filesTableView beginUpdates];
                    [self.filesTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:myFileIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.filesTableView endUpdates];
                });
            }
        }
    }
}

#pragma mark -
#pragma mark - Core Data Create end

@end

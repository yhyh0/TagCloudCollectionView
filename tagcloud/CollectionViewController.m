//
//  CollectionViewController.m
//  tagcloud
//
//  Created by Yin Hou on 6/24/15.
//  Copyright (c) 2015 Yin Hou. All rights reserved.
//

#import "CollectionViewController.h"

static NSString *KeyR = @"KeyR";

@interface CollectionViewController ()

@property (nonatomic, strong) NSMutableArray *sampleData;

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"Cell";


//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
//    return self;
//}
//

- (instancetype)init {
    self = [super init];
    self.sampleData = @[ @{KeyR:@80}, @{KeyR:@70}, @{KeyR:@70}, @{KeyR:@90}, @{KeyR:@60}, @{KeyR:@100}, @{KeyR:@70} ].mutableCopy;
    while (self.sampleData.count < 80) {
        self.sampleData = [self.sampleData arrayByAddingObjectsFromArray:self.sampleData].mutableCopy;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sampleData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (CGSize)collectionViewLayout:(TagCloudCollectionViewLayout *)layout itemSizeForIndexPath:(NSIndexPath *)indexPath {
    NSNumber *r = self.sampleData[indexPath.item][KeyR];
    return CGSizeMake(r.floatValue, r.floatValue);
}

@end

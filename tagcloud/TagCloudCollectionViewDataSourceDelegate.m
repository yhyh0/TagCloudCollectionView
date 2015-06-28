//
//  CollectionViewController.m
//  tagcloud
//
//  Created by Yin Hou on 6/24/15.
//  Copyright (c) 2015 Yin Hou. All rights reserved.
//

#import "TagCloudCollectionViewDataSourceDelegate.h"

static NSString *KeyR = @"KeyR";

@interface TagCloudCollectionViewDataSourceDelegate ()


@end

@implementation TagCloudCollectionViewDataSourceDelegate

static NSString * const reuseIdentifier = @"Cell";


//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
//    return self;
//}
//

- (instancetype)init {
    self = [super init];
    self.sampleData = @[ @{KeyR:@110}, @{KeyR:@90}, @{KeyR:@105}, @{KeyR:@88}, @{KeyR:@90}, @{KeyR:@100}].mutableCopy;
    return self;
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
    if (indexPath.item % 2 == 1) {
//        cell.hidden = YES;
    }
    
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

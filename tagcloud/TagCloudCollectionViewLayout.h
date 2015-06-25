//
//  TagCloudCollectionViewLayout.h
//  tagcloud
//
//  Created by Yin Hou on 6/25/15.
//  Copyright (c) 2015 Yin Hou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TagCloudCollectionViewLayout;

@protocol TagCloudCollectionViewLayoutDataSource

- (CGSize)collectionViewLayout:(TagCloudCollectionViewLayout *)layout itemSizeForIndexPath:(NSIndexPath *)indexPath;

@end

@interface TagCloudCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, weak) id<TagCloudCollectionViewLayoutDataSource> dataSource;

@end

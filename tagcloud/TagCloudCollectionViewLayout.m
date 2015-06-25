//
//  TagCloudCollectionViewLayout.m
//  tagcloud
//
//  Created by Yin Hou on 6/25/15.
//  Copyright (c) 2015 Yin Hou. All rights reserved.
//

#import "TagCloudCollectionViewLayout.h"

@interface TagCloudCollectionViewLayout ()

@property (nonatomic, strong) NSMutableArray *layoutAttributes;
@property (nonatomic, strong) NSMutableArray *rightEdges, *leftEdges;
@property (nonatomic, assign) CGFloat maxXRight;

@end

@implementation TagCloudCollectionViewLayout

- (void)prepareLayout {
    
    self.layoutAttributes = @[].mutableCopy;
    
    self.rightEdges = @[].mutableCopy;
    for (int i = 0; i < self.collectionView.bounds.size.height; i++) {
        [self.rightEdges addObject:@(0)];
    }
    self.leftEdges = @[].mutableCopy;
    for (int i = 0; i < self.collectionView.bounds.size.height; i++) {
        [self.leftEdges addObject:@(0)];
    }
    
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    CGFloat maxY = self.collectionView.bounds.size.height;
    
    self.maxXRight = .0f;;

    for (NSInteger i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i
                                                    inSection:0];
        CGSize itemSize = [self.dataSource collectionViewLayout:self
                                           itemSizeForIndexPath:indexPath];
        
        if (i % 2) {

        } else {//0, 2, 4
            
            CGPoint itemOrigin = CGPointMake(INFINITY, .0f);
            for (int y = 0; y < (maxY - itemSize.height); y++) {
                
                //Move item left/right
                CGFloat maxEdgeXInItemRange = .0f;
                for (int movingYInItemRange = y; movingYInItemRange < y + itemSize.height; movingYInItemRange++) {
                    CGFloat edgeX = [self.rightEdges[movingYInItemRange] floatValue];
                    if (edgeX > maxEdgeXInItemRange) {
                        maxEdgeXInItemRange = edgeX;
                    }
                }
                if (maxEdgeXInItemRange < itemOrigin.x) {
                    itemOrigin.x = maxEdgeXInItemRange;
                    itemOrigin.y = y;
                }
                
                if (maxEdgeXInItemRange > self.maxXRight) {
                    self.maxXRight = maxEdgeXInItemRange;
                }
            }
            
            CGFloat newX = itemOrigin.x + itemSize.width;
            for (int movingYInItemRange = 0; movingYInItemRange < itemSize.height; movingYInItemRange++) {
                self.rightEdges[(int)ceil(itemOrigin.y) + movingYInItemRange] = @(newX);
            }
            
            if (newX > self.maxXRight) {
                self.maxXRight = newX;
            }
            
            UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            layoutAttribute.frame = CGRectMake(itemOrigin.x, itemOrigin.y, itemSize.width, itemSize.height);
            [self.layoutAttributes addObject:layoutAttribute];
        }
    }
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.maxXRight, self.collectionView.bounds.size.height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutAttributes[indexPath.item];
}

@end

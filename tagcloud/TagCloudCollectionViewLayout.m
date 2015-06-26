//
//  TagCloudCollectionViewLayout.m
//  tagcloud
//
//  Created by Yin Hou on 6/25/15.
//  Copyright (c) 2015 Yin Hou. All rights reserved.
//

#import "TagCloudCollectionViewLayout.h"

static const CGFloat MARGIN = 10.f;

@interface TagCloudCollectionViewLayout ()

@property (nonatomic, strong) NSMutableArray *layoutAttributes;
@property (nonatomic, strong) NSMutableArray *rightEdges, *leftEdges;
@property (nonatomic, assign) CGFloat maxXRight, maxXLeft;

@end

@implementation TagCloudCollectionViewLayout

- (void)setUpInitialEdges {
    int height = (int)ceil(self.collectionView.bounds.size.height);
    self.rightEdges = @[].mutableCopy;
    for (int i = 0; i < height; i++) {
        [self.rightEdges addObject:@(0)];
        
    }
    self.leftEdges = @[].mutableCopy;
    for (int i = 0; i < height; i++) {
        [self.leftEdges addObject:@(0)];
    }
    self.maxXRight = .0f;;
}



- (CGFloat)maxEdgeXWithItemSize:(CGSize)itemSize startingY:(int)startingY edges:(NSArray *)edges{
    CGFloat maxEdgeXInItemRange = .0f;
    for (int movingYInItemRange = startingY; movingYInItemRange < (startingY + itemSize.height + 2 * MARGIN); movingYInItemRange++) {
        CGFloat edgeX = [edges[movingYInItemRange] floatValue];
        if (fabs(edgeX) > fabs(maxEdgeXInItemRange)) {
            maxEdgeXInItemRange = edgeX;
        }
    }
    return maxEdgeXInItemRange;
}

- (void)updateItemCellFrame:(CGRect *)framePointer fittingEdges:(NSArray *)edges{
    CGFloat maxY = self.collectionView.bounds.size.height - framePointer->size.height - 2 * MARGIN;
    for (int y = 0; y < maxY; y++) {
        CGFloat maxEdgeXInItemRange = [self maxEdgeXWithItemSize:framePointer->size startingY:y edges:edges];
        if (framePointer->origin.x < .0f) { //left side
            if (fabs(maxEdgeXInItemRange) < fabs([self maxXForItemFrame:*framePointer])) {
                framePointer->origin.x = maxEdgeXInItemRange - MARGIN - framePointer->size.width;
                framePointer->origin.y = y + MARGIN;
            }
        } else {
            if (maxEdgeXInItemRange < framePointer->origin.x) {
                framePointer->origin.x = maxEdgeXInItemRange + MARGIN;
                framePointer->origin.y = y + MARGIN;
            }
        }

    }
}

- (void)updateEdges:(NSMutableArray *)mutableEdges withNewItemFrame:(CGRect)frame {
    CGFloat newX = [self maxXForItemFrame:frame];
    for (int movingYInItemRange = 0; movingYInItemRange < frame.size.height; movingYInItemRange++) {
        mutableEdges[(int)ceil(frame.origin.y) + movingYInItemRange] = @(newX);
    }
}

- (CGFloat)maxXForItemFrame:(CGRect)frame {
    CGFloat maxX;
    if (frame.origin.x < .0f) {
        maxX = frame.origin.x - frame.size.width;
    } else {
        maxX = frame.origin.x + frame.size.width;
    }
    return maxX;
}

- (void)prepareLayout {
    self.layoutAttributes = @[].mutableCopy;
    [self setUpInitialEdges];
    NSInteger count = [self.collectionView numberOfItemsInSection:0];

    for (NSInteger i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i
                                                    inSection:0];
        CGSize itemSize = [self.dataSource collectionViewLayout:self
                                           itemSizeForIndexPath:indexPath];
        
        if (i % 2) {
            CGRect itemFrame = CGRectMake(-INFINITY, .0f, itemSize.width, itemSize.height);

            [self updateItemCellFrame:&itemFrame fittingEdges:self.leftEdges];
            [self updateEdges:self.leftEdges withNewItemFrame:itemFrame];
            CGFloat newX = itemFrame.origin.x + itemFrame.size.width;
            if (newX > self.maxXLeft) {
                self.maxXLeft = newX;
            }
            
            UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            layoutAttribute.frame = itemFrame;
            [self.layoutAttributes addObject:layoutAttribute];
        } else {//0, 2, 4
            CGRect itemFrame = CGRectMake(INFINITY, .0f, itemSize.width, itemSize.height);

            [self updateItemCellFrame:&itemFrame fittingEdges:self.rightEdges];
            [self updateEdges:self.rightEdges withNewItemFrame:itemFrame];
            CGFloat newX = itemFrame.origin.x + itemFrame.size.width;
            if (newX > self.maxXRight) {
                self.maxXRight = newX;
            }
            
            UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            layoutAttribute.frame = itemFrame;
            [self.layoutAttributes addObject:layoutAttribute];
        }
    }
    
    for (UICollectionViewLayoutAttributes *attributesItem in self.layoutAttributes) {
        CGRect frame = attributesItem.frame;
        frame.origin.x = frame.origin.x + self.collectionViewContentSize.width / 2.f;
        attributesItem.frame = frame;
    }
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.maxXRight + fabs(self.maxXLeft), self.collectionView.bounds.size.height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutAttributes[indexPath.item];
}

@end

//
//  TagCloudCollectionViewLayout.m
//  tagcloud
//
//  Created by Yin Hou on 6/25/15.
//  Copyright (c) 2015 Yin Hou. All rights reserved.
//

#import "TagCloudCollectionViewLayout.h"

static const CGFloat MARGIN = .0f;
static const CGFloat SCROLLING_SLOW_DOWN_RATE = 1/4.f;

@interface TagCloudCollectionViewLayout ()

@property (nonatomic, strong) NSMutableArray *layoutAttributes;
@property (nonatomic, strong) NSMutableArray *shiftedLayoutAttributes;
@property (nonatomic, strong) NSMutableArray *rightEdges, *leftEdges;
@property (nonatomic, assign) CGFloat maxXRight, maxXLeft;

@end

@implementation TagCloudCollectionViewLayout

- (void)prepareLayout {
    [self setUpInitialValuesIfNeeded];
    NSUInteger totalItemCount = [self.collectionView numberOfItemsInSection:0];
    
    NSMutableArray *mutableLayoutAttributes = @[].mutableCopy;
    for (NSInteger i = self.layoutAttributes.count; i < totalItemCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i
                                                    inSection:0];
        CGSize itemSize = [self.dataSource collectionViewLayout:self
                                           itemSizeForIndexPath:indexPath];
        CGRect itemFrame = CGRectMake(i % 2 ? -INFINITY : INFINITY, .0f, itemSize.width, itemSize.height);
        NSMutableArray *edges = i % 2 ? self.leftEdges : self.rightEdges;
        
        [self updateItemCellFrame:&itemFrame fittingEdges:edges];
        [self updateEdges:edges withNewItemFrame:itemFrame];
        UICollectionViewLayoutAttributes *newAttributes = [self addLayoutAttributesWithIndexPath:indexPath itemFrame:itemFrame];
        [mutableLayoutAttributes addObject:newAttributes];
    }
    [self makeShiftedLayoutAttributes];
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.maxXRight + fabs(self.maxXLeft), self.collectionView.bounds.size.height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.shiftedLayoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.shiftedLayoutAttributes[indexPath.item];
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGPoint current = self.collectionView.contentOffset;
    CGFloat distance = fabs(fabs(proposedContentOffset.x) - fabs(current.x));
    distance = distance * SCROLLING_SLOW_DOWN_RATE;
    
    if (proposedContentOffset.x < current.x) {
        current.x -= distance;
    } else {
        current.x += distance;
    }
    return current;
}

#pragma mark -
#pragma mark Helpers

- (void)setUpInitialValuesIfNeeded {
    self.layoutAttributes = self.layoutAttributes ?: @[].mutableCopy;

    int height = (int)ceil(self.collectionView.bounds.size.height);
    if (!self.rightEdges) {
        self.rightEdges = @[].mutableCopy;
        for (int i = 0; i < height; i++) {
            [self.rightEdges addObject:@(0)];
        }
    }
    if (!self.leftEdges) {
        self.leftEdges = @[].mutableCopy;
        for (int i = 0; i < height; i++) {
            [self.leftEdges addObject:@(0)];
        }
    }
}

- (CGFloat)maxEdgeXInItemRangeWithItemSize:(CGSize)itemSize startingY:(int)startingY edges:(NSArray *)edges endingY:(CGFloat *)endingY {
    CGFloat maxEdgeXInItemRange = .0f;
    for (int movingY = startingY; movingY < (startingY + itemSize.height + 2 * MARGIN); movingY++) {
        CGFloat edgeX = [edges[movingY] floatValue];
        if (fabs(edgeX) > fabs(maxEdgeXInItemRange)) {
            maxEdgeXInItemRange = edgeX;
            *endingY = movingY;
        }
    }
    return maxEdgeXInItemRange;
}

- (void)updateItemCellFrame:(CGRect *)framePointer fittingEdges:(NSArray *)edges{
    CGFloat maxY = self.collectionView.bounds.size.height - framePointer->size.height - 2 * MARGIN;
    for (int y = 0; y < maxY; y++) {
        CGFloat yWithMaxXEdge;
        
        CGFloat maxEdgeXInItemRange = [self maxEdgeXInItemRangeWithItemSize:framePointer->size startingY:y edges:edges endingY:&yWithMaxXEdge];
        CGRect newFrame = *framePointer;
        CGRect *newFramePointer = &newFrame;
        newFrame.origin.y = y;
        
        if (framePointer->origin.x < .0f) { //left side
            CGFloat bestGuessItemOriginX = maxEdgeXInItemRange + [self circleEdgeDistanceAtY:yWithMaxXEdge withItemFrame:*framePointer];
            if (bestGuessItemOriginX > -framePointer->size.width) {
                bestGuessItemOriginX = -framePointer->size.width;
            }
            newFramePointer->origin.x = bestGuessItemOriginX;
            for (int movingY = y + MARGIN; movingY < (y + newFramePointer->size.height + 2 * MARGIN); movingY++) {
                CGFloat edgeX = [edges[movingY] floatValue];
                CGFloat circleEdgeDistance = [self circleEdgeDistanceAtY:movingY withItemFrame:*newFramePointer];
                
                CGFloat currentItemEdgeX = newFramePointer->origin.x < .0f ? newFramePointer->origin.x + newFramePointer->size.width - circleEdgeDistance : newFramePointer->origin.x + circleEdgeDistance;
                
                if (fabs(edgeX) > fabs(currentItemEdgeX)) {
                    if (newFramePointer->origin.x < .0f) {
                        newFramePointer->origin.x = edgeX + circleEdgeDistance - newFramePointer->size.width;
                    } else {
                        newFramePointer->origin.x = edgeX - circleEdgeDistance;
                    }
                    newFramePointer->origin.y = y + MARGIN;
                }
            }
            
            if (y == 0 || newFrame.origin.x > framePointer->origin.x) {
                framePointer->origin.x = newFrame.origin.x;
                framePointer->origin.y = newFrame.origin.y;
            }
        } else {
            CGFloat bestGuessItemOriginX = maxEdgeXInItemRange - [self circleEdgeDistanceAtY:yWithMaxXEdge withItemFrame:*framePointer];
            if (bestGuessItemOriginX < .0f) {
                bestGuessItemOriginX = .0f;
            }
            newFramePointer->origin.x = bestGuessItemOriginX;
            for (int movingY = y + MARGIN; movingY < (y + newFramePointer->size.height + 2 * MARGIN); movingY++) {
                CGFloat edgeX = [edges[movingY] floatValue];
                CGFloat circleEdgeDistance = [self circleEdgeDistanceAtY:movingY withItemFrame:*newFramePointer];
                
                CGFloat currentItemEdgeX = newFramePointer->origin.x < .0f ? newFramePointer->origin.x + newFramePointer->size.width - circleEdgeDistance : newFramePointer->origin.x + circleEdgeDistance;
                
                if (fabs(edgeX) > fabs(currentItemEdgeX)) {
                    if (newFramePointer->origin.x < .0f) {
                        newFramePointer->origin.x = edgeX + circleEdgeDistance - newFramePointer->size.width;
                    } else {
                        newFramePointer->origin.x = edgeX - circleEdgeDistance;
                    }
                    newFramePointer->origin.y = y + MARGIN;
                }
            }
            
            if (y == 0 || newFrame.origin.x < framePointer->origin.x) {
                framePointer->origin.x = newFrame.origin.x;
                framePointer->origin.y = newFrame.origin.y;
            }
        }
    }
}

- (CGFloat)circleEdgeDistanceAtY:(CGFloat)y withItemFrame:(CGRect)itemFrame {
    CGFloat r = itemFrame.size.width / 2.f;
    CGFloat r_2 = pow(r, 2);
    CGFloat yWithInItem = y - itemFrame.origin.y;
    CGFloat shortEdge;
    if (y > r) {
        shortEdge = yWithInItem - r;
    } else {
        shortEdge = r - yWithInItem;
    }
    CGFloat xWithInItem = r - sqrt(r_2 - pow(shortEdge, 2));
    return xWithInItem;
}

- (void)updateEdges:(NSMutableArray *)mutableEdges withNewItemFrame:(CGRect)frame {
    for (int movingYInItemRange = 0; movingYInItemRange < frame.size.height; movingYInItemRange++) {
        int actualY = (int)ceil(frame.origin.y) + movingYInItemRange;
        CGFloat maxX;
        if (frame.origin.x < .0f) {
            maxX = frame.origin.x + [self circleEdgeDistanceAtY:actualY withItemFrame:frame];
        } else {
            maxX = frame.origin.x + frame.size.width - [self circleEdgeDistanceAtY:actualY withItemFrame:frame];
        }
        mutableEdges[actualY] = @(maxX);
    }
    [self updateMaxEdgesWithItemFrame:frame];
}

- (CGFloat)maxXForItemFrame:(CGRect)frame {
    CGFloat maxX;
    if (frame.origin.x < .0f) {
        maxX = frame.origin.x;
    } else {
        maxX = frame.origin.x + frame.size.width;
    }
    return maxX;
}

- (void)updateMaxEdgesWithItemFrame:(CGRect)itemFrame {
    CGFloat newX = [self maxXForItemFrame:itemFrame];
    if (newX < .0f) {
        if (newX < self.maxXLeft) {
            self.maxXLeft = newX;
        }
    } else {
        if (newX > self.maxXRight) {
            self.maxXRight = newX;
        }
    }
}

- (UICollectionViewLayoutAttributes *)addLayoutAttributesWithIndexPath:(NSIndexPath *)indexPath itemFrame:(CGRect)itemFrame {
    UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    layoutAttribute.frame = itemFrame;
    [self.layoutAttributes addObject:layoutAttribute];
    return layoutAttribute;
}

- (void)makeShiftedLayoutAttributes {
    self.shiftedLayoutAttributes = @[].mutableCopy;
    for (UICollectionViewLayoutAttributes *attributesItem in self.layoutAttributes) {
        UICollectionViewLayoutAttributes *newAttributes = attributesItem.copy;
        CGRect frame = newAttributes.frame;
        frame.origin.x = frame.origin.x + fabs(self.maxXLeft);
        newAttributes.frame = frame;
        [self.shiftedLayoutAttributes addObject:newAttributes];
    }
}

@end

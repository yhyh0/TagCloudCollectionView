//
//  TagCloudCollectionViewLayout.m
//  tagcloud
//
//  Created by Yin Hou on 6/25/15.
//  Copyright (c) 2015 Yin Hou. All rights reserved.
//

#import "TagCloudCollectionViewLayout.h"

static const CGFloat MARGIN = .0f; //Deprecated. Don't use it, set up margins in your cell views instead.
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
        CGRect itemFrame = CGRectMake(i % 2 ? -.01f : .01f, .0f, itemSize.width, itemSize.height);
        NSMutableArray *edges = i % 2 ? self.leftEdges : self.rightEdges;
        
        [self updateItemCellFrame:&itemFrame fittingEdges:edges];
        [self updateEdgesWithNewItemFrame:itemFrame];
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

- (void)moveNewFrameToAvoidOverlayWithStartingY:(int)y outNewFrame:(CGRect *)newFrame_p edges:(NSArray *)edges {
    for (int movingY = y + MARGIN; movingY < (y + newFrame_p->size.height + 2 * MARGIN); movingY++) {
        CGFloat circleEdgeDistance = [self circleEdgeDistanceAtY:movingY withItemFrame:*newFrame_p];
        
        CGFloat rightCircleEdgeX = newFrame_p->origin.x + newFrame_p->size.width - circleEdgeDistance;
        CGFloat leftCircleEdgeX = newFrame_p->origin.x + circleEdgeDistance;

        CGFloat currentRightEdge = [self.rightEdges[movingY] floatValue];
        CGFloat currentLeftEdge = [self minLeftEdgeXAtY:movingY];
        if (newFrame_p->origin.x < .0f && rightCircleEdgeX > currentLeftEdge) {
            newFrame_p->origin.x = currentLeftEdge - newFrame_p->size.width + circleEdgeDistance;
        } else if (newFrame_p->origin.x >= .0f && leftCircleEdgeX < currentRightEdge) {
            newFrame_p->origin.x = currentRightEdge - circleEdgeDistance;
        }
    }
}

// could be negative, 0, or INFINITY
- (CGFloat)minLeftEdgeXAtY:(int)y {
    CGFloat leftMostEdgeX = INFINITY;
    if ([self.leftEdges[y] floatValue] < .0f) {
        leftMostEdgeX = [self.leftEdges[y] floatValue];
    } else if ([self.rightEdges[y] floatValue] > .0f) {
        leftMostEdgeX = .0f;
    }
    return leftMostEdgeX;
}

- (void)updateItemCellFrame:(CGRect *)framePointer fittingEdges:(NSArray *)edges{
    BOOL invalidPosition = YES;
    CGFloat maxY = self.collectionView.bounds.size.height - framePointer->size.height - 2 * MARGIN;
    
    CGRect currentBestPosition;
    for (int y = 0; y < maxY; y++) {
        CGRect newFrame = *framePointer;
        newFrame.origin.y = y;

        [self moveNewFrameToAvoidOverlayWithStartingY:y outNewFrame:&newFrame edges:edges];

        if (invalidPosition ||
            fabs(newFrame.origin.x) < fabs(currentBestPosition.origin.x)) {
            currentBestPosition = newFrame;
            invalidPosition = NO;
        }
    }
    framePointer->origin.x = currentBestPosition.origin.x;
    framePointer->origin.y = currentBestPosition.origin.y;
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

- (void)updateEdgesWithNewItemFrame:(CGRect)frame {
    for (int movingYInItemRange = 0; movingYInItemRange < frame.size.height; movingYInItemRange++) {
        int actualY = (int)ceil(frame.origin.y) + movingYInItemRange;
        CGFloat circleEdgeDistance = [self circleEdgeDistanceAtY:actualY withItemFrame:frame];

        if (frame.origin.x < .0f) { //left side, possible to across y-axis
            CGFloat leftCircleEdgeX = frame.origin.x + circleEdgeDistance;
            if (leftCircleEdgeX < [self.leftEdges[actualY] floatValue]) {
                self.leftEdges[actualY] = @(leftCircleEdgeX);
                if (leftCircleEdgeX < self.maxXLeft) {
                    self.maxXLeft = leftCircleEdgeX;
                }
            }

        }
        CGFloat rightCircleEdgeX = frame.origin.x + frame.size.width - circleEdgeDistance;
        if (rightCircleEdgeX > [self.rightEdges[actualY] floatValue]) {
            self.rightEdges[actualY] = @(rightCircleEdgeX);
            if (rightCircleEdgeX > self.maxXRight) {
                self.maxXRight = rightCircleEdgeX;
            }
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

//
//  CollectionViewController.h
//  tagcloud
//
//  Created by Yin Hou on 6/24/15.
//  Copyright (c) 2015 Yin Hou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagCloudCollectionViewLayout.h"

@interface CollectionViewController : UICollectionViewController
<TagCloudCollectionViewLayoutDataSource>

@end

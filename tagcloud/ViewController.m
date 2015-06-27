//
//  ViewController.m
//  tagcloud
//
//  Created by Yin Hou on 6/24/15.
//  Copyright (c) 2015 Yin Hou. All rights reserved.
//

#import "ViewController.h"
#import "TagCloudCollectionViewDataSourceDelegate.h"
#import "TagCloudCollectionViewLayout.h"

@interface ViewController ()

@property (nonatomic, strong) TagCloudCollectionViewDataSourceDelegate *collectionViewControllerDataSourceDalegate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionViewControllerDataSourceDalegate = [[TagCloudCollectionViewDataSourceDelegate alloc] init];
    self.collectionView.delegate = self.collectionViewControllerDataSourceDalegate;
    self.collectionView.dataSource = self.collectionViewControllerDataSourceDalegate;
    
    NSAssert([self.collectionView.collectionViewLayout isKindOfClass:TagCloudCollectionViewLayout.class], nil);
    TagCloudCollectionViewLayout *layout = (TagCloudCollectionViewLayout *)self.collectionView.collectionViewLayout;
    layout.dataSource = self.collectionViewControllerDataSourceDalegate;
    // Do any additional setup after loading the view.
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.collectionView performBatchUpdates:^{
            NSInteger initialCount = self.collectionViewControllerDataSourceDalegate.sampleData.count;
            while (self.collectionViewControllerDataSourceDalegate.sampleData.count < 40) {
                self.collectionViewControllerDataSourceDalegate.sampleData = [self.collectionViewControllerDataSourceDalegate.sampleData arrayByAddingObjectsFromArray:self.collectionViewControllerDataSourceDalegate.sampleData].mutableCopy;
            }
            NSMutableArray *indesPaths = @[].mutableCopy;
            for (NSInteger i = initialCount; i < self.collectionViewControllerDataSourceDalegate.sampleData.count; i++) {
                [indesPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }
            [self.collectionView insertItemsAtIndexPaths:indesPaths.copy];
        } completion:nil];
    });

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

@end

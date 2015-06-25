//
//  ViewController.m
//  tagcloud
//
//  Created by Yin Hou on 6/24/15.
//  Copyright (c) 2015 Yin Hou. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewController.h"
#import "TagCloudCollectionViewLayout.h"

@interface ViewController ()

@property (nonatomic, strong) CollectionViewController *collectionViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionViewController = [[CollectionViewController alloc] init];
    self.collectionView.delegate = self.collectionViewController;
    self.collectionView.dataSource = self.collectionViewController;
    
    NSAssert([self.collectionView.collectionViewLayout isKindOfClass:TagCloudCollectionViewLayout.class], nil);
    TagCloudCollectionViewLayout *layout = (TagCloudCollectionViewLayout *)self.collectionView.collectionViewLayout;
    layout.dataSource = self.collectionViewController;
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

@end

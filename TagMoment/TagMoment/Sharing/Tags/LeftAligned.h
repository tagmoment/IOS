//
//  LeftAligned.h
//  TagMoment
//
//  Created by Tomer Hershkowitz on 3/30/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeftAlignedCollectionViewDelegate <UICollectionViewDelegateFlowLayout>
- (BOOL)shouldBeFirstItemAtIndexPath:(NSIndexPath*)indexPath;
@end


@interface LeftAligned : UICollectionViewLayout
@property (nonatomic, weak) id<LeftAlignedCollectionViewDelegate> delegate;
@end

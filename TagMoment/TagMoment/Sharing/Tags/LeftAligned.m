//
//  LeftAligned.m
//  TagMoment
//
//  Created by Tomer Hershkowitz on 3/30/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

#import "LeftAligned.h"

const NSInteger kMaxCellSpacing = 3;
const NSInteger HorizontalInset = 10.0f;
const NSInteger VerticalInset = 10.0f;
const NSInteger RowsInset = 20.0f;
@interface LeftAligned ()
@property (nonatomic, strong) NSMutableDictionary* framesCache;
@property (nonatomic, strong) NSMutableArray* sizesCache;
@property (nonatomic, assign) CGSize currentContentSize;
@end
@implementation LeftAligned

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSMutableArray* attributesToReturn = [NSMutableArray new];
	
	for (NSUInteger i = 0 ; i< self.framesCache.count; i++)
	{
		CGRect cellFrame = [self rectForIndex:i];
		if(CGRectIntersectsRect(cellFrame, rect))
		{
			NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
			UICollectionViewLayoutAttributes* attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
			
			//set the frame for this attributes object
			attr.frame = cellFrame;
			[attributesToReturn addObject:attr];
		}
	}
	return attributesToReturn;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	return YES;
}
- (void)prepareLayout
{
	[super prepareLayout];
	self.framesCache = [NSMutableDictionary new];
	self.sizesCache = [NSMutableArray new];

	NSUInteger numberOfCells = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
	
	CGFloat width = HorizontalInset*2;
	CGSize currentSize;
	NSIndexPath* indexPath;
	for (NSUInteger i=0; i< numberOfCells; i++)
	{
		indexPath = [NSIndexPath indexPathForItem:i inSection:0];
		currentSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
		NSValue* val = [NSValue valueWithCGSize:currentSize];
		[self.sizesCache addObject:val];
		if (i % 2 == 0)
		{
			width+=currentSize.width;
			if (i != numberOfCells - 1)
			{
				width+=kMaxCellSpacing;
			}
		}
		
		[self frameForIndexPath:indexPath];
		
	}
	
	self.currentContentSize = CGSizeMake(width, 100.0f);

	
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	return nil;
}

- (void)addRectToCache:(CGRect)frameToAdd withIndex:(NSUInteger)index
{
	self.framesCache[@(index)] = [NSValue valueWithCGRect:frameToAdd];
}

- (CGRect)rectForIndex:(NSUInteger)index
{
	id result = self.framesCache[@(index)];
	if (result)
	{
		return [result CGRectValue];
	}
	
	return CGRectZero;
}

- (void)frameForIndexPath:(NSIndexPath*)indexPath
{
	CGSize size;
	CGRect frame;
	if (indexPath.item == 0) { // first item of section
		size = [self.sizesCache[0] CGSizeValue];
		frame = CGRectMake(HorizontalInset, VerticalInset, size.width, size.height);
		
		[self addRectToCache:frame withIndex:indexPath.item];
		return;
	}
	
	if (indexPath.item == 1)
	{
		size = [self.sizesCache[1] CGSizeValue];
		frame = CGRectMake(HorizontalInset, VerticalInset*2 + size.height, size.width, size.height);
		[self addRectToCache:frame withIndex:indexPath.item];
		return;
	}
	
	NSIndexPath* previousIndexPath = [NSIndexPath indexPathForItem:indexPath.item-2 inSection:indexPath.section];
	CGRect previousFrame = [self rectForIndex:previousIndexPath.item];
	CGFloat previousFrameRightPoint = previousFrame.origin.x + previousFrame.size.width + kMaxCellSpacing;
	size = [self.sizesCache[indexPath.item] CGSizeValue];
	CGFloat originY = indexPath.item % 2 == 0 ? VerticalInset : VerticalInset*2 + previousFrame.size.height;
	
	frame = CGRectMake(previousFrameRightPoint, originY, size.width, previousFrame.size.height);

	[self addRectToCache:frame withIndex:indexPath.item];

}

- (CGSize)collectionViewContentSize
{
	return self.currentContentSize;
}
@end

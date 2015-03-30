//
//  LeftAligned.m
//  TagMoment
//
//  Created by Tomer Hershkowitz on 3/30/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

#import "LeftAligned.h"

const NSInteger kMaxCellSpacing = 3;

@implementation LeftAligned

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSArray* attributesToReturn = [super layoutAttributesForElementsInRect:rect];
	for (UICollectionViewLayoutAttributes* attributes in attributesToReturn) {
		if (nil == attributes.representedElementKind) {
			NSIndexPath* indexPath = attributes.indexPath;
			attributes.frame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
		}
	}
	return attributesToReturn;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewLayoutAttributes* currentItemAttributes =
	[super layoutAttributesForItemAtIndexPath:indexPath];
	
	UIEdgeInsets sectionInset = [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout sectionInset];
	
	if (indexPath.item == 0) { // first item of section
		CGRect frame = currentItemAttributes.frame;
		frame.origin.x = sectionInset.left; // first item of the section should always be left aligned
		currentItemAttributes.frame = frame;
		
		return currentItemAttributes;
	}
	
	if (indexPath.item == 1)
	{
		CGRect frame = currentItemAttributes.frame;
		frame.origin.x = sectionInset.left; 
		currentItemAttributes.frame = frame;
		
		return currentItemAttributes;
	}
	
	NSIndexPath* previousIndexPath = [NSIndexPath indexPathForItem:indexPath.item-2 inSection:indexPath.section];
	CGRect previousFrame = [self layoutAttributesForItemAtIndexPath:previousIndexPath].frame;
	CGFloat previousFrameRightPoint = previousFrame.origin.x + previousFrame.size.width + kMaxCellSpacing;
	
	CGRect frame = currentItemAttributes.frame;
	frame.origin.x = previousFrameRightPoint;
	currentItemAttributes.frame = frame;
	
	return currentItemAttributes;
}

@end

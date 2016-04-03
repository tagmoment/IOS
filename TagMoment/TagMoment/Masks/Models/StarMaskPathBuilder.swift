//
//  StarMaskPathBuilder.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 5/19/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class StarMaskPathBuilder
{
	func degree2radian(a:CGFloat)->CGFloat {
		let b = CGFloat(M_PI) * a/180
		return b
	}
	
	func polygonPointArray(sides:Int,x:CGFloat,y:CGFloat,radius:CGFloat,adjustment:CGFloat=0)->[CGPoint] {
		let angle = degree2radian(360/CGFloat(sides))
		let cx = x // x origin
		let cy = y // y origin
		let r  = radius // radius of circle
		var i = sides
		var points = [CGPoint]()
		while points.count <= sides {
			let xpo = cx - r * cos(angle * CGFloat(i)+degree2radian(adjustment))
			let ypo = cy - r * sin(angle * CGFloat(i)+degree2radian(adjustment))
			points.append(CGPoint(x: xpo, y: ypo))
			i -= 1;
		}
		return points
	}
	
	func starPath(x x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int,pointyness:CGFloat) -> CGPathRef {
		let adjustment = 360/sides/2
		let path = CGPathCreateMutable()
		let points = polygonPointArray(sides,x: x,y: y,radius: radius, adjustment: CGFloat(-adjustment/2))
		let cpg = points[0]
		let points2 = polygonPointArray(sides,x: x,y: y,radius: radius*pointyness,adjustment:CGFloat(adjustment/2))
		var i = 0
		CGPathMoveToPoint(path, nil, cpg.x, cpg.y)
		for p in points {
			CGPathAddLineToPoint(path, nil, points2[i].x, points2[i].y)
			CGPathAddLineToPoint(path, nil, p.x, p.y)
			i += 1
		}
		CGPathCloseSubpath(path)
		return path
	}
}

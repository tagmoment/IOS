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
	func degree2radian(_ a:CGFloat)->CGFloat {
		let b = CGFloat(M_PI) * a/180
		return b
	}
	
	func polygonPointArray(_ sides:Int,x:CGFloat,y:CGFloat,radius:CGFloat,adjustment:CGFloat=0)->[CGPoint] {
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
	
	func starPath(x:CGFloat, y:CGFloat, radius:CGFloat, sides:Int,pointyness:CGFloat) -> CGPath {
		let adjustment = 360/sides/2
		let path = CGMutablePath()
		let points = polygonPointArray(sides,x: x,y: y,radius: radius, adjustment: CGFloat(-adjustment/2))
		let cpg = points[0]
		let points2 = polygonPointArray(sides,x: x,y: y,radius: radius*pointyness,adjustment:CGFloat(adjustment/2))
		var i = 0
		path.move(to: cpg)
		for p in points {
			path.addLine(to: points2[i])
			path.addLine(to: p)
			i += 1
		}
		path.closeSubpath()
		return path
	}
}

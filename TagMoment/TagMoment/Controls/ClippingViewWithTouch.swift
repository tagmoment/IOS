
class ClippingViewWithTouch: UIImageView {
	
	override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
		let layer = self.layer.mask as! CAShapeLayer
		return CGPathContainsPoint(layer.path, nil, point, false)
	}
}

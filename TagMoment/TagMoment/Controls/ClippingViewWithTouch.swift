
class ClippingViewWithTouch: UIImageView {
	
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		let layer = self.layer.mask as! CAShapeLayer
		return layer.path!.contains(point);
	}
}

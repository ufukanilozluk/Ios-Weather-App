import Foundation
import UIKit

@IBDesignable class CardView : UIView{
    @IBInspectable var cornerRadius: CGFloat = 5
    @IBInspectable var shadowColor: UIColor? =  UIColor.black
    @IBInspectable var borderColor: UIColor? =  UIColor.black
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 1
    @IBInspectable var shadowOpacity: Float = 0.2
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowOpacity = shadowOpacity
        layer.borderColor = borderColor?.cgColor
    }
}

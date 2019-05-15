import UIKit

class FlashButton:ToggleButton{
    override init(frame: CGRect) {
        super.init(frame: FlashButton.rect)
         backgroundColor = .clear
        self.setImage(#imageLiteral(resourceName: "icons8-flash-off-50").withRenderingMode(.alwaysOriginal), for: .normal)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var rect:CGRect {
        let btnWidth:CGFloat = 30
        let topLeft:CGPoint = {
            let margin:CGFloat = 20
            return CGPoint.init(x: margin, y: margin)
        }()
        let rect = CGRect(x:topLeft.x, y:topLeft.y, width:btnWidth, height:btnWidth)
        return rect
    }

}

import UIKit
class SearchAnimation : NSObject,UIViewControllerAnimatedTransitioning{
    var operation: UINavigationController.Operation?
    var duration: TimeInterval = 0
    var an = 1
    var imageViewTop:UIImageView?
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toview = transitionContext.view(forKey: .to)
        let containerView = transitionContext.containerView
        
        toview?.frame = CGRect(x: 0, y: 0,width: containerView.bounds.width, height: containerView.bounds.height)
        toview?.alpha = 1
        containerView.addSubview(toview!)
        toview?.layer.transform = CATransform3DMakeScale(0.1,0.1, 1)
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            toview?.center = containerView.center
            toview?.layer.transform = CATransform3DMakeScale(1, 1, 1)            }, completion: {finished in
                toview?.center = containerView.center
              //  foview?.center = containerView.center
                transitionContext.completeTransition(true)
                
        }
        )
        
        
    }
    
    
    
    
}

class SearcAnimationPop : SearchAnimation {
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let foview = transitionContext.view(forKey: .from)
        let toview = transitionContext.view(forKey: .to)
        let containerView = transitionContext.containerView
      //  self.imageView.center = view.center
        containerView.frame = CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height)
        toview?.frame = CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height)
        foview?.frame = CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height)
                toview?.alpha = 1
        containerView.addSubview(toview!)
        containerView.addSubview(foview!)
        toview?.layer.transform = CATransform3DMakeScale(1,1, 1)
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
        }, completion: {finished in
            UIView.animate(withDuration: 0.5, delay: 0,  animations: {
                foview?.center = toview!.center
                toview?.center = containerView.center
                foview?.layer.transform = CATransform3DMakeScale(0.1,0.1, 1)
                
            }, completion: {finished in
            toview?.layer.transform = CATransform3DMakeScale(1,1, 1)
            toview?.center = containerView.center
            foview?.center = containerView.center
                transitionContext.completeTransition(true)
                
            })
            
            
        }
        )
        
    }
}

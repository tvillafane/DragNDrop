//
//  ViewController.swift
//  DragNDrop
//
//  Created by Trey Villafane on 3/30/17.
//  Copyright © 2017 Trey Villafane. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    struct ProfileImage {
        var source: String!
        var index: Int!
    }

    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var imageThree: UIImageView!
    @IBOutlet weak var imageFour: UIImageView!
    @IBOutlet weak var imageFive: UIImageView!
    @IBOutlet weak var imageSix: UIImageView!

    var imageViews: [UIImageView] {
        return [imageOne, imageTwo, imageThree, imageFour, imageFive, imageSix]
    }

    var images = ["cat", "trey", "joker", "batman", "itunes", "rick"]
    var imageStructs: [ProfileImage] = []

    var alphaImage: UIImageView!
    var indexToSwapWith = -1
    var originalAlphaIndex = -1

    var toggleRadius: CGFloat = 40.0

    override func viewDidLoad() {
        super.viewDidLoad()

        for index in 0..<images.count {
            let str = ProfileImage(source: images[index], index: index + 1)
            imageStructs.append(str)
        }

        configureImageViews()
        renderImages()
    }

    func configureImageViews() {
        for image in imageViews {
            image.isUserInteractionEnabled = true
            let tap = UILongPressGestureRecognizer(target: self, action: #selector(imageHeld(sender:)))
            image.addGestureRecognizer(tap)
        }
    }

    func renderImages() {
        for index in 0..<imageStructs.count {
            imageViews[index].image = UIImage(named: imageStructs[index].source)
            //  this will help perist our data WRT order
            imageStructs[index].index = index + 1
        }
    }

    func imageHeld(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            createAlphaImage(image: sender.view! as! UIImageView)
        } else if sender.state == .ended {
            alphaImageWasDropped(withCenter: sender.location(in: view))
        } else if sender.state == .changed {
            moveAlphaImage(withCenter: sender.location(in: view))
        }
    }

    func createAlphaImage(image: UIImageView) {
        let frame = CGRect(x: image.frame.origin.x + 3.0, y: image.frame.origin.y + 3.0, width: image.frame.width, height: image.frame.height)
        alphaImage = UIImageView(frame: frame)
        alphaImage.alpha = 0.5
        alphaImage.image = image.image
        view.addSubview(alphaImage)
        //  tracking purposes
        originalAlphaIndex = image.tag
    }

    func moveAlphaImage(withCenter center: CGPoint) {
        UIView.animate(withDuration: 0.1, animations: {
            self.alphaImage.center = center
        }) { (someBool) in
            self.doToggleLogic(center)
        }
    }

    func alphaImageWasDropped(withCenter center: CGPoint) {
        UIView.animate(withDuration: 0.4, animations: {
            self.alphaImage.center = self.imageViews[self.originalAlphaIndex].center
        }) { (someBool) in
            self.resetSwapLogic()
        }
    }

    func doToggleLogic(_ alphaImageCenter: CGPoint) {
        for image in imageViews {
            if image.tag != originalAlphaIndex && image.tag != indexToSwapWith && distance(a: alphaImageCenter, b: image.center) < toggleRadius {
                indexToSwapWith = image.tag
                swapImagesForIndicies(indexToSwapWith, originalAlphaIndex)
                originalAlphaIndex = indexToSwapWith
                return
            }
        }
    }

    func distance(a: CGPoint, b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y

        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }

    func swapImagesForIndicies(_ indexOne: Int, _ indexTwo: Int) {
        let temp = imageStructs[indexOne]
        imageStructs[indexOne] = imageStructs[indexTwo]
        imageStructs[indexTwo] = temp
        renderImages()
    }

    func resetSwapLogic() {
        alphaImage.removeFromSuperview()
        alphaImage = nil
        //  reset this stuff
        indexToSwapWith = -1
        originalAlphaIndex = -1
    }
}


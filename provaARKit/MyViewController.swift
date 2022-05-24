//
//  MyViewController.swift
//  provaARKit
//
//  Created by Rosario Galioto on 23/05/22.
//

import UIKit
import ARKit
import RealityKit

class MyViewController: UIViewController, ARSessionDelegate {

    @IBOutlet weak var ARView: ARView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configuration.planeDetection = .horizontal
        ARView.session.run(configuration, options: [])
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func toyClicked(_ sender: Any) {
        print("Plane Button Clicked")
        let plane = try! Entity.loadModel(named: "/toy_biplane")
        let planeAnchor = AnchorEntity(plane: .horizontal)
        planeAnchor.addChild(plane)
        ARView.scene.anchors.append(planeAnchor)
    }

}

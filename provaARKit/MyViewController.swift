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
    private var planeAnchor: AnchorEntity? // riferimento al primo (e unico) piano che riconosciamo
    private var mapPlaneAnchor: [String: UIColor]! // per colorare nello stesso modo i nuovi piani di un'ancora già conosciuta
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapPlaneAnchor = [String: UIColor]()
        // settiamo la sessione AR per dover riconoscere i piani orizzontali (punto 2)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        ARView.session.run(configuration, options: [])
        ARView.session.delegate = self // è questa classe a gestire i metodi per il riconoscimento dei piani
        
        // settiamo una Gesture di Tocco sullo Schermo (per il punto 3), che richiamerà il metodo arViewDidTap definito in self (questa classe)
        self.ARView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(arViewDidTap(_:))))
    }


     // MARK: - 1. Model at Fixed Position
    // posizioniamo il Modello (Entità) nel punto 0,0 della Sessione AR
    @IBAction func toyClicked(_ sender: Any) {
        print("Fender Button Clicked")
        let fender = try! ModelEntity.load(named: "fender_stratocaster") // metodo sincrono che caricherà il Modello, bloccherà per un momento il Main Thread
        let originAnchor = AnchorEntity() // di default Ancora creata sul punto x:0 y:0
        originAnchor.addChild(fender)
        ARView.scene.anchors.append(originAnchor)
    }
    
    // MARK:  - 2. Plane Detection + Model at Center Position
    // per il riconoscimento del Piano usiamo le funzionalità base di ARKit di Delegazione del riconscimento di un Ancora (in questo caso di un Piano), ovvero i metodi da implementare di ARSessionDelegate
    
    // quando viene riconosciuto per la prima volta un piano
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        let anchorID = anchors.first!.identifier.uuidString
        self.mapPlaneAnchor[anchorID] = UIColor.random // assegno un colore random all'ancora
        print("added anchor \(anchorID)")
        guard let arPlaneAnchor = anchors.first as? ARPlaneAnchor else { return } // prendiamo la prima ancora riconosciuta e controlliamo che sia effettivamente un Piano
        showPlaneOver(arPlaneAnchor: arPlaneAnchor, color: self.mapPlaneAnchor[anchorID]!)
    }
    
    // quando lo stesso piano viene ingrandito
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        let anchorID = anchors.first!.identifier.uuidString
        print("updated anchor \(anchorID)")
        guard let arPlaneAnchor = anchors.first as? ARPlaneAnchor else { return } // prendiamo la prima ancora riconosciuta e controlliamo che sia effettivamente un Piano
        showPlaneOver(arPlaneAnchor: arPlaneAnchor, color: self.mapPlaneAnchor[anchorID]!)
    }
    
    
    // creiamo Modelli di Piani da piazzare dove sono stati riconosciuti i piani
    func showPlaneOver(arPlaneAnchor: ARPlaneAnchor, color: UIColor) {
        self.planeAnchor = AnchorEntity(anchor: arPlaneAnchor) // creiamo un'ancora/entità di RealityKit, basandoci sull'ancora di ARKit
        // creiamo il Modello del Piano
        let planeMesh = MeshResource.generatePlane(width: arPlaneAnchor.extent.x, depth: arPlaneAnchor.extent.z)
        let planeMaterial = UnlitMaterial(color: color)
        let planeModel = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
        self.planeAnchor?.addChild(planeModel)
        self.ARView.scene.addAnchor(self.planeAnchor!)
    }
    
    // aggiungiamo l'oggetto nell'ULTIMO piano identificato (ovvero la nostra var. planeAnchor)
    @IBAction func addShoeAtPlaneCenter(_ sender: Any) {
        guard let esistingPlane = self.planeAnchor else {return}
        let shoe = try! ModelEntity.load(named: "PegasusTrail")
        esistingPlane.addChild(shoe) // di default al centro del piano
    }
    
    
    // MARK:  - 3. RayCast
    @objc private func arViewDidTap(_ sender: UITapGestureRecognizer) {
        // andiamo a fare un raycast che parte (from:) dal tocco fatto dall'utente (sender) rispetto all'ARView (in: ARView)
        guard let result = ARView.raycast(from: sender.location(in: ARView), allowing: .existingPlaneGeometry, alignment: .horizontal).first else {return} // prendo il primo punto del RayCast (quello più vicino)
        let arAnchor = ARAnchor(name: "RaycastAnchor", transform: result.worldTransform) // andiamo a creare un'ancora con la posizione del punto restituito
        ARView.session.add(anchor: arAnchor)
        let anchorEntity = AnchorEntity(anchor: arAnchor)
        let planeToy = try! ModelEntity.load(named: "toy_biplane")
        anchorEntity.addChild(planeToy)
        ARView.scene.addAnchor(anchorEntity)
    }
    
}


extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}

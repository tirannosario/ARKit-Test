//
//  ContentView.swift
//  provaARKit
//
//  Created by Rosario Galioto on 23/05/22.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

// usiamo UIKit dentro SwiftUI poichè le lib AR funzionano solo su UIKit.
// quindi ci creiamo un ViewController UIKit separato, così da avere tutti i vantaggi di un file statico (di un file xib) e lo andiamo ad istanziare dentro SwiftUI
struct ARViewContainer: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyViewController
    
    func makeUIViewController(context: Context) -> MyViewController {
       return MyViewController(nibName: "MyViewController", bundle: .main)
    }
    
    func updateUIViewController(_ uiViewController: MyViewController, context: Context) {
        
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

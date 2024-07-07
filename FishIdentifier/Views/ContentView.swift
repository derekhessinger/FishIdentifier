//
//  ContentView.swift
//  FishIdentifier
//
//  Created by Derek Hessinger on 7/7/24.
//

import SwiftUI

struct ContentView: View{
    var body: some View{
        ZStack{
            Color.blue
                .ignoresSafeArea()
            
            Text("Fish Identifier")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}

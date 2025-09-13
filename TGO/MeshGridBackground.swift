//
//  MeshGridBackground.swift
//  TGO
//
//  Created by Brooklyn Daines on 9/9/25.
//

import SwiftUI

struct MeshGridBackground: View {
    @State private var animate = false
    let colors1 = (0..<9).map {_ in [Color.yellow, .blue, .green].randomElement()!}
    let colors2 = (0..<9).map {_ in [Color.green, .blue, .yellow].randomElement()!}
    
    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points:[
                .init(x:0, y:0),   .init(x:0.5, y:0),   .init(x:1, y:0),
                .init(x:0, y:0.5), .init(x:0.5, y:0.5), .init(x:1, y:0.5),
                .init(x:0, y:1),   .init(x:0.5, y:1),   .init(x:1, y:1)
            ],
            colors: animate ? colors1 : colors2
        )
        .onAppear{
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
        .ignoresSafeArea()
    }
}
    

#Preview {
    MeshGridBackground()
}

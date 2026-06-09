    //
    //  Inicio.swift
    //  ArcaContinental
    //
    //  Created by Damaris B on 14/06/25.
    //

//  Inicio.swift
//  ArcaContinental
//
//  Created by Damaris B on 14/06/25.
//

import SwiftUI

struct SplashScreenApp: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var showButton = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                VStack(spacing: 40) {
                    // Tu logo o imagen aquí
                    Image("RutaArcaLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                    
                    // NavigationLink con el diseño del botón
                    if showButton {
                        NavigationLink(destination: Login1()) {
                            HStack(spacing: 12) {
                                Text("Continuar")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                Color(red: 200/255, green: 16/255, blue: 46/255)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .shadow(color: Color.gray.opacity(0.3), radius: 8, x: 0, y: 4)
                            .scaleEffect(showButton ? 1.0 : 0.8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .opacity(showButton ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showButton)
                    }
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                    
                    // Mostrar el botón después de 3 segundos
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                            self.showButton = true
                        }
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}


struct SplashScreenApp_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenApp()
    }
}

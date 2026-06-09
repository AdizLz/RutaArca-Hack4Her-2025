//
//  Login1.swift
//  ArcaContinental
//
//  Created by Damaris B on 14/06/25.
//

import SwiftUI

struct Login1: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Área superior con logo y texto
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo como imagen
                    Image("RutaArcaLogo") // Cambia por el nombre de tu imagen
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 250)
                        .offset(y:40)
                    
                    // Título de bienvenida
                    VStack(spacing: 8) {
                        Text("Bienvenido a")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                        
                        Text("RUTAARCA")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .tracking(1)
                            
                    }
                    
                    // Descripción
                    Text("Con Rutaarca, la solución móvil que te acompaña en cada visita, optimiza tu ruta y asegura el control en cada sucursal.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .lineSpacing(4)
                    
                    Spacer()
                }
                .frame(maxHeight: geometry.size.height * 0.75)
                
                // Botones en la parte inferior
                // Botones lado a lado
                
                HStack(spacing: 20) {
                    // Botón Empleado
                    NavigationLink(destination: Login2()) {
                        Text("Empleado")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color(red: 200/255, green: 16/255, blue: 46/255))
                            )
                    }
                    
                    // Botón Cliente
                    
                    NavigationLink(destination: Cliente()) {
                        Text("Cliente")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color(red: 200/255, green: 16/255, blue: 46/255)
)
                            )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }.navigationBarBackButtonHidden(true)
        }
        .background(Color.white)
        .ignoresSafeArea()
    }
}

// Vista del logo personalizado
struct LogoView: View {
    var body: some View {
        ZStack {
            // Diamante rojo (izquierdo)
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red.opacity(0.8), Color.pink.opacity(0.9)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(45))
                .offset(x: -15, y: 0)
            
            // Diamante marrón (derecho)
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.brown.opacity(0.9), Color.brown]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(45))
                .offset(x: 15, y: 0)
            
            // Línea divisoria roja en el centro
            Rectangle()
                .fill(Color.red)
                .frame(width: 3, height: 30)
                .rotationEffect(.degrees(25))
        }
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// Vista de preview
struct Login1_Previews: PreviewProvider {
    static var previews: some View {
        Login1()
    }
}

// Colores personalizados (extensión opcional)
extension Color {
    static let rutaarcaRed = Color(red: 0.85, green: 0.31, blue: 0.31)
    static let rutaarcaBrown = Color(red: 0.45, green: 0.25, blue: 0.15)
}


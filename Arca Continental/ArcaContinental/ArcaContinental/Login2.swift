import SwiftUI

struct Login2: View {
    @State private var numeroEmpleado: String = ""
    @State private var contrasena: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var shouldNavigateToMain = false
    
    var body: some View {
        VStack(spacing: 50) {
            // Header con título y botón back
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("Empleado")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top,50)
                
                Spacer()
                
                // Espacio invisible para centrar el título
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .opacity(0)
            }
            .padding(.horizontal, 25)
            .padding(.top, 15)
            .padding(.bottom, 40)
            
            // Contenido principal
            VStack(spacing: 0) {
                // Sección Número de empleado
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Numero de empleado")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    
                    // Campo de texto para número
                    HStack(spacing: 15) {
                        Image(systemName: "person.crop.rectangle")
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                            .font(.system(size: 20))
                        
                        TextField("#####", text: $numeroEmpleado)
                            .font(.body)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
                    )
                    .padding(.horizontal, 25)
                }
                .padding(.bottom, 35)
                
                // Sección Contraseña
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Contraseña")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    
                    // Campo de texto para contraseña
                    HStack(spacing: 15) {
                        Image(systemName: "lock")
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                            .font(.system(size: 20))
                        
                        SecureField("Contraseña", text: $contrasena)
                            .font(.body)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
                    )
                    .padding(.horizontal, 25)
                }
                .padding(.bottom, 20)
                
                // Link "Olvidaste la contraseña"
                HStack {
                    Spacer()
                    Button(action: {
                        // Acción para olvidaste contraseña
                        print("Olvidaste la contraseña")
                    }) {
                        Text("Olvidaste la contraseña")
                            .font(.body)
                               .foregroundColor(.blue)
                               .underline(true, color: .blue)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 40)
                
                // Botón Iniciar Sesión (sin NavigationLink)
                Button(action: {
                    print("Iniciar sesión - Empleado: \(numeroEmpleado)")
                    shouldNavigateToMain = true
                }) {
                    Text("Iniciar Sesión")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            RoundedRectangle(cornerRadius: 29)
                                .fill(Color(red: 200/255, green: 16/255, blue: 46/255))
                        )
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 25)
                
                Spacer()
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .ignoresSafeArea(.keyboard)
        // Navegación programática completa (reemplaza toda la vista)
        .fullScreenCover(isPresented: $shouldNavigateToMain) {
            ContentView()
                .navigationBarHidden(true)
        }
    }
}

// Vista de preview
struct Login2_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Login2()
        }
    }
}



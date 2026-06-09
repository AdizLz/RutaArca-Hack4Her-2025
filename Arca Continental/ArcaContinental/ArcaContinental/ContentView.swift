//
//  ContentView.swift
//  ArcaContinental
//
//  Created by Damaris B on 14/06/25.
//

import SwiftUI
import MapKit
import Foundation
import UserNotifications

// MARK: - Enum para los tabs
enum TabSelection: CaseIterable {
    case home
    case calendar
    case task
    case map
    case records
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .calendar: return "Calendario"
        case .task: return "Asistente"
        case .map: return "Mapa"
        case .records: return "FeedBack"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .calendar: return "calendar"
        case .task: return "ellipsis.message.fill"
        case .map: return "map.fill"
        case .records: return "checkmark.seal.text.page"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: TabSelection = .home
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161), // Monterrey
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // Contenido principal que cambia según el tab seleccionado
            Group {
                switch selectedTab {
                case .home:
                    HomeScreenView()
                case .calendar:
                    CalendarScreenView()
                case .task:
                    Asistente()
                case .map:
                    MapScreenView()
                case .records:
                    VisitReportView()
                }
            }
            
            // Bottom Navigation
            BottomNavigation(selectedTab: $selectedTab)
        }
        .background(Color.white)
    }
}

// MARK: - Pantalla Home (VACÍA)
struct HomeScreenView: View {
    @State private var selectedStore = 0
    @State private var chatMessages: [ChatMessage] = [
        ChatMessage(text: "¡Hola! Soy tu asistente virtual conectado con Gemini AI. ¿En qué puedo ayudarte hoy?", isUser: false, timestamp: Date())
    ]
    @State private var messageText = ""
    @State private var isTyping = false
    @State private var currentTime = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let stores = [
        Store(name: "OXXO San Pedro", address: "San Pedro Garza García, NL", coordinate: CLLocationCoordinate2D(latitude: 25.6693, longitude: -100.3099)),
        Store(name: "OXXO Monterrey Centro", address: "Centro, Monterrey, NL", coordinate: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161)),
        Store(name: "OXXO Apodaca", address: "Apodaca, NL", coordinate: CLLocationCoordinate2D(latitude: 25.7781, longitude: -100.1875)),
        Store(name: "OXXO Guadalupe", address: "Guadalupe, NL", coordinate: CLLocationCoordinate2D(latitude: 25.6767, longitude: -100.2583)),
        Store(name: "OXXO Santa Catarina", address: "Santa Catarina, NL", coordinate: CLLocationCoordinate2D(latitude: 25.6721, longitude: -100.4593))
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Top Status Bar
                HStack {
                    
                    Spacer()
                    
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .onReceive(timer) { _ in
                    currentTime = Date()
                }
                
                // Header
                ZStack {
                    // Fondo de color solo para el header
                    VStack {
                         // Esto extiende a los lados

                        Spacer()
                    }
                    .padding(.bottom)
                    .ignoresSafeArea(edges: .top)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Hola de nuevo")
                                .font(.body)
                                .font(.largeTitle)
                                .foregroundColor(Color(red: 200/255, green: 16/255, blue: 46/255)) // Cambia color del texto
                            Spacer()
                        }
                        
                        Text("Juanita")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 200/255, green: 16/255, blue: 46/255)) // Cambia color del texto
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.title3)
                            TextField("Search", text: .constant(""))
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.body)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 15)
                        .background(Color.white) // Fondo blanco para el search
                        .cornerRadius(12)
                        
                        Spacer() // Para que el resto del contenido vaya abajo
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10) // Ajusta según necesites
                }
                                
                
                                
                
                // Store Carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<stores.count, id: \.self) { index in
                            StoreCard(
                                store: stores[index],
                                isSelected: selectedStore == index
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedStore = index
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, -30)
                
                // Activity Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Actividad")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    // Map View
                    MapView(coordinate: stores[selectedStore].coordinate, storeName: stores[selectedStore].name)
                        .frame(height: 160)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.top, 12)
                
                // Virtual Assistant Chat Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        NavigationLink(destination: Asistente()) {
                            Text("Asistente Virtual")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary) // Para mantener el color del texto
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: Asistente()) {
                            Text("Chat")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Chat Interface
                    VStack(spacing: 0) {
                        // Chat Messages
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(chatMessages) { message in
                                    ChatBubble(message: message)
                                }
                                
                                if isTyping {
                                    TypingIndicator()
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        }
                        .frame(height: 140)
                        .background(Color.gray.opacity(0.05))
                        
                        // Message Input
                        HStack(spacing: 8) {
                            TextField("Escribe tu mensaje...", text: $messageText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.caption)
                            
                            Button(action: sendMessage) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.white)
                                    .font(.caption)
                                    .frame(width: 28, height: 28)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            .disabled(messageText.isEmpty)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
                    .padding(.horizontal)
                }
                .padding(.top, 12)
                
                Spacer()
                
            }
            .background(Color.gray.opacity(0.05))
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userMessage = ChatMessage(text: messageText, isUser: true, timestamp: Date())
        chatMessages.append(userMessage)
        
        let currentMessage = messageText
        messageText = ""
        
        // Show typing indicator
        isTyping = true
        
        // Call Gemini API
        callGeminiAPI(message: currentMessage)
    }
    
    private func callGeminiAPI(message: String) {
        // Simulate API call to Gemini
        // In real implementation, you would use Google's Gemini API
        let context = "Eres un asistente virtual para OXXO. La sucursal actual es \(stores[selectedStore].name) en \(stores[selectedStore].address). Responde de manera útil y amigable."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isTyping = false
            
            // Simulate intelligent responses based on message content
            let response = generateGeminiResponse(for: message, context: context)
            
            let aiResponse = ChatMessage(
                text: response,
                isUser: false,
                timestamp: Date()
            )
            chatMessages.append(aiResponse)
        }
    }
    
    private func generateGeminiResponse(for message: String, context: String) -> String {
        let lowercaseMessage = message.lowercased()
        
        // Simulate Gemini-like intelligent responses
        if lowercaseMessage.contains("hora") || lowercaseMessage.contains("tiempo") {
            return "La hora actual es \(formatTime(Date())). ¿Hay algo más en lo que pueda ayudarte?"
        } else if lowercaseMessage.contains("ubicación") || lowercaseMessage.contains("dirección") || lowercaseMessage.contains("donde") {
            return "Te encuentras en \(stores[selectedStore].name), ubicado en \(stores[selectedStore].address). ¿Necesitas direcciones a algún lugar específico?"
        } else if lowercaseMessage.contains("producto") || lowercaseMessage.contains("comprar") {
            return "En \(stores[selectedStore].name) puedes encontrar una gran variedad de productos. ¿Buscas algo en particular? Puedo ayudarte a encontrarlo."
        } else if lowercaseMessage.contains("promoción") || lowercaseMessage.contains("oferta") {
            return "¡Excelente! Tenemos varias promociones activas en \(stores[selectedStore].name). ¿Te interesa algún tipo de producto en particular?"
        } else if lowercaseMessage.contains("pago") || lowercaseMessage.contains("tarjeta") {
            return "En OXXO aceptamos efectivo, tarjetas de débito y crédito, y pagos digitales. ¿Necesitas ayuda con algún método de pago específico?"
        } else if lowercaseMessage.contains("horario") || lowercaseMessage.contains("abierto") {
            return "La mayoría de nuestras sucursales OXXO están abiertas las 24 horas. ¿Necesitas confirmar el horario de \(stores[selectedStore].name)?"
        } else {
            // Generic intelligent response
            let responses = [
                "Entiendo tu consulta. Como asistente de OXXO, estoy aquí para ayudarte con información sobre productos, servicios y ubicaciones. ¿Podrías ser más específico?",
                "¡Por supuesto! Estoy conectado con Gemini AI para brindarte la mejor asistencia. ¿En qué aspecto de nuestros servicios en \(stores[selectedStore].name) puedo ayudarte?",
                "Gracias por tu pregunta. Con la tecnología de Gemini, puedo ayudarte con información sobre OXXO, productos, servicios y mucho más. ¿Qué necesitas saber?",
                "¡Perfecto! Estoy aquí para asistirte. ¿Te gustaría saber sobre productos disponibles, servicios, o tienes alguna pregunta específica sobre \(stores[selectedStore].name)?"
            ]
            return responses.randomElement() ?? "¿En qué más puedo ayudarte?"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct Store {
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
}

struct StoreCard: View {
    let store: Store
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(store.name)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            Text(store.address)
                .font(.caption2)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(width: 180)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.red : Color.red.opacity(0.3), lineWidth: isSelected ? 2 : 1)
        )
        .cornerRadius(8)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .shadow(color: isSelected ? .red.opacity(0.2) : .gray.opacity(0.1), radius: isSelected ? 4 : 2, x: 0, y: 1)
    }
}

struct MapView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    let storeName: String
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = storeName
        
        view.removeAnnotations(view.annotations)
        view.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 1500,
            longitudinalMeters: 1500
        )
        view.setRegion(region, animated: true)
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(message.text)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            } else {
                HStack(alignment: .top, spacing: 6) {
                    // AI Avatar
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.white)
                            .font(.caption2)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(message.text)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .foregroundColor(.black)
                            .cornerRadius(12)
                        
                        Text(formatTime(message.timestamp))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TypingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack {
            HStack(alignment: .top, spacing: 6) {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.white)
                        .font(.caption2)
                }
                
                HStack(spacing: 3) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 4, height: 4)
                            .scaleEffect(animating ? 1.0 : 0.5)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: animating
                            )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            Spacer()
        }
        .onAppear {
            animating = true
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(isSelected ? .red : .gray)
            Text(title)
                .font(.caption2)
                .foregroundColor(isSelected ? .red : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}


// MARK: - Pantallas individuales para cada tab








// MARK: - Componentes auxiliares
struct CalendarEventRow: View {
    let title: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(color)
                .frame(width: 4, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                Text(time)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Task Screen Components


// MARK: - Bottom Navigation
struct BottomNavigation: View {
    @Binding var selectedTab: TabSelection
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabSelection.allCases, id: \.self) { tab in
                BottomNavItem(
                    icon: tab.icon,
                    title: tab.title,
                    isSelected: selectedTab == tab,
                    action: {
                        selectedTab = tab
                    }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        
            
    }
}

struct BottomNavItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .red : .gray)
                Text(title)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .red : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

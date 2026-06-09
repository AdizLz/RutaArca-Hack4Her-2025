// ContentView.swift
import SwiftUI
import Charts

struct Cliente: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Inicio")
                }
                .tag(0)
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendario")
                }
                .tag(1)
            
            NotificationsView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Notificaciones")
                }
                .badge(3)
                .tag(2)
            
            FeedBackView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Feedback")
                }
                .tag(3)
        }
        .accentColor(.red)
    }
}

// MARK: - Home View
struct HomeView: View {
    let chartData = [
        FeedbackData(mes: "Ene", feedback: 4.2, ventas: 12000),
        FeedbackData(mes: "Feb", feedback: 4.5, ventas: 13500),
        FeedbackData(mes: "Mar", feedback: 4.3, ventas: 11800),
        FeedbackData(mes: "Abr", feedback: 4.7, ventas: 15200),
        FeedbackData(mes: "May", feedback: 4.6, ventas: 14800),
        FeedbackData(mes: "Jun", feedback: 4.8, ventas: 16500)
    ]
    
    let contactosSugeridos = [
        ContactoSugerido(nombre: "Representante de Ventas", telefono: "+52 81 1234-5678", departamento: "Ventas"),
        ContactoSugerido(nombre: "Soporte Técnico", telefono: "+52 81 8765-4321", departamento: "Soporte"),
        ContactoSugerido(nombre: "Gerente de Cuenta", telefono: "+52 81 2468-1357", departamento: "Cuentas")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Cliente")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text("Panel de gestión")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.red, Color.red.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                    
                    // Gráfica de Resultados Anuales
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Resultados Anuales de Feedback")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        Chart(chartData) { item in
                            LineMark(
                                x: .value("Mes", item.mes),
                                y: .value("Feedback", item.feedback)
                            )
                            .foregroundStyle(.red)
                            .symbol(.circle)
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                        
                        HStack {
                            HStack {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 12, height: 12)
                                Text("Calificación Feedback")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            HStack {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 12, height: 12)
                                Text("Ventas ($)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    
                    // Contactos Sugeridos
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Contactos Sugeridos")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            ForEach(contactosSugeridos, id: \.id) { contacto in
                                HStack {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.red)
                                        .frame(width: 24, height: 24)
                                    
                                    VStack(alignment: .leading) {
                                        Text(contacto.nombre)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(contacto.departamento)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text(contacto.telefono)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    
                    // Asistente Virtual
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "robot.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text("Asistente Virtual")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Text("¿Necesitas ayuda? Pregúntame lo que necesites")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                        }
                        
                        Button("Iniciar Chat") {
                            // Acción del chat
                        }
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.red)
                        .cornerRadius(10)
                        .fontWeight(.medium)
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.red, Color.red.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Calendar View
struct CalendarView: View {
    @State private var selectedDate = Date()
    
    let eventos = [
        Evento(titulo: "Entrega Programada", fecha: "18 de Junio - 10:00 AM", tipo: .entrega),
        Evento(titulo: "Reunión de Seguimiento", fecha: "25 de Junio - 2:00 PM", tipo: .reunion)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Calendario
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Junio 2025")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        // Componente de calendario personalizado
                        CalendarGridView()
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    
                    // Próximos Eventos
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Próximos Eventos")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            ForEach(eventos, id: \.id) { evento in
                                HStack {
                                    Circle()
                                        .fill(evento.tipo == .entrega ? .red : .blue)
                                        .frame(width: 12, height: 12)
                                    
                                    VStack(alignment: .leading) {
                                        Text(evento.titulo)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(evento.fecha)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(evento.tipo == .entrega ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Calendario")
        }
    }
}

// MARK: - Notifications View
struct NotificationsView: View {
    let notifications = [
        NotificationItem(
            id: 1,
            titulo: "Cita programada confirmada",
            mensaje: "Visita técnica mañana a las 10:00 AM",
            tiempo: "30 min",
            unread: true,
            tipo: .appointment
        ),
        NotificationItem(
            id: 2,
            titulo: "Mensaje del asistente virtual",
            mensaje: "Tu consulta sobre inventario ha sido procesada",
            tiempo: "1 hora",
            unread: true,
            tipo: .assistant
        ),
        NotificationItem(
            id: 3,
            titulo: "Mensaje de Carlos (Ventas)",
            mensaje: "Hola, tengo buenas noticias sobre tu pedido",
            tiempo: "2 horas",
            unread: true,
            tipo: .employee
        ),
        NotificationItem(
            id: 4,
            titulo: "Recordatorio de cita",
            mensaje: "Tienes una visita programada en 2 horas",
            tiempo: "3 horas",
            unread: false,
            tipo: .appointment
        ),
        NotificationItem(
            id: 5,
            titulo: "Ana (Soporte Técnico)",
            mensaje: "El problema reportado ya fue solucionado",
            tiempo: "5 horas",
            unread: false,
            tipo: .employee
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Chats Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Chats")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            // Asistente Virtual
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(.red)
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "robot.fill")
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Asistente Virtual")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("Siempre disponible para ayudarte")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Circle()
                                    .fill(.red)
                                    .frame(width: 12, height: 12)
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.red.opacity(0.1), Color.red.opacity(0.2)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10)
                            
                            // Equipo de Trabajo
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(.blue)
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "person.2.fill")
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Equipo de Trabajo")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("Chatea con nuestros especialistas")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("2")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.blue)
                                    .cornerRadius(12)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    
                    // Notificaciones
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Notificaciones")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 1) {
                            ForEach(notifications, id: \.id) { notification in
                                NotificationRowView(notification: notification)
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Mensajes")
        }
    }
}

// MARK: - Feedback View
struct FeedBackView: View {
    @State private var feedbackText = ""
    
    let feedbackData = FeedbackDataModel(
        ventasUltimos30Dias: 15420,
        crecimiento: 12.5,
        productosPopulares: [
            ProductoPopular(nombre: "Producto A", ventas: 45),
            ProductoPopular(nombre: "Producto B", ventas: 38),
            ProductoPopular(nombre: "Producto C", ventas: 32)
        ],
        calificacionPromedio: 4.7
    )
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Métricas principales
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Resultados y Feedback")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            VStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.title)
                                    .foregroundColor(.green)
                                Text("$\(feedbackData.ventasUltimos30Dias, specifier: "%.0f")")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("Ventas últimos 30 días")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                            
                            VStack {
                                Image(systemName: "star.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                Text("\(feedbackData.calificacionPromedio, specifier: "%.1f")")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("Calificación promedio")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        // Crecimiento
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Crecimiento este mes")
                                    .foregroundColor(.white.opacity(0.8))
                                Text("+\(feedbackData.crecimiento, specifier: "%.1f")%")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.green, Color.green.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    
                    // Productos más vendidos
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Productos Más Vendidos")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            ForEach(Array(feedbackData.productosPopulares.enumerated()), id: \.element.id) { index, producto in
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(.red)
                                            .frame(width: 32, height: 32)
                                        Text("\(index + 1)")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text(producto.nombre)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text("\(producto.ventas) ventas")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    
                    // Enviar Feedback
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Enviar Feedback")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        TextEditor(text: $feedbackText)
                            .frame(height: 100)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        
                        Button("Enviar Feedback") {
                            // Acción para enviar feedback
                            feedbackText = ""
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .fontWeight(.medium)
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Feedback")
        }
    }
}

// MARK: - Supporting Views
struct CalendarGridView: View {
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            // Días de la semana
            ForEach(["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"], id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            // Días del mes (simplificado)
            ForEach(1...30, id: \.self) { day in
                ZStack {
                    Circle()
                        .fill(day == 15 ? .red : Color.clear)
                        .frame(width: 32, height: 32)
                    
                    Text("\(day)")
                        .font(.subheadline)
                        .fontWeight(day == 15 ? .bold : .regular)
                        .foregroundColor(day == 15 ? .white : .primary)
                    
                    if [5, 12, 18, 25].contains(day) {
                        VStack {
                            Spacer()
                            Circle()
                                .fill(.red)
                                .frame(width: 4, height: 4)
                        }
                        .frame(width: 32, height: 32)
                    }
                }
                .frame(width: 32, height: 32)
            }
        }
    }
}

struct NotificationRowView: View {
    let notification: NotificationItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconForNotificationType(notification.tipo))
                .foregroundColor(colorForNotificationType(notification.tipo))
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.titulo)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if notification.unread {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                    }
                    
                    Spacer()
                }
                
                Text(notification.mensaje)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(notification.tiempo)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(backgroundColorForNotificationType(notification.tipo))
    }
    
    private func iconForNotificationType(_ type: NotificationType) -> String {
        switch type {
        case .appointment: return "calendar"
        case .assistant: return "robot"
        case .employee: return "person.2"
        }
    }
    
    private func colorForNotificationType(_ type: NotificationType) -> Color {
        switch type {
        case .appointment: return .blue
        case .assistant: return .red
        case .employee: return .green
        }
    }
    
    private func backgroundColorForNotificationType(_ type: NotificationType) -> Color {
        switch type {
        case .appointment: return Color.blue.opacity(0.05)
        case .assistant: return Color.red.opacity(0.05)
        case .employee: return Color.green.opacity(0.05)
        }
    }
}

// MARK: - Data Models
struct FeedbackData: Identifiable {
    let id = UUID()
    let mes: String
    let feedback: Double
    let ventas: Int
}

struct ContactoSugerido: Identifiable {
    let id = UUID()
    let nombre: String
    let telefono: String
    let departamento: String
}

struct Evento: Identifiable {
    let id = UUID()
    let titulo: String
    let fecha: String
    let tipo: TipoEvento
}

enum TipoEvento {
    case entrega, reunion
}

struct NotificationItem: Identifiable {
    let id: Int
    let titulo: String
    let mensaje: String
    let tiempo: String
    let unread: Bool
    let tipo: NotificationType
}

enum NotificationType {
    case appointment, assistant, employee
}

struct FeedbackDataModel {
    let ventasUltimos30Dias: Int
    let crecimiento: Double
    let productosPopulares: [ProductoPopular]
    let calificacionPromedio: Double
}

struct ProductoPopular: Identifiable {
    let id = UUID()
    let nombre: String
    let ventas: Int
}

// MARK: - App Entry Point


struct Cliente_Views: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            MapScreenView()
        }
    }
}

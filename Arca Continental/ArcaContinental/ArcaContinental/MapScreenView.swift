//
//  MapScreenView.swift
//  ArcaContinental
//
//  Created by Damaris B on 15/06/25.
//

//
//  Análisis de Zonas para Papelerías BBVA
//
//  Created on 13/05/25.
//

//
//  Análisis de Zonas para Papelerías BBVA
//
//  Created on 13/05/25.
//

import SwiftUI
import MapKit

// Estructura para los puntos de análisis
struct AnalysisPoint: Identifiable, Hashable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let opportunityLevel: OpportunityLevel
    let name: String
    let details: ZoneDetails
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AnalysisPoint, rhs: AnalysisPoint) -> Bool {
        lhs.id == rhs.id
    }
}

// Niveles de oportunidad
enum OpportunityLevel {
    case high    // Rojo - Alta oportunidad
    case medium  // Amarillo - Oportunidad media
    case low     // Verde - Baja oportunidad
    
    var color: Color {
        switch self {
        case .high: return Color.red
        case .medium: return Color.orange
        case .low: return Color.green
        }
    }
    
    var description: String {
        switch self {
        case .high: return "Alta Prioridad"
        case .medium: return "Media prioridad"
        case .low: return "Baja Prioridad"
        }
    }
}

// Detalles de cada zona
struct ZoneDetails {
    let personDensity: String
    let nearbyCompetitors: Int
    let zoneType: String
    let demandLevel: String
}

struct MapScreenView: View {
    // Colores BBVA
    let bbvaBlue = Color(red: 0.0, green: 0.35, blue: 0.63)
    
    // Estados principales
    @State private var cameraPosition: MapCameraPosition = .region(.monterreyRegion)
    @State private var selectedPoint: AnalysisPoint?
    @State private var showingDetails = false
    @State private var selectedFilter: BusinessFilter = .all
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var showingRoute = false
    
    // Puntos de análisis
    let analysisPoints: [AnalysisPoint] = [
        // Alta oportunidad - cerca de la universidad
        AnalysisPoint(
            coordinate: CLLocationCoordinate2D(latitude: 25.6500276, longitude: -100.2992966),
            opportunityLevel: .high,
            name: "Oxxo Smart Tec",
            details: ZoneDetails(
                personDensity: "Tecnológico, 64700 Monterrey, N.L",
                nearbyCompetitors: 8292938292,
                zoneType: "Blanca Sauceda",
                demandLevel: "0201"
            )
        ),
        
        AnalysisPoint(
            coordinate: CLLocationCoordinate2D(latitude: 25.6693, longitude: -100.3099),
            opportunityLevel: .high,
            name: "OXXO San Pedro",
            details: ZoneDetails(
                personDensity: "Libertad Y Reforma 102, Reforma Ote, San Pedro, 66230 San Pedro Garza García, N.L.",
                nearbyCompetitors: 13467292,
                zoneType: "Ana Sofia",
                demandLevel: "0230"
            )
        ),
        
        // Oportunidad media
        AnalysisPoint(
            coordinate: CLLocationCoordinate2D( latitude: 25.6866, longitude: -100.3161),
            opportunityLevel: .medium,
            name: "OXXO Monterrey Centro",
            details: ZoneDetails(
                personDensity: "Miguel Hidalgo y Costilla 330-Piso 5 suite L501, Torre Centro, Cuauhtemoc, 64000 Monterrey, N.L.",
                nearbyCompetitors: 8281939302,
                zoneType: "Camila John",
                demandLevel: "0231"
            )
        ),
        
        AnalysisPoint(
            coordinate: CLLocationCoordinate2D(latitude: 25.7781, longitude: -100.1875),
            opportunityLevel: .medium,
            name: "OXXO Apodaca",
            details: ZoneDetails(
                personDensity: "C. Alamo 346, Bosques Real I, 66612 Cdad. Apodaca, N.L.",
                nearbyCompetitors: 810567432,
                zoneType: "Kevin Kared",
                demandLevel: "0208"
            )
        ),
        
        // Baja oportunidad
        AnalysisPoint(
            coordinate: CLLocationCoordinate2D(latitude: 25.6767, longitude: -100.2583),
            opportunityLevel: .low,
            name: "OXXO Guadalupe",
            details: ZoneDetails(
                personDensity: "La Silla, Paseo De Las Americas, El Greco 2473-SECT 1, 67173 Guadalupe, N.L.",
                nearbyCompetitors: 8145720200,
                zoneType: "Alex Lazcano",
                demandLevel: "0204"
            )
        ),
        
        AnalysisPoint(
            coordinate: CLLocationCoordinate2D(latitude: 25.6721, longitude: -100.4593),
            opportunityLevel: .low,
            name: "OXXO Santa Catarina",
            details: ZoneDetails(
                personDensity: "Eje Exterior, Av. Alfonso Reyes Y Calle Francisco Villa, Av. Olinca Supermanzana Sector Local 2301 Y 2302 10, Zona Valle Poniente, 66196 Cdad. Santa Catarina, N.L.",
                nearbyCompetitors: 810239483,
                zoneType: "Javier Brayan",
                demandLevel: "0205"
            )
        )
    ]
    
    var filteredPoints: [AnalysisPoint] {
        switch selectedFilter {
        case .all:
            return analysisPoints
        case .papelerias:
            // Pendientes: rojas y amarillas (high y medium)
            return analysisPoints.filter { $0.opportunityLevel == .high || $0.opportunityLevel == .medium }
        case .competencia:
            // Finalizadas: verdes (low)
            return analysisPoints.filter { $0.opportunityLevel == .low }
        }
    }
    
    // Función para calcular y mostrar la ruta
    func calculateRoute(to destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: .tecMonterreyLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {
                print("Error calculando ruta: \(error?.localizedDescription ?? "Error desconocido")")
                return
            }
            
            self.route = route
            self.showingRoute = true
            
            // Ajustar la cámara para mostrar toda la ruta
            let rect = route.polyline.boundingMapRect
            let region = MKCoordinateRegion(rect)
            
            withAnimation(.easeInOut(duration: 1.0)) {
                self.cameraPosition = .region(region)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Mapa ocupando toda la pantalla
                Map(position: $cameraPosition, selection: $selectedPoint) {
                    // Marcador del Tec de Monterrey (referencia principal)
                    Annotation("TEC Monterrey", coordinate: .tecMonterreyLocation) {
                        Image(systemName: "building.columns.fill")
                            .font(.title)
                            .foregroundStyle(bbvaBlue)
                            .background(Circle().fill(.white).shadow(radius: 2))
                    }
                    
                    // Puntos de análisis
                    ForEach(filteredPoints) { point in
                        Annotation(point.name, coordinate: point.coordinate) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(point.opportunityLevel.color)
                                    .frame(width: 24, height: 24)
                                    .shadow(radius: 2)
                                
                                Image(systemName: "triangle.fill")
                                    .font(.caption)
                                    .foregroundStyle(point.opportunityLevel.color)
                                    .rotationEffect(.degrees(180))
                                    .offset(y: -5)
                            }
                        }
                        .tag(point)
                    }
                    
                    // Círculo de influencia (solo mostrar si no hay ruta)
                    if !showingRoute {
                        MapCircle(center: .tecMonterreyLocation, radius: 1000)
                            .foregroundStyle(bbvaBlue.opacity(0.1))
                            .stroke(bbvaBlue.opacity(0.3), lineWidth: 2)
                    }
                    
                    // Mostrar la ruta si existe
                    if let route = route, showingRoute {
                        MapPolyline(route.polyline)
                            .stroke(bbvaBlue, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    }
                }
                .mapStyle(.standard)
                .ignoresSafeArea(.all, edges: .top)
                
                // Controles en la parte inferior con fondo blanco
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        // Botón para limpiar ruta
                        if showingRoute {
                            HStack {
                                Button("Limpiar Ruta") {
                                    withAnimation {
                                        self.route = nil
                                        self.showingRoute = false
                                        self.cameraPosition = .region(.monterreyRegion)
                                    }
                                }
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.red)
                                .cornerRadius(8)
                                
                                Spacer()
                                
                                if let route = route {
                                    VStack(alignment: .trailing) {
                                        Text("Distancia: \(String(format: "%.1f", route.distance / 1000)) km")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text("Tiempo: \(String(format: "%.0f", route.expectedTravelTime / 60)) min")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Leyenda
                        HStack(spacing: 16) {
                            ForEach([OpportunityLevel.high, .medium, .low], id: \.self) { level in
                                LegendItem(level: level)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        
                        // Filtros
                        Picker("Filtro", selection: $selectedFilter) {
                            Text("Todas").tag(BusinessFilter.all)
                            Text("Pendientes").tag(BusinessFilter.papelerias)
                            Text("Finalizadas").tag(BusinessFilter.competencia)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(Color(UIColor.systemBackground))
                }
            }
            .sheet(isPresented: $showingDetails) {
                InfoView(bbvaBlue: bbvaBlue)
            }
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                Button(action: { showingDetails = true }) {
                    Image(systemName: "info.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color(red: 200/255, green: 16/255, blue: 46/255))
                        .background(Circle().fill(Color(UIColor.systemBackground).opacity(0.95)))
                        .shadow(radius: 2)
                }
                .padding(.top, 50)
                .padding(.trailing, 16)
            }
            .safeAreaInset(edge: .bottom) {
                if let selectedPoint {
                    ZoneDetailView(
                        point: selectedPoint,
                        bbvaBlue: bbvaBlue,
                        onClose: {
                            withAnimation {
                                self.selectedPoint = nil
                            }
                        },
                        onRouteRequested: {
                            calculateRoute(to: selectedPoint.coordinate)
                        }
                    )
                }
            }
        }
    }
}

// Elemento de leyenda
struct LegendItem: View {
    let level: OpportunityLevel
    
    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(level.color)
                .frame(width: 10, height: 10)
            Text(level.description)
                .font(.caption)
        }
    }
}

// Vista de detalles de la zona
struct ZoneDetailView: View {
    let point: AnalysisPoint
    let bbvaBlue: Color
    let onClose: () -> Void
    let onRouteRequested: () -> Void
    
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(point.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(red: 200/255, green: 16/255, blue: 46/255))
                    
                    HStack {
                        Circle()
                            .fill(point.opportunityLevel.color)
                            .frame(width: 10, height: 10)
                        Text(point.opportunityLevel.description)
                            .font(.subheadline)
                    }
                }
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                DetailRow(title: "Ubicacion", value: point.details.personDensity, icon: "location.circle.fill")
                DetailRow(title: "Telefono", value: "\(point.details.nearbyCompetitors)", icon: "phone.fill")
                DetailRow(title: "Supervisor:", value: point.details.zoneType, icon: "person.badge.shield.checkmark.fill")
                DetailRow(title: "ID de Tienda", value: point.details.demandLevel, icon: "storefront.circle.fill")
            }
            
            Button("Trazar Ruta") {
                onRouteRequested()
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(red: 200/255, green: 16/255, blue: 46/255))
            .cornerRadius(8)
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.15), radius: 10)
        )
        .padding()
    }
}

// Fila de detalle
struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
            }
            
            Spacer()
        }
    }
}

// Vista de información
struct InfoView: View {
    @Environment(\.dismiss) var dismiss
    let bbvaBlue: Color
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Análisis de Tiendas")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color(red: 200/255, green: 16/255, blue: 46/255))
                
                Text("Esta herramienta te ayuda a identificar las tiendas que se han visitado")
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 16) {
                    InfoSection(color: .red, title: "No visitada hace 3 mes", description: "Tienda necesita ser revisada con urgencia")
                    InfoSection(color: .orange, title: "Visitada hace 2 meses", description: "Tienda que podria ser revisada")
                    InfoSection(color: .green, title: "Visitada hace 1 mes", description: "Tienda que no necesita ser revisada por el momento")
                }
                
                Spacer()
                
                NavigationLink(destination: Asistente()) {
                    Text("Contactar a un asesor Arca")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 200/255, green: 16/255, blue: 46/255))
                        .cornerRadius(8)
                }
            }
            .padding()
            .navigationTitle("Información")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Sección de información
struct InfoSection: View {
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 16, height: 16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

// Filtros de negocio
enum BusinessFilter {
    case all
    case papelerias
    case competencia
}

// Extensiones
extension CLLocationCoordinate2D {
    static var tecMonterreyLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 25.6515, longitude: -100.2895) // Tec de Monterrey
    }
}

extension MKCoordinateRegion {
    static var monterreyRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: .tecMonterreyLocation,  // Centrado en Monterrey
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // Zoom más amplio para ver todos los puntos
        )
    }
    
    init(_ rect: MKMapRect) {
        let topLeft = MKMapPoint(x: rect.minX, y: rect.minY)
        let bottomRight = MKMapPoint(x: rect.maxX, y: rect.maxY)
        
        let center = CLLocationCoordinate2D(
            latitude: (topLeft.coordinate.latitude + bottomRight.coordinate.latitude) / 2,
            longitude: (topLeft.coordinate.longitude + bottomRight.coordinate.longitude) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: abs(topLeft.coordinate.latitude - bottomRight.coordinate.latitude) * 1.3,
            longitudeDelta: abs(topLeft.coordinate.longitude - bottomRight.coordinate.longitude) * 1.3
        )
        
        self.init(center: center, span: span)
    }
}

struct MapaPapelerias_Views: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            MapScreenView()
        }
    }
}

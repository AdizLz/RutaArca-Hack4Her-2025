//
//  CalendarScreenView.swift
//  ArcaContinental
//
//  Created by Damaris B on 15/06/25.
//

import SwiftUI
import Foundation
import UserNotifications

// MARK: - Data Models
struct OxxoStore: Identifiable, Codable {
    let id: Int
    let name: String
    let municipality: String
    let address: String
    let phone: String
    let manager: String
    let description: String
}

struct Visit: Identifiable, Codable {
    let id: UUID
    let storeId: Int
    let time: String
    let notes: String
    let notifications: Bool
    let date: Date
    
    init(id: UUID = UUID(), storeId: Int, time: String, notes: String, notifications: Bool, date: Date) {
        self.id = id
        self.storeId = storeId
        self.time = time
        self.notes = notes
        self.notifications = notifications
        self.date = date
    }
}

// MARK: - Calendar Helper
struct CalendarDay {
    let date: Date
    let isCurrentMonth: Bool
}

// MARK: - Enhanced Notification Manager
class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    @Published var hasPermission = false
    @Published var showingAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkPermission()
    }
    
    func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    
    
    func scheduleNotification(for visit: Visit, store: OxxoStore) {
        guard visit.notifications && hasPermission else { return }
        
        // Cancelar notificación anterior si existe
        cancelNotification(for: visit.id)
        
        // Crear componentes de fecha y hora
        let timeComponents = visit.time.split(separator: ":")
        guard timeComponents.count == 2,
              let hour = Int(timeComponents[0]),
              let minute = Int(timeComponents[1]) else { return }
        
        let calendar = Calendar.current
        var visitComponents = calendar.dateComponents([.year, .month, .day], from: visit.date)
        visitComponents.hour = hour
        visitComponents.minute = minute
        
        guard let visitDateTime = calendar.date(from: visitComponents) else { return }
        
        // Notificación 1 hora antes
        if let reminderTime = calendar.date(byAdding: .hour, value: -1, to: visitDateTime),
           reminderTime > Date() {
            scheduleReminderNotification(visit: visit, store: store, triggerDate: reminderTime, isReminder: true)
        }
        
        // Notificación al momento de la visita
        if visitDateTime > Date() {
            scheduleReminderNotification(visit: visit, store: store, triggerDate: visitDateTime, isReminder: false)
        }
        
        print("✅ Notificaciones programadas para \(store.name)")
    }
    
    private func scheduleReminderNotification(visit: Visit, store: OxxoStore, triggerDate: Date, isReminder: Bool) {
        let content = UNMutableNotificationContent()
        
        if isReminder {
            content.title = "🔔 Recordatorio OXXO"
            content.body = "Visita a \(store.name) en 1 hora (\(visit.time))"
            content.sound = .default
        } else {
            content.title = "🏪 Hora de Visita OXXO"
            content.body = "Es hora de visitar \(store.name)"
            content.sound = .defaultCritical
        }
        
        content.userInfo = [
            "visitId": visit.id.uuidString,
            "storeId": store.id,
            "storeName": store.name,
            "isReminder": isReminder
        ]
        
        let calendar = Calendar.current
        let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let identifier = isReminder ? "\(visit.id.uuidString)_reminder" : "\(visit.id.uuidString)_visit"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error al programar notificación: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelNotification(for visitId: UUID) {
        let identifiers = [
            "\(visitId.uuidString)_reminder",
            "\(visitId.uuidString)_visit"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🗑️ Notificaciones canceladas para visita")
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            self.alertTitle = title
            self.alertMessage = message
            self.showingAlert = true
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // Mostrar notificación cuando la app está en primer plano
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        let storeName = userInfo["storeName"] as? String ?? "Sucursal"
        let isReminder = userInfo["isReminder"] as? Bool ?? false
        
        DispatchQueue.main.async {
            if isReminder {
                self.showAlert(
                    title: "🔔 Recordatorio de Visita",
                    message: "Tienes una visita programada a \(storeName) en 1 hora"
                )
            } else {
                self.showAlert(
                    title: "🏪 Hora de Visita",
                    message: "Es hora de visitar \(storeName)"
                )
            }
        }
        
        // Mostrar la notificación incluso si la app está abierta
        completionHandler([.banner, .sound, .badge])
    }
    
    // Manejar cuando el usuario toca la notificación
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        let storeName = userInfo["storeName"] as? String ?? "Sucursal"
        let isReminder = userInfo["isReminder"] as? Bool ?? false
        
        DispatchQueue.main.async {
            if isReminder {
                self.showAlert(
                    title: "📱 Recordatorio Activado",
                    message: "No olvides tu visita a \(storeName)"
                )
            } else {
                self.showAlert(
                    title: "🚀 ¡Hora de la Visita!",
                    message: "Dirígete a \(storeName)"
                )
            }
        }
        
        completionHandler()
    }
}

// MARK: - Main View
struct CalendarScreenView: View {
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    @State private var showAddModal = false
    @State private var selectedStoreInfo: OxxoStore?
    @State private var visits: [Visit] = []
    @State private var showCancelAlert = false
    @State private var visitToCancel: Visit?
    @StateObject private var notificationManager = NotificationManager.shared
    
    // Sample OXXO stores data
    private let oxxoStores = [
        OxxoStore(id: 1, name: "OXXO Centro", municipality: "Monterrey",
                 address: "Av. Madero 123", phone: "81-1234-5678",
                 manager: "Carlos Rodríguez",
                 description: "Sucursal en el centro histórico, alta afluencia de clientes"),
        OxxoStore(id: 2, name: "OXXO San Pedro", municipality: "San Pedro",
                 address: "Av. Constitución 456", phone: "81-2345-6789",
                 manager: "María González",
                 description: "Zona residencial premium, clientela de alto poder adquisitivo"),
        OxxoStore(id: 3, name: "OXXO Guadalupe", municipality: "Guadalupe",
                 address: "Blvd. Díaz Ordaz 789", phone: "81-3456-7890",
                 manager: "José Martínez",
                 description: "Ubicación estratégica cerca de zona industrial"),
        OxxoStore(id: 4, name: "OXXO Apodaca", municipality: "Apodaca",
                 address: "Carr. Miguel Alemán 321", phone: "81-4567-8901",
                 manager: "Ana López",
                 description: "Sucursal nueva, oportunidades de crecimiento"),
        OxxoStore(id: 5, name: "OXXO Escobedo", municipality: "Escobedo",
                 address: "Av. Raúl Salinas 654", phone: "81-5678-9012",
                 manager: "Luis Hernández",
                 description: "Alto tráfico vehicular, ventas de conveniencia"),
        OxxoStore(id: 6, name: "OXXO Santa Catarina", municipality: "Santa Catarina",
                 address: "Av. Industriales 987", phone: "81-6789-0123",
                 manager: "Patricia Jiménez",
                 description: "Zona industrial, horarios extendidos")
    ]
    
    private let months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
                         "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    
    private let daysOfWeek = ["LU", "MA", "MI", "JU", "VI", "SA", "DO"]
    
    // Computed property para ordenar las sucursales
    private var sortedStores: [OxxoStore] {
        return oxxoStores.sorted { store1, store2 in
            let hasVisit1 = hasStoreVisitInMonth(storeId: store1.id)
            let hasVisit2 = hasStoreVisitInMonth(storeId: store2.id)
            
            if hasVisit1 != hasVisit2 {
                return !hasVisit1 && hasVisit2
            }
            
            return store1.name < store2.name
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Notification Status Bar
                if !notificationManager.hasPermission {
                    notificationPermissionBar
                }
                
                // Calendar Navigation
                calendarNavigationView
                
                // Calendar Grid
                calendarGridView
                
                // Store List
                storeListView
            }
            .background(Color(.systemGray6))
        }
        .sheet(isPresented: $showAddModal) {
            AddVisitModal(
                selectedDate: selectedDate ?? Date(),
                oxxoStores: oxxoStores,
                visits: visits,
                onAddVisit: addVisit,
                onDismiss: { showAddModal = false }
            )
        }
        .sheet(item: $selectedStoreInfo) { store in
            StoreInfoModal(
                store: store,
                hasVisitThisMonth: hasStoreVisitInMonth(storeId: store.id),
                visit: getVisitForStore(storeId: store.id),
                onDismiss: { selectedStoreInfo = nil },
                onCancelVisit: { visit in
                    visitToCancel = visit
                    showCancelAlert = true
                }
            )
        }
        .alert("Cancelar Visita", isPresented: $showCancelAlert) {
            Button("Cancelar Visita", role: .destructive) {
                if let visit = visitToCancel {
                    cancelVisit(visit)
                }
            }
            Button("Mantener Visita", role: .cancel) {}
        } message: {
            if let visit = visitToCancel,
               let store = oxxoStores.first(where: { $0.id == visit.storeId }) {
                Text("¿Estás seguro de cancelar la visita a \(store.name) programada para el \(visit.date.formatted(date: .abbreviated, time: .omitted)) a las \(visit.time)?")
            }
        }
        
    }
    
    // MARK: - Notification Permission Bar
    private var notificationPermissionBar: some View {
        HStack {
            Image(systemName: "bell.slash.fill")
                .foregroundColor(.orange)
            Text("Activa las notificaciones para recibir recordatorios")
                .font(.caption)
                .foregroundColor(.orange)
            Spacer()
           
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.1))
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: "building.2.fill")
                    .foregroundColor(Color(red: 200/255, green: 16/255, blue: 46/255))
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Calendario OXXO")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Gestión de visitas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Notification status indicator
            if notificationManager.hasPermission {
                Image(systemName: "bell.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            }
            
            Button(action: {
                selectedDate = Date()
                showAddModal = true
            }) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color(red: 200/255, green: 16/255, blue: 46/255))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray4)),
            alignment: .bottom
        )
    }
    
    // MARK: - Calendar Navigation View
    private var calendarNavigationView: some View {
        HStack {
            Button(action: { navigateMonth(-1) }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("\(months[Calendar.current.component(.month, from: currentDate) - 1]) \(Calendar.current.component(.year, from: currentDate))")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: { navigateMonth(1) }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray4)),
            alignment: .bottom
        )
    }
    
    // MARK: - Calendar Grid View
    private var calendarGridView: some View {
        VStack(spacing: 0) {
            // Days of week header
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Calendar days grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(getDaysInMonth(), id: \.date) { day in
                    CalendarDayView(
                        day: day,
                        isToday: Calendar.current.isDate(day.date, inSameDayAs: Date()),
                        hasVisits: hasVisits(for: day.date),
                        isSelected: selectedDate != nil && Calendar.current.isDate(day.date, inSameDayAs: selectedDate!),
                        onTap: { handleDateClick(day) }
                    )
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Store List View
    private var storeListView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "building.2")
                    .foregroundColor(.primary)
                Text("Sucursales Disponibles")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.systemGray4)),
                alignment: .top
            )
            
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(sortedStores) { store in
                        StoreRowView(
                            store: store,
                            hasVisitThisMonth: hasStoreVisitInMonth(storeId: store.id),
                            visit: getVisitForStore(storeId: store.id),
                            onTap: { selectedStoreInfo = store },
                            onCancelVisit: { visit in
                                visitToCancel = visit
                                showCancelAlert = true
                            }
                        )
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Helper Methods
    private func getDaysInMonth() -> [CalendarDay] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate),
              let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let adjustedFirstWeekday = (firstWeekday == 1) ? 7 : firstWeekday - 1
        
        var days: [CalendarDay] = []
        
        // Previous month days
        for i in (1..<adjustedFirstWeekday).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: firstDay) {
                days.append(CalendarDay(date: date, isCurrentMonth: false))
            }
        }
        
        // Current month days
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 0
        for day in 1...daysInMonth {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                days.append(CalendarDay(date: date, isCurrentMonth: true))
            }
        }
        
        // Next month days to complete the grid
        let remainingDays = 42 - days.count
        for i in 1...remainingDays {
            if let date = calendar.date(byAdding: .day, value: i, to: monthInterval.end.addingTimeInterval(-1)) {
                days.append(CalendarDay(date: date, isCurrentMonth: false))
            }
        }
        
        return days
    }
    
    private func navigateMonth(_ direction: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: direction, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func handleDateClick(_ day: CalendarDay) {
        guard day.isCurrentMonth else { return }
        selectedDate = day.date
        showAddModal = true
    }
    
    private func hasVisits(for date: Date) -> Bool {
        return visits.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func hasStoreVisitInMonth(storeId: Int) -> Bool {
        let calendar = Calendar.current
        return visits.contains { visit in
            visit.storeId == storeId &&
            calendar.isDate(visit.date, equalTo: currentDate, toGranularity: .month)
        }
    }
    
    private func getVisitForStore(storeId: Int) -> Visit? {
        let calendar = Calendar.current
        return visits.first { visit in
            visit.storeId == storeId &&
            calendar.isDate(visit.date, equalTo: currentDate, toGranularity: .month)
        }
    }
    
    private func addVisit(storeId: Int, time: String, notes: String, notifications: Bool) {
        guard let date = selectedDate else { return }
        let newVisit = Visit(storeId: storeId, time: time, notes: notes, notifications: notifications, date: date)
        visits.append(newVisit)
        
        // Programar notificación si está habilitada
        if notifications, let store = oxxoStores.first(where: { $0.id == storeId }) {
            notificationManager.scheduleNotification(for: newVisit, store: store)
        }
        
        showAddModal = false
    }
    
    private func cancelVisit(_ visit: Visit) {
        visits.removeAll { $0.id == visit.id }
        notificationManager.cancelNotification(for: visit.id)
        visitToCancel = nil
        selectedStoreInfo = nil
    }
    
    private func loadSampleVisits() {
        let calendar = Calendar.current
        let today = Date()
        
        // Sample visits
        if let date1 = calendar.date(byAdding: .day, value: 1, to: today) {
            let visit1 = Visit(storeId: 1, time: "14:30", notes: "Reunión con gerente", notifications: true, date: date1)
            visits.append(visit1)
            
            // Programar notificación para la visita de ejemplo
            if let store = oxxoStores.first(where: { $0.id == 1 }) {
                notificationManager.scheduleNotification(for: visit1, store: store)
            }
        }
        
        if let date2 = calendar.date(byAdding: .day, value: 3, to: today) {
            visits.append(Visit(storeId: 3, time: "10:30", notes: "Capacitación personal", notifications: true, date: date2))
        }
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let day: CalendarDay
    let isToday: Bool
    let hasVisits: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 40, height: 40)
                
                Text("\(Calendar.current.component(.day, from: day.date))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor)
                
                if hasVisits && !isToday {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                        .offset(y: 16)
                }
            }
        }
        .disabled(!day.isCurrentMonth)
    }
    
    private var backgroundColor: Color {
        if isToday {
            return Color(red: 200/255, green: 16/255, blue: 46/255)
        } else if day.isCurrentMonth {
            return Color(.systemGray6)
        } else {
            return Color.clear
        }
    }
    
    private var textColor: Color {
        if isToday {
            return .white
        } else if day.isCurrentMonth {
            return .primary
        } else {
            return .secondary
        }
    }
}

// MARK: - Store Row View
struct StoreRowView: View {
    let store: OxxoStore
    let hasVisitThisMonth: Bool
    let visit: Visit?
    let onTap: () -> Void
    let onCancelVisit: (Visit) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    Text(store.municipality)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    if hasVisitThisMonth {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                    }
                    
                    Button(action: onTap) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                    
                    if let visit = visit {
                        Button(action: { onCancelVisit(visit) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.title3)
                        }
                    }
                }
            }
            
            Text(store.address)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(store.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
            
            if hasVisitThisMonth, let visit = visit {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("✅ Visita programada:")
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                        Spacer()
                        if visit.notifications {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    
                    Text("📅 \(visit.date.formatted(date: .abbreviated, time: .omitted)) a las \(visit.time)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !visit.notes.isEmpty {
                        Text("📝 \(visit.notes)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(hasVisitThisMonth ? Color.green.opacity(0.1) : Color(.systemGray6))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(hasVisitThisMonth ? Color.green.opacity(0.3) : Color(.systemGray4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Add Visit Modal
struct AddVisitModal: View {
    let selectedDate: Date
    let oxxoStores: [OxxoStore]
    let visits: [Visit]
    let onAddVisit: (Int, String, String, Bool) -> Void
    let onDismiss: () -> Void
    
    @State private var selectedStoreId: Int = 0
    @State private var selectedTime = Date()
    @State private var notes = ""
    @State private var notifications = true
    
    private var availableStores: [OxxoStore] {
        let calendar = Calendar.current
        return oxxoStores.filter { store in
            !visits.contains { visit in
                visit.storeId == store.id &&
                calendar.isDate(visit.date, equalTo: selectedDate, toGranularity: .month)
            }
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Date display
                HStack {
                    Text("📅")
                    Text(selectedDate.formatted(date: .complete, time: .omitted))
                                    .font(.headline)
                                    .fontWeight(.medium)
                                                                }
                        .padding()
                                                                .background(Color(.systemGray6))
                                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                                
                                                                // Store selection
                                                                VStack(alignment: .leading, spacing: 12) {
                                                                    Text("🏪 Seleccionar Sucursal")
                                                                        .font(.headline)
                                                                        .fontWeight(.medium)
                                                                    
                                                                    if availableStores.isEmpty {
                                                                        Text("No hay sucursales disponibles para este mes")
                                                                            .font(.subheadline)
                                                                            .foregroundColor(.secondary)
                                                                            .padding()
                                                                            .background(Color(.systemGray6))
                                                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                    } else {
                                                                        Picker("Sucursal", selection: $selectedStoreId) {
                                                                            Text("Seleccionar sucursal...")
                                                                                .foregroundColor(.secondary)
                                                                                .tag(0)
                                                                            
                                                                            ForEach(availableStores) { store in
                                                                                VStack(alignment: .leading) {
                                                                                    Text(store.name)
                                                                                        .font(.subheadline)
                                                                                        .fontWeight(.medium)
                                                                                    Text(store.municipality)
                                                                                        .font(.caption)
                                                                                        .foregroundColor(.secondary)
                                                                                }
                                                                                .tag(store.id)
                                                                            }
                                                                        }
                                                                        .pickerStyle(MenuPickerStyle())
                                                                        .padding()
                                                                        .background(Color(.systemGray6))
                                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                    }
                                                                }
                                                                
                                                                // Time selection
                                                                VStack(alignment: .leading, spacing: 12) {
                                                                    Text("⏰ Hora de la Visita")
                                                                        .font(.headline)
                                                                        .fontWeight(.medium)
                                                                    
                                                                    DatePicker("Hora", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                                                        .labelsHidden()
                                                                        .datePickerStyle(WheelDatePickerStyle())
                                                                        .padding()
                                                                        .background(Color(.systemGray6))
                                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                }
                                                                
                                                                // Notifications toggle
                                                                VStack(alignment: .leading, spacing: 12) {
                                                                    Text("🔔 Notificaciones")
                                                                        .font(.headline)
                                                                        .fontWeight(.medium)
                                                                    
                                                                    Toggle("Recibir recordatorios", isOn: $notifications)
                                                                        .padding()
                                                                        .background(Color(.systemGray6))
                                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                }
                                                                
                                                                // Notes
                                                                VStack(alignment: .leading, spacing: 12) {
                                                                    Text("📝 Notas (Opcional)")
                                                                        .font(.headline)
                                                                        .fontWeight(.medium)
                                                                    
                                                                    TextField("Agregar notas sobre la visita...", text: $notes, axis: .vertical)
                                                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                                                        .lineLimit(3...6)
                                                                }
                                                                
                                                                Spacer()
                                                                
                                                                // Action buttons
                                                                HStack(spacing: 16) {
                                                                    Button("Cancelar") {
                                                                        onDismiss()
                                                                    }
                                                                    .frame(maxWidth: .infinity)
                                                                    .padding()
                                                                    .background(Color(.systemGray5))
                                                                    .foregroundColor(.primary)
                                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                                                    
                                                                    Button("Agendar Visita") {
                                                                        let timeString = timeFormatter.string(from: selectedTime)
                                                                        onAddVisit(selectedStoreId, timeString, notes, notifications)
                                                                    }
                                                                    .frame(maxWidth: .infinity)
                                                                    .padding()
                                                                    .background(selectedStoreId == 0 ? Color(.systemGray4) : Color.blue)
                                                                    .foregroundColor(.white)
                                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                                                    .disabled(selectedStoreId == 0)
                                                                }
                                                            }
                                                            .padding()
                                                            .navigationTitle("Nueva Visita")
                                                            .navigationBarTitleDisplayMode(.inline)
                                                            .navigationBarItems(trailing: Button("Cerrar") { onDismiss() })
                                                        }.navigationBarHidden(true)
                                                        .onAppear {
                                                            if let firstStore = availableStores.first {
                                                                selectedStoreId = firstStore.id
                                                            }
                                                        }
                                                    }
                                                }

                                                // MARK: - Store Info Modal
                                                struct StoreInfoModal: View {
                                                    let store: OxxoStore
                                                    let hasVisitThisMonth: Bool
                                                    let visit: Visit?
                                                    let onDismiss: () -> Void
                                                    let onCancelVisit: (Visit) -> Void
                                                    
                                                    var body: some View {
                                                        NavigationView {
                                                            ScrollView {
                                                                VStack(alignment: .leading, spacing: 20) {
                                                                    // Store header
                                                                    VStack(alignment: .leading, spacing: 12) {
                                                                        HStack {
                                                                            Image(systemName: "building.2.fill")
                                                                                .font(.title)
                                                                                .foregroundColor(Color(red: 200/255, green: 16/255, blue: 46/255))
                                                                            
                                                                            VStack(alignment: .leading) {
                                                                                Text(store.name)
                                                                                    .font(.title2)
                                                                                    .fontWeight(.bold)
                                                                                Text(store.municipality)
                                                                                    .font(.subheadline)
                                                                                    .foregroundColor(Color(red: 200/255, green: 16/255, blue: 46/255))
                                                                            }
                                                                            
                                                                            Spacer()
                                                                            
                                                                            if hasVisitThisMonth {
                                                                                Image(systemName: "checkmark.circle.fill")
                                                                                    .font(.title2)
                                                                                    .foregroundColor(.green)
                                                                            }
                                                                        }
                                                                        
                                                                        Text(store.description)
                                                                            .font(.body)
                                                                            .foregroundColor(.secondary)
                                                                            .italic()
                                                                    }
                                                                    .padding()
                                                                    .background(Color(.systemGray6))
                                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                                                    
                                                                    // Contact info
                                                                    VStack(alignment: .leading, spacing: 16) {
                                                                        Text("📞 Información de Contacto")
                                                                            .font(.headline)
                                                                            .fontWeight(.medium)
                                                                        
                                                                        VStack(alignment: .leading, spacing: 8) {
                                                                            HStack {
                                                                                Image(systemName: "location.fill")
                                                                                    .foregroundColor(.red)
                                                                                Text(store.address)
                                                                                    .font(.subheadline)
                                                                            }
                                                                            
                                                                            HStack {
                                                                                Image(systemName: "phone.fill")
                                                                                    .foregroundColor(.green)
                                                                                Text(store.phone)
                                                                                    .font(.subheadline)
                                                                            }
                                                                            
                                                                            HStack {
                                                                                Image(systemName: "person.fill")
                                                                                    .foregroundColor(.blue)
                                                                                Text("Gerente: \(store.manager)")
                                                                                    .font(.subheadline)
                                                                            }
                                                                        }
                                                                    }
                                                                    .padding()
                                                                    .background(Color(.systemGray6))
                                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                                                    
                                                                    // Visit status
                                                                    VStack(alignment: .leading, spacing: 16) {
                                                                        Text("📅 Estado de Visita")
                                                                            .font(.headline)
                                                                            .fontWeight(.medium)
                                                                        
                                                                        if hasVisitThisMonth, let visit = visit {
                                                                            VStack(alignment: .leading, spacing: 12) {
                                                                                HStack {
                                                                                    Image(systemName: "checkmark.circle.fill")
                                                                                        .foregroundColor(.green)
                                                                                    Text("Visita Programada")
                                                                                        .font(.subheadline)
                                                                                        .fontWeight(.medium)
                                                                                        .foregroundColor(.green)
                                                                                    
                                                                                    Spacer()
                                                                                    
                                                                                    if visit.notifications {
                                                                                        Image(systemName: "bell.fill")
                                                                                            .foregroundColor(.blue)
                                                                                    }
                                                                                }
                                                                                
                                                                                VStack(alignment: .leading, spacing: 8) {
                                                                                    HStack {
                                                                                        Image(systemName: "calendar")
                                                                                            .foregroundColor(.blue)
                                                                                        Text(visit.date.formatted(date: .complete, time: .omitted))
                                                                                            .font(.subheadline)
                                                                                    }
                                                                                    
                                                                                    HStack {
                                                                                        Image(systemName: "clock")
                                                                                            .foregroundColor(.orange)
                                                                                        Text(visit.time)
                                                                                            .font(.subheadline)
                                                                                    }
                                                                                    
                                                                                    if !visit.notes.isEmpty {
                                                                                        HStack(alignment: .top) {
                                                                                            Image(systemName: "note.text")
                                                                                                .foregroundColor(.secondary)
                                                                                            Text(visit.notes)
                                                                                                .font(.subheadline)
                                                                                                .foregroundColor(.secondary)
                                                                                        }
                                                                                    }
                                                                                }
                                                                                
                                                                                Button(action: { onCancelVisit(visit) }) {
                                                                                    HStack {
                                                                                        Image(systemName: "xmark.circle.fill")
                                                                                        Text("Cancelar Visita")
                                                                                    }
                                                                                    .font(.subheadline)
                                                                                    .foregroundColor(.white)
                                                                                    .frame(maxWidth: .infinity)
                                                                                    .padding()
                                                                                    .background(Color.red)
                                                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                                }
                                                                            }
                                                                        } else {
                                                                            HStack {
                                                                                Image(systemName: "calendar.badge.plus")
                                                                                    .foregroundColor(.orange)
                                                                                Text("Sin visita programada este mes")
                                                                                    .font(.subheadline)
                                                                                    .foregroundColor(.secondary)
                                                                            }
                                                                        }
                                                                    }
                                                                    .padding()
                                                                    .background(Color(.systemGray6))
                                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                                                    
                                                                    Spacer()
                                                                }
                                                                .padding()
                                                            }
                                                            .navigationTitle("Información")
                                                            .navigationBarTitleDisplayMode(.inline)
                                                            .navigationBarItems(trailing: Button("Cerrar") { onDismiss() })
                                                        }
                                                    }
                                                }

                                                // MARK: - Preview
                                                struct OxxoCalendarView_Previews: PreviewProvider {
                                                    static var previews: some View {
                                                        CalendarScreenView()
                                                    }
                                                }

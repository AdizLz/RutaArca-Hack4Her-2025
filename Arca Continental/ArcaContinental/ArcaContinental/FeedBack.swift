//
//  VisitReportView.swift
//  VisitReportView
//
//  Created by Asenet on 15/06/25.
//

//
//  VisitReport.swift
//  ArcaContinental
//
//  Created by Damaris B on 15/06/25.
//

//
//  VISITREPORT_D.swift
//  DEMO_RUTAARCA
//
//  Created by Linda De La Garza on 15/06/25.
//

import SwiftUI
import AVFoundation
import Speech
import UIKit

// MARK: - Main Visit Report View
struct VisitReportView: View {
    @StateObject private var viewModel = VisitReportViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    arSectionView
                    audioSectionView
                    qualitySectionView
                    photoSectionView
                    signatureSectionView
                    completeButtonView
                }
                .padding()
            }
            .navigationTitle("Reporte de Visita")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .alert("Estado de la Visita", isPresented: $viewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
        .sheet(isPresented: $viewModel.showCamera) {
            CameraView(capturedImage: $viewModel.capturedPhoto)
        }
        .sheet(isPresented: $viewModel.showSignaturePad) {
            SignaturePadView(
                signature: viewModel.currentSigner == .worker ?
                    $viewModel.workerSignature : $viewModel.ownerSignature,
                signerType: viewModel.currentSigner?.rawValue ?? ""
            )
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Sistema de Reportes")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Complete todos los pasos para finalizar la visita")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack {
                Label(Date().formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                Spacer()
                Label("Establecimiento Demo", systemImage: "location")
            }
            .font(.caption)
            .foregroundColor(Color(red: 200/255, green: 16/255, blue: 46/255))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - AR Section
    private var arSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Inicio de Visita - Realidad Aumentada",
                         icon: "camera.fill",
                         color: .blue)
            
            if !viewModel.visitStarted {
                Button(action: viewModel.startVisitWithAR) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Iniciar Visita con RA")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Visita Iniciada")
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Productos Registrados:")
                            .fontWeight(.semibold)
                        
                        ForEach(viewModel.arProducts, id: \.id) { product in
                            HStack {
                                Text(product.name)
                                    .fontWeight(.medium)
                                Spacer()
                                Text(product.status)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(product.statusColor.opacity(0.2))
                                    .foregroundColor(product.statusColor)
                                    .cornerRadius(4)
                                Text(product.location)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Audio Section
    private var audioSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Notas de Voz",
                         icon: "mic.fill",
                         color: .green)
            
            HStack {
                Button(action: {
                    if viewModel.isRecording {
                        viewModel.stopRecording()
                    } else {
                        viewModel.startRecording()
                    }
                }) {
                    HStack {
                        Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                        Text(viewModel.isRecording ? "Detener" : "Grabar")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(viewModel.isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                if viewModel.isRecording {
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .opacity(viewModel.recordingAnimation ? 1 : 0.3)
                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: viewModel.recordingAnimation)
                        Text("Grabando...")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
            }
            
            if !viewModel.audioNotes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notas Grabadas:")
                        .fontWeight(.semibold)
                    
                    ForEach(Array(viewModel.audioNotes.enumerated()), id: \.offset) { index, note in
                        HStack {
                            Image(systemName: "play.circle")
                                .foregroundColor(.green)
                            Text(note)
                                .font(.caption)
                            Spacer()
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Transcripción:")
                    .fontWeight(.semibold)
                
                TextEditor(text: $viewModel.transcription)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Quality Section
    private var qualitySectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Encuesta de Calidad",
                         icon: "star.fill",
                         color: .yellow)
            
            ForEach(viewModel.products, id: \.self) { product in
                VStack(alignment: .leading, spacing: 8) {
                    Text(product)
                        .fontWeight(.semibold)
                    
                    HStack {
                        ForEach(1..<6) { rating in
                            Button(action: {
                                viewModel.setRating(for: product, rating: rating)
                            }) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(
                                        (viewModel.qualityRatings[product] ?? 0) >= rating
                                            ? .yellow : .gray.opacity(0.3)
                                    )
                                    .font(.title3)
                            }
                        }
                        
                        Spacer()
                        
                        if let rating = viewModel.qualityRatings[product] {
                            Text("\(rating)/5")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                        } else {
                            Text("Sin calificar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Photo Section
    private var photoSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Foto de Comprobante",
                         icon: "camera.fill",
                         color: .purple)
            
            Text("Toma una foto con el dueño del establecimiento como comprobante de la visita.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let photo = viewModel.capturedPhoto {
                VStack(spacing: 12) {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Foto capturada correctamente")
                            .font(.caption)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    
                    Button("Tomar nueva foto") {
                        viewModel.showCamera = true
                    }
                    .foregroundColor(.purple)
                    .fontWeight(.semibold)
                }
            } else {
                Button(action: {
                    viewModel.showCamera = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Tomar Foto")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Signature Section
    private var signatureSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Firmas Digitales",
                         icon: "signature",
                         color: .indigo)
            
            HStack(spacing: 16) {
                // Worker Signature
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("Trabajador")
                            .fontWeight(.semibold)
                    }
                    .font(.caption)
                    
                    ZStack {
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .frame(height: 80)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        if let signature = viewModel.workerSignature {
                            Image(uiImage: signature)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 70)
                        } else {
                            Text("Sin firma")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(viewModel.workerSignature == nil ? "Firmar" : "Modificar") {
                        viewModel.currentSigner = .worker
                        viewModel.showSignaturePad = true
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                
                Spacer()
                
                // Owner Signature
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "building.2.fill")
                        Text("Dueño")
                            .fontWeight(.semibold)
                    }
                    .font(.caption)
                    
                    ZStack {
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .frame(height: 80)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        if let signature = viewModel.ownerSignature {
                            Image(uiImage: signature)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 70)
                        } else {
                            Text("Sin firma")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(viewModel.ownerSignature == nil ? "Firmar" : "Modificar") {
                        viewModel.currentSigner = .owner
                        viewModel.showSignaturePad = true
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.indigo.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Complete Button
    private var completeButtonView: some View {
        Button(action: viewModel.completeVisit) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Completar Visita")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.green, Color.green.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Section Header Helper
    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24, height: 24)
                .background(color)
                .foregroundColor(.white)
                .clipShape(Circle())
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
        }
    }
}

// MARK: - Product Model
struct ARProduct {
    let id: Int
    let name: String
    let status: String
    let location: String
    
    var statusColor: Color {
        switch status {
        case "En stock": return .green
        case "Bajo stock": return .yellow
        case "Agotado": return .red
        default: return .gray
        }
    }
}

// MARK: - Signer Type
enum SignerType: String, CaseIterable {
    case worker = "Trabajador"
    case owner = "Dueño"
}

// MARK: - ViewModel
class VisitReportViewModel: ObservableObject {
    @Published var visitStarted = false
    @Published var arProducts: [ARProduct] = []
    @Published var isRecording = false
    @Published var recordingAnimation = false
    @Published var audioNotes: [String] = []
    @Published var transcription = ""
    @Published var qualityRatings: [String: Int] = [:]
    @Published var capturedPhoto: UIImage?
    @Published var workerSignature: UIImage?
    @Published var ownerSignature: UIImage?
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var showCamera = false
    @Published var showSignaturePad = false
    @Published var currentSigner: SignerType?
    
    let products = [
        "Coca-Cola 600ml",
        "Sprite 600ml",
        "Fanta Naranja 600ml",
        "Agua Ciel 600ml"
    ]
    
    private var recordingTimer: Timer?
    
    func startVisitWithAR() {
        visitStarted = true
        
        // Simular delay de procesamiento de RA
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.arProducts = [
                ARProduct(id: 1, name: "Coca-Cola 600ml", status: "En stock", location: "Refrigerador A"),
                ARProduct(id: 2, name: "Sprite 600ml", status: "Bajo stock", location: "Refrigerador B"),
                ARProduct(id: 3, name: "Fanta Naranja 600ml", status: "En stock", location: "Refrigerador A"),
                ARProduct(id: 4, name: "Agua Ciel 600ml", status: "Agotado", location: "Almacén")
            ]
            self.showAlert(message: "¡Visita iniciada exitosamente!\n\nSe han registrado \(self.arProducts.count) productos mediante Realidad Aumentada.")
        }
    }
    
    func startRecording() {
        isRecording = true
        recordingAnimation = true
        
        // Simular grabación con animación
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            DispatchQueue.main.async {
                self.recordingAnimation.toggle()
            }
        }
        
        transcription += "[Iniciando grabación...] "
    }
    
    func stopRecording() {
        isRecording = false
        recordingAnimation = false
        recordingTimer?.invalidate()
        
        let noteNumber = audioNotes.count + 1
        let timestamp = Date().formatted(date: .omitted, time: .shortened)
        let newNote = "Nota de audio #\(noteNumber) - \(timestamp)"
        audioNotes.append(newNote)
        
        // Simular transcripción automática
        let sampleTranscriptions = [
            "El establecimiento se encuentra en buenas condiciones. Los productos están bien ubicados.",
            "Se observa una buena rotación de inventario. El cliente está satisfecho con el servicio.",
            "El refrigerador funciona correctamente. Se recomienda mantener la temperatura estable.",
            "Excelente presentación de los productos. El establecimiento cumple con los estándares."
        ]
        
        let randomTranscription = sampleTranscriptions.randomElement() ?? "Transcripción no disponible"
        transcription += "\n\n📝 \(newNote):\n\(randomTranscription)"
    }
    
    func setRating(for product: String, rating: Int) {
        qualityRatings[product] = rating
    }
    
    func completeVisit() {
        // Validación paso a paso con mensajes específicos
        guard visitStarted && !arProducts.isEmpty else {
            showAlert(message: "❌ Error: Inicio de Visita\n\nDebe iniciar la visita y registrar productos con Realidad Aumentada antes de continuar.")
            return
        }
        
        guard qualityRatings.count == products.count else {
            let missing = products.count - qualityRatings.count
            showAlert(message: "❌ Error: Encuesta de Calidad\n\nFaltan \(missing) producto(s) por calificar. Complete todas las calificaciones para continuar.")
            return
        }
        
        guard capturedPhoto != nil else {
            showAlert(message: "❌ Error: Foto de Comprobante\n\nDebe tomar la foto de comprobante con el dueño del establecimiento.")
            return
        }
        
        guard workerSignature != nil && ownerSignature != nil else {
            var missing: [String] = []
            if workerSignature == nil { missing.append("Trabajador") }
            if ownerSignature == nil { missing.append("Dueño") }
            showAlert(message: "❌ Error: Firmas Digitales\n\nFaltan las firmas de: \(missing.joined(separator: " y "))")
            return
        }
        
        // Si todo está completo
        let completionData = generateCompletionSummary()
        showAlert(message: "✅ ¡Visita Completada Exitosamente!\n\n\(completionData)")
    }
    
    private func generateCompletionSummary() -> String {
        let avgRating = Double(qualityRatings.values.reduce(0, +)) / Double(qualityRatings.count)
        let ratingEmoji = avgRating >= 4.0 ? "⭐" : avgRating >= 3.0 ? "👍" : "⚠️"
        
        return """
        📊 Resumen de la Visita:
        
        🎯 Productos registrados: \(arProducts.count)
        \(ratingEmoji) Calificación promedio: \(String(format: "%.1f", avgRating))/5
        📷 Foto de comprobante: Capturada
        ✍️ Firmas: Trabajador y Dueño
        🎤 Notas de audio: \(audioNotes.count)
        
        Todos los datos han sido guardados correctamente.
        """
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Camera View (Funcional)
struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        // Verificar disponibilidad de cámara
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraDevice = .rear
            picker.allowsEditing = true
        } else {
            // Fallback a biblioteca de fotos si no hay cámara (simulador)
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            var selectedImage: UIImage?
            
            // Priorizar imagen editada
            if let editedImage = info[.editedImage] as? UIImage {
                selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                selectedImage = originalImage
            }
            
            parent.capturedImage = selectedImage
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Signature Pad View (Mejorado)
struct SignaturePadView: View {
    @Binding var signature: UIImage?
    let signerType: String
    @Environment(\.presentationMode) var presentationMode
    @State private var paths: [Path] = []
    @State private var currentPath = Path()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Firma Digital")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Firma de \(signerType)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Usa tu dedo para firmar en el área de abajo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Área de firma
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                        )
                    
                    if paths.isEmpty && currentPath.isEmpty {
                        Text("Firme aquí")
                            .foregroundColor(.gray.opacity(0.5))
                            .font(.title3)
                    }
                    
                    Canvas { context, size in
                        for path in paths {
                            context.stroke(path, with: .color(.black), lineWidth: 3)
                        }
                        context.stroke(currentPath, with: .color(.black), lineWidth: 3)
                    }
                }
                .frame(height: 250)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let point = value.location
                            if value.translation == .zero {
                                currentPath = Path()
                                currentPath.move(to: point)
                            } else {
                                currentPath.addLine(to: point)
                            }
                        }
                        .onEnded { _ in
                            paths.append(currentPath)
                            currentPath = Path()
                        }
                )
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Botones
                HStack(spacing: 20) {
                    Button(action: clearSignature) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Limpiar")
                        }
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Button(action: saveSignature) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Guardar Firma")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(paths.isEmpty ? Color.gray : Color.green)
                        .cornerRadius(8)
                    }
                    .disabled(paths.isEmpty)
                }
                .padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func clearSignature() {
        paths.removeAll()
        currentPath = Path()
    }
    
    private func saveSignature() {
        let renderer = ImageRenderer(content:
            Canvas { context, size in
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.white))
                for path in paths {
                    context.stroke(path, with: .color(.black), lineWidth: 3)
                }
            }
            .frame(width: 300, height: 200)
        )
        
        if let image = renderer.uiImage {
            signature = image
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Preview Provider
struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        VisitReportView()
    }
}

//
//  Asistente.swift
//  ArcaContinental
//
//  Created by Damaris B on 15/06/25.
//

import SwiftUI
import Foundation

class ChatController: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Reemplaza con tu API key de Google AI Studio
    private let apiKey = Config.geminiKey
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    func sendNewMessage(content: String) {
        let userMessage = Message(content: content, isUser: true)
        self.messages.append(userMessage)
        getBotReply()
    }
    
    func getBotReply() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            errorMessage = "URL inválida"
            isLoading = false
            return
        }
        
        // Obtener solo el último mensaje del usuario para la solicitud
        guard let lastMessage = messages.last, lastMessage.isUser else {
            errorMessage = "Error interno"
            isLoading = false
            return
        }
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "text": lastMessage.content
                        ]
                    ]
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            errorMessage = "Error al crear la solicitud"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Error de red: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No se recibieron datos"
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let candidates = json["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let firstPart = parts.first,
                       let text = firstPart["text"] as? String {
                        
                        self?.messages.append(Message(content: text, isUser: false))
                    } else {
                        // Si hay error en la respuesta, mostrarlo
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let error = json["error"] as? [String: Any],
                           let message = error["message"] as? String {
                            self?.errorMessage = "Error de API: \(message)"
                        } else {
                            self?.errorMessage = "Respuesta inválida de la API"
                        }
                    }
                } catch {
                    self?.errorMessage = "Error al procesar la respuesta: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct Message: Identifiable {
    var id: UUID = .init()
    var content: String
    var isUser: Bool
}

struct Asistente: View {
    @StateObject var chatController: ChatController = .init()
    @State var string: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(chatController.messages) { message in
                    MessageView(message: message)
                        .padding(5)
                }
                
                // Mostrar indicador de carga
                if chatController.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Escribiendo...")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                }
                
                // Mostrar errores
                if let errorMessage = chatController.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.leading)
                }
            }
            
            Divider()
            
            HStack {
                TextField("Escribe tu mensaje...", text: self.$string, axis: .vertical)
                    .padding(5)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .disabled(chatController.isLoading)
                
                Button {
                    guard !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    self.chatController.sendNewMessage(content: string)
                    string = ""
                } label: {
                    Image(systemName: "paperplane")
                        .foregroundColor(chatController.isLoading ? .gray : .blue)
                }
                .disabled(chatController.isLoading || string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle("Chat con Gemini")
        
    }
}

struct MessageView: View {
    var message: Message
    
    var body: some View {
        Group {
            if message.isUser {
                HStack {
                    Spacer()
                    Text(message.content)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .clipShape(Capsule())
                        .textSelection(.enabled)
                }
            } else {
                HStack {
                    Text(message.content)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .textSelection(.enabled)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        Asistente()
    }
}
    

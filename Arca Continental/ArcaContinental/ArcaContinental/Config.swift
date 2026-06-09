// Config.swift
// Lee las API keys desde Secrets.plist (NO subir Secrets.plist a Git)
// Copia Secrets.plist.example → Secrets.plist y llena tu key real.

import Foundation

enum Config {

    private static let secrets: [String: Any] = {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) as? [String: Any]
        else {
            print("⚠️  Config: no se encontró Secrets.plist. Copia Secrets.plist.example → Secrets.plist y llena tu key.")
            return [:]
        }
        return dict
    }()

    /// Key de Google Gemini (usada en Asistente.swift)
    static var geminiKey: String {
        secrets["GEMINI_API_KEY"] as? String ?? ""
    }
}

# 🚚 RutaArca — App iOS para Arca Continental

> Desarrollado durante el **Hackathon Hack4Her** para la problematica de Arca Continental.

App móvil en SwiftUI que optimiza las rutas de visita a sucursales para empleados de **Arca Continental**. Permite gestionar visitas, registrar feedback con evidencia y contar con un asistente virtual con IA para soporte en campo.

---

## Pantallas

| Pantalla | Descripción |
|---|---|
| **Splash** | Pantalla de inicio con logo de RutaArca y animación de entrada |
| **Login 1** | Selección de rol: Empleado o Cliente |
| **Login 2** | Acceso con número de empleado y contraseña |
| **Home (Empleado)** | TabBar con 5 módulos: Home, Calendario, Asistente, Mapa, FeedBack |
| **Home (Cliente)** | TabBar con 4 módulos: Inicio, Calendario, Notificaciones, Feedback |
| **Calendario** | Agenda de visitas a tiendas OXXO con notas y notificaciones |
| **Asistente Virtual** | Chatbot con IA (Gemini 1.5 Flash) para soporte al empleado |
| **Mapa** | Zonas de Monterrey clasificadas por nivel de oportunidad de visita |
| **FeedBack** | Reporte de visita: foto, audio, firma del trabajador y del dueño |

---

## Flujo de navegación

```
Splash (Inicio)
  └─→ Login 1 (selección de rol)
        └─→ Login 2 (empleado)
              └─→ Home con TabBar
                    ├─ Home
                    ├─ Calendario de visitas
                    ├─ Asistente Virtual (Gemini AI)
                    ├─ Mapa de zonas
                    └─ FeedBack de visita
```

---

## Estructura del proyecto

```
ArcaContinental/
├── ArcaContinentalApp.swift    → Entry point (@main)
├── Config.swift                → Lector seguro de API keys
├── Secrets.plist.example       → Plantilla de keys (sí va a Git)
├── Inicio.swift                → Splash screen
├── Login1.swift                → Selección de rol
├── Login2.swift                → Login de empleado
├── ContentView.swift           → TabBar del empleado (5 tabs)
├── Cliente.swift               → TabBar del cliente (4 tabs)
├── CalendarScreenView.swift    → Calendario de visitas a tiendas
├── Asistente.swift             → Chatbot con Gemini AI
├── MapScreenView.swift         → Mapa de zonas por oportunidad
└── FeedBack.swift              → Formulario de reporte de visita
```

---

## Requisitos

- Xcode 15 o superior
- iOS 17+
- Cuenta en [Google AI Studio](https://aistudio.google.com/) para obtener una API key de Gemini

---

## Configuración de API Key

El asistente virtual usa **Google Gemini 1.5 Flash**. La key se maneja de forma segura mediante `Secrets.plist`, que **no se sube a Git**.

1. Copia el archivo de ejemplo:
   ```bash
   cp ArcaContinental/Secrets.plist.example ArcaContinental/Secrets.plist
   ```

2. Abre `Secrets.plist` en Xcode y reemplaza el valor de `GEMINI_API_KEY` con tu key real obtenida en [aistudio.google.com](https://aistudio.google.com/).

3. `Secrets.plist` está en `.gitignore` y **nunca se subirá** al repositorio.

---

## Mapa de oportunidades

El módulo de mapa clasifica las zonas de Monterrey en tres niveles para priorizar visitas:

| Nivel | Color | Frecuencia de revisita |
|---|---|---|
| Alta oportunidad | 🔴 Rojo | 1 mes |
| Oportunidad media | 🟠 Naranja | 2 meses |
| Baja oportunidad | 🟢 Verde | 3 meses |

---

## Módulo de FeedBack

El reporte de visita incluye:
- Captura de foto con cámara
- Grabación de audio
- Firma digital del trabajador y del dueño del local
- Calificación de la visita

---

## Frameworks utilizados

- `SwiftUI` — Interfaz de usuario
- `MapKit` — Mapa de zonas de oportunidad
- `Charts` — Gráficas en la vista de cliente
- `AVFoundation` — Grabación de audio en el reporte
- `Speech` — Reconocimiento de voz
- `UserNotifications` — Recordatorios de visitas
- `UIKit` — Cámara y firma digital

---
<img width="1920" height="1080" alt="RutaArca1" src="https://github.com/user-attachments/assets/726c6e7a-20fa-4c66-8c07-44720d4484ad" />
<img width="1920" height="1080" alt="RutaArca2" src="https://github.com/user-attachments/assets/96c639f4-c18f-4a95-83c3-37df92b30a6e" />

## Hackathon

Proyecto desarrollado durante el **Hackathon Hack4Her**, con el objetivo de empoderar a las promotoras y empleadas de Arca Continental con una herramienta móvil que optimice su trabajo en campo.

---

## 👩‍💻 Autoras

Desarrollado por **Asenet L** , **Damaris B** y **Linda De La Garza** · Junio 2025

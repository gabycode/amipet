# 🐾 AmiPet - Plataforma de Adopción de Mascotas

AmiPet es una aplicación móvil completa desarrollada en Flutter que conecta a personas que buscan adoptar mascotas con aquellas que tienen mascotas disponibles para adopción. La aplicación incluye un sistema de registro de usuarios, gestión de mascotas, formularios de adopción y mucho más.

## ✨ Características Principales

### 🔐 Autenticación y Perfiles

- Registro e inicio de sesión con Firebase Auth
- Perfiles de usuario personalizables con foto
- Edición de información personal
- Sistema de sesiones seguro

### 🐕 Gestión de Mascotas

- Registro de mascotas para adopción con fotos
- Exploración de mascotas disponibles
- Filtrado por especies (perros, gatos, etc.)
- Sistema de favoritos
- Detalles completos de cada mascota

### 📋 Sistema de Adopción

- Formularios de adopción estructurados
- Seguimiento de solicitudes enviadas
- Historial de formularios por usuario
- Validación de datos completos

### 🗂️ Organización

- Lista de mascotas registradas por usuario
- Gestión de favoritos
- Navegación intuitiva entre secciones

## 📱 Tecnologías Utilizadas

### Frontend

- **Flutter** - Framework multiplataforma
- **Provider** - Gestión de estado
- **Firebase Auth** - Autenticación
- **Cloud Firestore** - Base de datos NoSQL
- **Firebase Storage** - Almacenamiento de imágenes
- **Image Picker** - Selección de fotos
- **Google Fonts** - Tipografías personalizadas

### Backend y Servicios

- **Firebase Console** - Gestión de proyecto
- **Cloud Firestore** - Base de datos en tiempo real
- **Firebase Storage** - CDN para imágenes
- **Firebase Auth** - Gestión de usuarios

## 🏗️ Arquitectura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── providers/               # Gestión de estado
│   └── mascota_provider.dart
├── screens/                 # Pantallas de la app
│   ├── home_page.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── user_detail_screen.dart
│   ├── editar_perfil_screen.dart
│   ├── mascotas_page.dart
│   ├── favoritos_page.dart
│   ├── registro_mascotas.dart
│   ├── mascotas_registradas_screen.dart
│   ├── adopt_pet_screen.dart
│   └── pet_detail_screen.dart
├── services/               # Lógica de negocio
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── form_notifier.dart
└── assets/                # Recursos estáticos
    ├── images/
    └── fonts/
```

## � Configuración e Instalación

### Prerrequisitos

- Flutter SDK (versión 3.0 o superior)
- Android Studio o VS Code
- Cuenta de Firebase
- Git

### 1. Clonar el repositorio

```bash
git clone https://github.com/gabycode/amipet.git
cd amipet
```

### 2. Configurar Firebase

1. Crear un proyecto en [Firebase Console](https://console.firebase.google.com)
2. Habilitar Authentication (Email/Password y Google Sign-in)
3. Crear base de datos Cloud Firestore
4. Configurar Storage para imágenes
5. Descargar `google-services.json` para Android
6. Descargar `GoogleService-Info.plist` para iOS

### 3. Instalar dependencias

```bash
flutter pub get
```

### 4. Configurar variables de entorno

Crear archivo `.env` en la raíz del proyecto:

```env
# Firebase Configuration
FIREBASE_API_KEY=tu_api_key
FIREBASE_PROJECT_ID=tu_project_id
FIREBASE_APP_ID=tu_app_id
```

### 5. Ejecutar la aplicación

```bash
# Para Android
flutter run

# Para iOS
flutter run -d ios

# Para Web
flutter run -d chrome
```

## 📊 Estructura de Base de Datos (Firestore)

### Colecciones Principales

```javascript
// Usuarios
usuarios/{userId} {
  email: string,
  nombre: string,
  fotoURL: string,
  fechaCreacion: timestamp,
  estadisticas: {
    formularios_enviados: number,
    mascotas_registradas: number
  }
}

// Mascotas
mascotas/{mascotaId} {
  nombre: string,
  especie: string,
  edad: number,
  descripcion: string,
  fotoURL: string,
  usuarioId: string,
  fechaCreacion: timestamp,
  disponible: boolean
}

// Formularios de Adopción
formularios_adopcion/{formularioId} {
  usuarioId: string,
  mascotaId: string,
  datosPersonales: object,
  motivacion: string,
  experiencia: string,
  vivienda: object,
  estado: string,
  fechaEnvio: timestamp
}
```

## 🔧 Funcionalidades por Pantalla

### 🏠 Pantalla Principal

- Dashboard con mascotas destacadas
- Navegación rápida a secciones principales
- Información del usuario actual

### 👤 Gestión de Usuario

- **Login/Registro**: Autenticación segura
- **Perfil**: Edición de datos personales y foto
- **Configuración**: Ajustes de la cuenta

### 🐾 Gestión de Mascotas

- **Explorar**: Ver todas las mascotas disponibles
- **Favoritos**: Lista personal de mascotas favoritas
- **Registrar**: Añadir nuevas mascotas para adopción
- **Mis Mascotas**: Gestionar mascotas propias

### 📝 Sistema de Adopción

- **Adoptar**: Formulario completo de adopción
- **Mis Solicitudes**: Seguimiento de formularios enviados
- **Validación**: Verificación de datos requeridos

## 🛠️ Scripts de Desarrollo

```bash
# Limpiar proyecto
flutter clean

# Actualizar dependencias
flutter pub upgrade

# Generar APK
flutter build apk

# Generar App Bundle
flutter build appbundle

# Analizar código
flutter analyze

# Ejecutar tests
flutter test
```

## 🎨 Diseño y UX

### Paleta de Colores

- **Verde Principal**: `#355F2E` - Representa la naturaleza y el cuidado
- **Blanco**: `#FFFFFF` - Limpieza y simplicidad
- **Grises**: Varios tonos para texto secundario
- **Rojo Favoritos**: `#FF0000` - Para sistema de favoritos

### Componentes Clave

- Cards responsivos para mascotas
- Botones con estados hover/pressed
- Formularios con validación visual
- Navegación intuitiva con iconos

## 🔐 Seguridad y Buenas Prácticas

### Autenticación

- Tokens JWT manejados automáticamente por Firebase
- Validación de sesión en cada operación crítica
- Logout automático en caso de token expirado

### Base de Datos

- Reglas de seguridad en Firestore
- Validación de permisos por usuario
- Sanitización de datos de entrada

### Imágenes

- Compresión automática antes de subir
- Validación de tipos de archivo
- URLs seguras desde Firebase Storage

## 🤝 Contribución

1. Fork del proyecto
2. Crear branch para nueva característica (`git checkout -b feature/nueva-caracteristica`)
3. Commit de cambios (`git commit -am 'Añadir nueva característica'`)
4. Push al branch (`git push origin feature/nueva-caracteristica`)
5. Crear Pull Request

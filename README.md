# 🐾 AmiPet - Explorador de Mascotas

Aplicación Flutter que muestra mascotas disponibles para adopción utilizando la API de [Petfinder](https://www.petfinder.com/developers/). El backend Node.js se encarga de manejar el token y exponer un endpoint seguro para consumir desde Flutter.

## 📱 Tecnologías utilizadas

- Flutter (Frontend móvil/web)
- Node.js + Express (Backend)
- Petfinder API v2
- dotenv (manejo de claves)
- axios (peticiones HTTP)
- cors (manejo de CORS)

## 🔧 Configuración del Backend

### 1. Clona el repositorio y ve a la carpeta del backend:

```bash
cd petfinder-backend
```

### 2. Instala dependencias

```
npm install
```

### 3. Crea tu archivo .env

Copia el archivo de ejemplo y edítalo con tus credenciales de Petfinder:

```bash
cp .env.example .env
```

```
CLIENT_ID=tu_client_id_aqui
CLIENT_SECRET=tu_client_secret_aqui
```

> Las claves se obtienen desde https://www.petfinder.com/developers

### 4. Ejecuta el servidor

```bash
node index.js
```

> El servidor por defecto corre en http://localhost:3000.

## 🌐 Configuración del Frontend (Flutter)

### 1. Asegúrate de tener Flutter instalado:

```bash
flutter doctor
```

### 2. Corre la app en tu plataforma preferida

En Web (Chrome):

```bash
flutter run -d chrome
```

Android Studio:

> Mayus+F10

✅ El backend se adapta automáticamente al entorno:

```dart
// Se adapta dinámicamente a Web, Android, iOS, etc.
if (kIsWeb) {
  backendUrl = 'http://localhost:3000';
} else if (Platform.isAndroid) {
  backendUrl = 'http://10.0.2.2:3000';
} else {
  backendUrl = 'http://localhost:3000';
}
```

## Licencia

Este proyecto es de uso libre para fines educativos. No está afiliado oficialmente con Petfinder.

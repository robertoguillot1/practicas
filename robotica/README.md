# Sistema de Riego Hidropónico con ESP32

Sistema completo de automatización de riego hidropónico con interfaz web moderna y responsive. Permite control manual del motor, programación de horarios y ajuste de duración de riego.

## 🚀 Características

- ✅ **Control Manual**: Encender y apagar el motor de agua a voluntad
- ✅ **Programación de Horarios**: Configurar múltiples horarios automáticos de riego
- ✅ **Ajuste de Duración**: Establecer cuánto tiempo permanecerá encendido el motor
- ✅ **Interfaz Moderna**: Diseño limpio, intuitivo y visualmente atractivo
- ✅ **Responsive**: Compatible con dispositivos móviles y de escritorio
- ✅ **Persistencia**: Los horarios y configuraciones se guardan en la memoria del ESP32

## 📋 Requisitos

### Hardware
- ESP32 (cualquier variante)
- Módulo relé para controlar el motor de agua
- Fuente de alimentación adecuada
- Motor de agua o bomba hidropónica
- Cables de conexión

### Software
- Arduino IDE 1.8.13 o superior
- Librerías necesarias:
  - WiFi (incluida en ESP32)
  - WebServer (incluida en ESP32)
  - ArduinoJson (versión 6.x)
  - Preferences (incluida en ESP32)

## 📦 Instalación

### 1. Instalar Arduino IDE y Configurar ESP32

1. Descarga e instala [Arduino IDE](https://www.arduino.cc/en/software)
2. Abre Arduino IDE y ve a `Archivo > Preferencias`
3. En "Gestor de URLs Adicionales de Tarjetas", agrega:
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
4. Ve a `Herramientas > Placa > Gestor de Placas`
5. Busca "ESP32" e instala el paquete de Espressif Systems
6. Selecciona tu placa ESP32 en `Herramientas > Placa`

### 2. Instalar Librerías

1. Ve a `Herramientas > Administrar Librerías`
2. Busca e instala:
   - **ArduinoJson** (por Benoit Blanchon) - versión 6.x

### 3. Configurar el Código ESP32

1. Abre el archivo `esp32_riego.ino` en Arduino IDE
2. Modifica las siguientes líneas con tus credenciales WiFi:

```cpp
const char* ssid = "TU_SSID";  // Cambiar por tu SSID
const char* password = "TU_PASSWORD";  // Cambiar por tu contraseña
```

3. Ajusta la zona horaria si es necesario (línea 20):

```cpp
const long gmtOffset_sec = -18000; // GMT-5 (Colombia, Perú, etc.)
// Para otros países:
// GMT-6 (México): -21600
// GMT-3 (Argentina, Chile): -10800
// GMT+1 (España): 3600
```

4. Verifica que el pin del motor sea correcto (línea 12):

```cpp
const int MOTOR_PIN = 2; // Cambiar si usas otro pin
```

### 4. Subir el Código al ESP32

1. Conecta tu ESP32 a la computadora por USB
2. Selecciona el puerto COM correcto en `Herramientas > Puerto`
3. Haz clic en el botón "Subir" (flecha hacia la derecha)
4. Espera a que termine la compilación y carga

### 5. Configurar la Interfaz Web

1. Abre el archivo `script.js`
2. Modifica la IP del ESP32 (línea 3):

```javascript
const ESP32_IP = '192.168.1.100'; // Cambiar por la IP que muestra el Serial Monitor
```

3. Para encontrar la IP del ESP32:
   - Abre el Monitor Serial en Arduino IDE (`Herramientas > Monitor Serial`)
   - Verás un mensaje como: `IP asignada: 192.168.1.100`
   - Copia esa IP y úsala en `script.js`

### 6. Usar la Interfaz

**Opción A: Servidor Local**
- Abre `index.html` en tu navegador web
- Asegúrate de que tu dispositivo esté en la misma red WiFi que el ESP32

**Opción B: Servidor Web**
- Sube los archivos HTML, CSS y JS a un servidor web
- O usa un servidor local como Python:
  ```bash
  python -m http.server 8000
  ```
- Accede desde `http://localhost:8000`

## 🔌 Conexiones del Hardware

```
ESP32          Relé
------         ----
GPIO 2   -->   IN (Entrada de señal)
GND      -->   GND
5V       -->   VCC

Relé            Motor
----            -----
COM      -->    Terminal positivo del motor
NO       -->    Fuente de alimentación del motor
```

**⚠️ Importante**: 
- El relé debe ser compatible con 5V
- Asegúrate de usar una fuente de alimentación adecuada para el motor
- El ESP32 no puede alimentar directamente motores grandes

## 📱 Uso de la Interfaz

### Control Manual
1. Haz clic en el botón "Encender Motor" para activar el motor
2. El motor se apagará automáticamente después del tiempo configurado
3. Puedes apagarlo manualmente haciendo clic en "Apagar Motor"

### Configurar Duración
1. Usa el deslizador o ingresa un valor en segundos (1-3600)
2. Haz clic en "Guardar Duración"
3. Esta duración se aplicará a todos los riegos automáticos y manuales

### Programar Horarios
1. Haz clic en "Agregar Horario"
2. Selecciona la hora deseada
3. Marca los días de la semana en los que quieres que se active
4. Activa o desactiva el horario según necesites
5. Haz clic en "Guardar"

### Editar o Eliminar Horarios
- Haz clic en el ícono de editar (✏️) para modificar un horario
- Haz clic en el ícono de eliminar (🗑️) para borrar un horario

## 🛠️ Solución de Problemas

### El ESP32 no se conecta a WiFi
- Verifica que el SSID y la contraseña sean correctos
- Asegúrate de que la red WiFi esté en modo 2.4GHz (ESP32 no soporta 5GHz)
- Revisa la distancia al router

### No puedo acceder a la interfaz
- Verifica que la IP en `script.js` coincida con la IP del ESP32
- Asegúrate de que ambos dispositivos estén en la misma red WiFi
- Revisa el firewall de tu computadora

### El motor no se activa
- Verifica las conexiones del relé
- Comprueba que el pin del motor sea correcto en el código
- Usa un multímetro para verificar que el relé funcione

### Los horarios no se ejecutan
- Verifica que la zona horaria esté configurada correctamente
- Asegúrate de que el ESP32 tenga conexión a Internet (para NTP)
- Revisa que los horarios estén activos (habilitados)

## 📚 API del ESP32

El ESP32 expone una API REST con los siguientes endpoints:

### Estado del Sistema
- `GET /api/status` - Verifica el estado del sistema

### Control del Motor
- `GET /api/motor/state` - Obtiene el estado actual del motor
- `POST /api/motor/on` - Enciende el motor
- `POST /api/motor/off` - Apaga el motor

### Duración del Riego
- `GET /api/duration` - Obtiene la duración configurada
- `POST /api/duration` - Establece la duración (body: `{"duration": 30}`)

### Horarios
- `GET /api/schedules` - Obtiene todos los horarios
- `POST /api/schedules` - Crea un nuevo horario
- `PUT /api/schedules/{id}` - Actualiza un horario
- `DELETE /api/schedules/{id}` - Elimina un horario

## 🎨 Personalización

### Colores
Puedes personalizar los colores editando las variables CSS en `styles.css`:

```css
:root {
    --primary-color: #10b981;  /* Color principal */
    --secondary-color: #3b82f6; /* Color secundario */
    --accent-color: #8b5cf6;    /* Color de acento */
    /* ... más colores ... */
}
```

### Fuentes
La interfaz usa la fuente "Inter" de Google Fonts. Puedes cambiarla en `index.html`:

```html
<link href="https://fonts.googleapis.com/css2?family=TU_FUENTE&display=swap" rel="stylesheet">
```

## 📄 Licencia

Este proyecto es de código abierto y está disponible para uso personal y comercial.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Si encuentras algún error o tienes sugerencias, no dudes en abrir un issue o enviar un pull request.

## 📞 Soporte

Para problemas o preguntas:
1. Revisa la sección de Solución de Problemas
2. Verifica que todas las dependencias estén instaladas correctamente
3. Revisa los logs del Monitor Serial del Arduino IDE

---

**¡Disfruta de tu sistema de riego hidropónico automatizado! 🌱💧**


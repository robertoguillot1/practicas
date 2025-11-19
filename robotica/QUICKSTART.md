# Inicio Rápido 🚀

## Pasos Rápidos para Comenzar

### 1. Configurar ESP32 (5 minutos)

1. Abre `esp32_riego.ino` en Arduino IDE
2. Cambia estas líneas:
   ```cpp
   const char* ssid = "TU_WIFI";
   const char* password = "TU_PASSWORD";
   ```
3. Sube el código al ESP32
4. Abre el Monitor Serial y copia la IP que aparece (ej: `192.168.1.100`)

### 2. Configurar Interfaz Web (2 minutos)

1. Abre `script.js`
2. Cambia la línea 3:
   ```javascript
   const ESP32_IP = '192.168.1.100'; // Usa la IP del paso anterior
   ```

### 3. Usar la Interfaz (1 minuto)

1. Abre `index.html` en tu navegador
2. ¡Listo! Ya puedes controlar tu sistema de riego

## Conexiones Rápidas

```
ESP32 GPIO 2 → Relé IN
ESP32 GND    → Relé GND
ESP32 5V     → Relé VCC
Relé COM     → Motor +
Relé NO      → Fuente Motor
```

## Funcionalidades Principales

- ⚡ **Control Manual**: Botón grande para encender/apagar
- ⏱️ **Duración**: Deslizador para ajustar tiempo (1-300 seg)
- 📅 **Horarios**: Agregar múltiples horarios automáticos
- 📱 **Responsive**: Funciona en móvil y escritorio

## ¿Problemas?

1. **No conecta**: Verifica WiFi (2.4GHz) y credenciales
2. **No carga interfaz**: Verifica que la IP en `script.js` sea correcta
3. **Motor no funciona**: Revisa conexiones del relé

Para más detalles, consulta el [README.md](README.md) completo.


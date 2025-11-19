// Archivo de configuración de ejemplo
// Copia este archivo como config.js y ajusta los valores según tu configuración

const CONFIG = {
    // IP del ESP32 en tu red local
    // Encuentra esta IP en el Monitor Serial de Arduino IDE
    ESP32_IP: '192.168.1.100',
    
    // Puerto del servidor web (generalmente 80)
    ESP32_PORT: 80,
    
    // Intervalo de verificación de conexión (en milisegundos)
    CONNECTION_CHECK_INTERVAL: 5000,
    
    // Intervalo de verificación de horarios (en milisegundos)
    SCHEDULE_CHECK_INTERVAL: 60000,
    
    // Timeout para peticiones HTTP (en milisegundos)
    HTTP_TIMEOUT: 3000
};

// Si usas este archivo, modifica script.js para importarlo:
// const API_BASE = `http://${CONFIG.ESP32_IP}:${CONFIG.ESP32_PORT}`;


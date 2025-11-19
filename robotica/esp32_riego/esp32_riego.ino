#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>
#include <time.h>
#include <Preferences.h>

// Configuración de WiFi
const char* ssid = "TU_SSID";  // Cambiar por tu SSID
const char* password = "TU_PASSWORD";  // Cambiar por tu contraseña

// Pin del motor (relé)
const int MOTOR_PIN = 2;

// Servidor web en puerto 80
WebServer server(80);

// Preferencias para almacenamiento persistente
Preferences preferences;

// Variables de estado
bool motorState = false;
int irrigationDuration = 30; // Duración en segundos
unsigned long motorStartTime = 0;
bool motorRunning = false;

// Estructura para horarios
struct Schedule {
  int id;
  String time;
  int days[7];
  bool enabled;
};

Schedule schedules[10]; // Máximo 10 horarios
int scheduleCount = 0;
int nextScheduleId = 1;

// Configuración NTP
const char* ntpServer = "pool.ntp.org";
const long gmtOffset_sec = -18000; // Ajustar según tu zona horaria (ej: -18000 para GMT-5)
const int daylightOffset_sec = 0;

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  // Configurar pin del motor
  pinMode(MOTOR_PIN, OUTPUT);
  digitalWrite(MOTOR_PIN, LOW);
  
  // Inicializar preferencias
  preferences.begin("riego", false);
  loadSettings();
  
  // Conectar a WiFi
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.print("Conectando a WiFi");
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println();
  Serial.print("IP asignada: ");
  Serial.println(WiFi.localIP());
  
  // Configurar NTP
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  
  // Configurar rutas del servidor
  setupRoutes();
  
  // Iniciar servidor
  server.begin();
  Serial.println("Servidor web iniciado");
}

void loop() {
  server.handleClient();
  
  // Control del motor
  if (motorRunning) {
    unsigned long elapsed = (millis() - motorStartTime) / 1000;
    if (elapsed >= irrigationDuration) {
      turnMotorOff();
    }
  }
  
  // Verificar horarios programados
  checkSchedules();
  
  delay(100);
}

void setupRoutes() {
  // Servir archivos estáticos (HTML, CSS, JS)
  server.on("/", HTTP_GET, handleRoot);
  server.on("/index.html", HTTP_GET, handleRoot);
  server.on("/styles.css", HTTP_GET, handleCSS);
  server.on("/script.js", HTTP_GET, handleJS);
  
  // API - Estado del sistema
  server.on("/api/status", HTTP_GET, handleStatus);
  
  // API - Control del motor
  server.on("/api/motor/state", HTTP_GET, handleMotorState);
  server.on("/api/motor/on", HTTP_POST, handleMotorOn);
  server.on("/api/motor/off", HTTP_POST, handleMotorOff);
  
  // API - Duración del riego
  server.on("/api/duration", HTTP_GET, handleGetDuration);
  server.on("/api/duration", HTTP_POST, handleSetDuration);
  
  // API - Horarios
  server.on("/api/schedules", HTTP_GET, handleGetSchedules);
  server.on("/api/schedules", HTTP_POST, handleCreateSchedule);
  server.on("/api/schedules", HTTP_OPTIONS, handleCORS);
  
  // Manejar CORS
  server.onNotFound(handleNotFound);
}

void handleCORS() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.sendHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  server.sendHeader("Access-Control-Allow-Headers", "Content-Type");
  server.send(200, "text/plain", "");
}

void handleRoot() {
  String html = getHTML();
  server.send(200, "text/html", html);
}

void handleCSS() {
  // En producción, servir el archivo CSS real
  // Por ahora, retornar un mensaje
  server.send(200, "text/css", "/* CSS será servido desde el ESP32 o servidor externo */");
}

void handleJS() {
  // En producción, servir el archivo JS real
  // Por ahora, retornar un mensaje
  server.send(200, "application/javascript", "// JS será servido desde el ESP32 o servidor externo");
}

void handleStatus() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", "{\"status\":\"ok\"}");
}

void handleMotorState() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  String json = "{\"state\":\"" + String(motorState ? "on" : "off") + "\"}";
  server.send(200, "application/json", json);
}

void handleMotorOn() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  turnMotorOn();
  server.send(200, "application/json", "{\"success\":true}");
}

void handleMotorOff() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  turnMotorOff();
  server.send(200, "application/json", "{\"success\":true}");
}

void handleGetDuration() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  String json = "{\"duration\":" + String(irrigationDuration) + "}";
  server.send(200, "application/json", json);
}

void handleSetDuration() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  
  if (server.hasArg("plain")) {
    StaticJsonDocument<200> doc;
    deserializeJson(doc, server.arg("plain"));
    
    if (doc.containsKey("duration")) {
      irrigationDuration = doc["duration"];
      preferences.putInt("duration", irrigationDuration);
      server.send(200, "application/json", "{\"success\":true}");
      return;
    }
  }
  
  server.send(400, "application/json", "{\"error\":\"Invalid request\"}");
}

void handleGetSchedules() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  
  StaticJsonDocument<2048> doc;
  JsonArray array = doc.to<JsonArray>();
  
  for (int i = 0; i < scheduleCount; i++) {
    JsonObject obj = array.createNestedObject();
    obj["id"] = schedules[i].id;
    obj["time"] = schedules[i].time;
    obj["enabled"] = schedules[i].enabled;
    
    JsonArray daysArray = obj.createNestedArray("days");
    for (int j = 0; j < 7; j++) {
      if (schedules[i].days[j] == 1) {
        daysArray.add(j);
      }
    }
  }
  
  String response;
  serializeJson(doc, response);
  server.send(200, "application/json", response);
}

void handleCreateSchedule() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  
  if (server.hasArg("plain")) {
    StaticJsonDocument<512> doc;
    deserializeJson(doc, server.arg("plain"));
    
    if (scheduleCount < 10 && doc.containsKey("time") && doc.containsKey("days")) {
      Schedule newSchedule;
      newSchedule.id = nextScheduleId++;
      newSchedule.time = doc["time"].as<String>();
      newSchedule.enabled = doc.containsKey("enabled") ? doc["enabled"] : true;
      
      // Inicializar días
      for (int i = 0; i < 7; i++) {
        newSchedule.days[i] = 0;
      }
      
      // Marcar días seleccionados
      JsonArray daysArray = doc["days"];
      for (JsonVariant day : daysArray) {
        int dayIndex = day.as<int>();
        if (dayIndex >= 0 && dayIndex < 7) {
          newSchedule.days[dayIndex] = 1;
        }
      }
      
      schedules[scheduleCount++] = newSchedule;
      saveSchedules();
      
      server.send(200, "application/json", "{\"success\":true,\"id\":" + String(newSchedule.id) + "}");
      return;
    }
  }
  
  server.send(400, "application/json", "{\"error\":\"Invalid request\"}");
}

void handleUpdateSchedule() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  
  String path = server.uri();
  int id = path.substring(path.lastIndexOf('/') + 1).toInt();
  
  if (server.hasArg("plain")) {
    StaticJsonDocument<512> doc;
    deserializeJson(doc, server.arg("plain"));
    
    for (int i = 0; i < scheduleCount; i++) {
      if (schedules[i].id == id) {
        if (doc.containsKey("time")) {
          schedules[i].time = doc["time"].as<String>();
        }
        if (doc.containsKey("enabled")) {
          schedules[i].enabled = doc["enabled"];
        }
        if (doc.containsKey("days")) {
          // Inicializar días
          for (int j = 0; j < 7; j++) {
            schedules[i].days[j] = 0;
          }
          
          // Marcar días seleccionados
          JsonArray daysArray = doc["days"];
          for (JsonVariant day : daysArray) {
            int dayIndex = day.as<int>();
            if (dayIndex >= 0 && dayIndex < 7) {
              schedules[i].days[dayIndex] = 1;
            }
          }
        }
        
        saveSchedules();
        server.send(200, "application/json", "{\"success\":true}");
        return;
      }
    }
  }
  
  server.send(404, "application/json", "{\"error\":\"Schedule not found\"}");
}

void handleDeleteSchedule() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  
  String path = server.uri();
  int id = path.substring(path.lastIndexOf('/') + 1).toInt();
  
  for (int i = 0; i < scheduleCount; i++) {
    if (schedules[i].id == id) {
      // Mover horarios restantes
      for (int j = i; j < scheduleCount - 1; j++) {
        schedules[j] = schedules[j + 1];
      }
      scheduleCount--;
      saveSchedules();
      server.send(200, "application/json", "{\"success\":true}");
      return;
    }
  }
  
  server.send(404, "application/json", "{\"error\":\"Schedule not found\"}");
}

void handleNotFound() {
  String path = server.uri();
  
  // Manejar rutas dinámicas de horarios
  if (path.startsWith("/api/schedules/")) {
    String method = server.method();
    if (method == "PUT") {
      handleUpdateSchedule();
      return;
    } else if (method == "DELETE") {
      handleDeleteSchedule();
      return;
    }
  }
  
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(404, "text/plain", "Not Found");
}

void turnMotorOn() {
  if (!motorRunning) {
    motorState = true;
    motorRunning = true;
    motorStartTime = millis();
    digitalWrite(MOTOR_PIN, HIGH);
    Serial.println("Motor encendido");
  }
}

void turnMotorOff() {
  motorState = false;
  motorRunning = false;
  digitalWrite(MOTOR_PIN, LOW);
  Serial.println("Motor apagado");
}

void checkSchedules() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    return;
  }
  
  char currentTime[6];
  sprintf(currentTime, "%02d:%02d", timeinfo.tm_hour, timeinfo.tm_min);
  int currentDay = timeinfo.tm_wday == 0 ? 6 : timeinfo.tm_wday - 1;
  
  for (int i = 0; i < scheduleCount; i++) {
    if (schedules[i].enabled && 
        schedules[i].time == String(currentTime) && 
        schedules[i].days[currentDay] == 1 &&
        !motorRunning) {
      turnMotorOn();
      break;
    }
  }
}

void loadSettings() {
  irrigationDuration = preferences.getInt("duration", 30);
  scheduleCount = preferences.getInt("scheduleCount", 0);
  nextScheduleId = preferences.getInt("nextScheduleId", 1);
  
  // Cargar horarios
  for (int i = 0; i < scheduleCount && i < 10; i++) {
    String key = "sched_" + String(i);
    String data = preferences.getString(key.c_str(), "");
    
    if (data.length() > 0) {
      StaticJsonDocument<512> doc;
      deserializeJson(doc, data);
      
      schedules[i].id = doc["id"];
      schedules[i].time = doc["time"].as<String>();
      schedules[i].enabled = doc["enabled"];
      
      JsonArray daysArray = doc["days"];
      for (int j = 0; j < 7; j++) {
        schedules[i].days[j] = 0;
      }
      for (JsonVariant day : daysArray) {
        int dayIndex = day.as<int>();
        if (dayIndex >= 0 && dayIndex < 7) {
          schedules[i].days[dayIndex] = 1;
        }
      }
    }
  }
}

void saveSchedules() {
  preferences.putInt("scheduleCount", scheduleCount);
  preferences.putInt("nextScheduleId", nextScheduleId);
  
  for (int i = 0; i < scheduleCount; i++) {
    StaticJsonDocument<512> doc;
    doc["id"] = schedules[i].id;
    doc["time"] = schedules[i].time;
    doc["enabled"] = schedules[i].enabled;
    
    JsonArray daysArray = doc.createNestedArray("days");
    for (int j = 0; j < 7; j++) {
      if (schedules[i].days[j] == 1) {
        daysArray.add(j);
      }
    }
    
    String data;
    serializeJson(doc, data);
    String key = "sched_" + String(i);
    preferences.putString(key.c_str(), data);
  }
}

String getHTML() {
  // Retornar una página simple que redirija a la interfaz
  // En producción, servir los archivos HTML/CSS/JS desde SPIFFS o servidor externo
  return "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Riego Hidropónico</title></head><body><h1>Sistema de Riego Hidropónico</h1><p>Servidor ESP32 funcionando. Usa la interfaz web en tu dispositivo.</p></body></html>";
}


// ============================================
// CONFIGURACIÓN Y ESTADO
// ============================================

// Configuración del ESP32 (se carga desde LocalStorage)
let ESP32_IP = '192.168.1.100';
let ESP32_PORT = 80;
let API_BASE = `http://${ESP32_IP}:${ESP32_PORT}`;

// Estado de la aplicación
let motorState = false;
let schedules = [];
let currentScheduleId = null;
let connectionStatus = false;
let testMode = false;
let irrigationHistory = [];
let activityChart = null;
let logs = [];
let unreadLogs = 0;

// Días de la semana
const daysOfWeek = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

// ============================================
// LOCALSTORAGE - Gestión de Configuración
// ============================================

function saveConfig() {
    const config = {
        esp32_ip: ESP32_IP,
        esp32_port: ESP32_PORT,
        test_mode: testMode,
        notifications: true,
        theme: document.documentElement.getAttribute('data-theme') || 'dark',
        widgetVisibility: getWidgetVisibility()
    };
    localStorage.setItem('riego_config', JSON.stringify(config));
    addLog('Configuración guardada', 'success');
}

function loadConfig() {
    const saved = localStorage.getItem('riego_config');
    if (saved) {
        try {
            const config = JSON.parse(saved);
            ESP32_IP = config.esp32_ip || '192.168.1.100';
            ESP32_PORT = config.esp32_port || 80;
            testMode = config.test_mode || false;
            API_BASE = `http://${ESP32_IP}:${ESP32_PORT}`;
            
            // Aplicar tema
            if (config.theme) {
                document.documentElement.setAttribute('data-theme', config.theme);
                updateThemeIcon(config.theme);
            }
            
            // Restaurar visibilidad de widgets
            if (config.widgetVisibility) {
                restoreWidgetVisibility(config.widgetVisibility);
            }
            
            addLog('Configuración cargada', 'info');
        } catch (error) {
            addLog('Error al cargar configuración: ' + error.message, 'error');
        }
    }
}

function saveHistory() {
    localStorage.setItem('riego_history', JSON.stringify(irrigationHistory));
}

function loadHistory() {
    const saved = localStorage.getItem('riego_history');
    if (saved) {
        try {
            irrigationHistory = JSON.parse(saved);
            renderHistory();
            updateActivityChart();
        } catch (error) {
            addLog('Error al cargar historial: ' + error.message, 'error');
        }
    }
}

function addToHistory(type, duration) {
    const entry = {
        id: Date.now(),
        timestamp: new Date().toISOString(),
        type: type, // 'manual' o 'scheduled'
        duration: duration,
        date: new Date().toLocaleDateString('es-ES'),
        time: new Date().toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit' })
    };
    
    irrigationHistory.unshift(entry);
    if (irrigationHistory.length > 10) {
        irrigationHistory = irrigationHistory.slice(0, 10);
    }
    
    saveHistory();
    renderHistory();
    updateActivityChart();
}

function getWidgetVisibility() {
    const widgets = document.querySelectorAll('.widget');
    const visibility = {};
    widgets.forEach(widget => {
        const widgetName = widget.getAttribute('data-widget');
        visibility[widgetName] = !widget.classList.contains('collapsed');
    });
    return visibility;
}

function restoreWidgetVisibility(visibility) {
    Object.keys(visibility).forEach(widgetName => {
        const widget = document.querySelector(`[data-widget="${widgetName}"]`);
        if (widget && !visibility[widgetName]) {
            widget.classList.add('collapsed');
        }
    });
}

// ============================================
// ELEMENTOS DEL DOM
// ============================================

const connectionStatusDot = document.getElementById('connectionStatus');
const connectionText = document.getElementById('connectionText');
const motorStatusCircle = document.getElementById('motorStatusCircle');
const motorStatusText = document.getElementById('motorStatusText');
const toggleMotorBtn = document.getElementById('toggleMotorBtn');
const durationInput = document.getElementById('durationInput');
const durationSlider = document.getElementById('durationSlider');
const saveDurationBtn = document.getElementById('saveDurationBtn');
const scheduleList = document.getElementById('scheduleList');
const addScheduleBtn = document.getElementById('addScheduleBtn');
const scheduleModal = document.getElementById('scheduleModal');
const closeModal = document.getElementById('closeModal');
const cancelScheduleBtn = document.getElementById('cancelScheduleBtn');
const saveScheduleBtn = document.getElementById('saveScheduleBtn');
const scheduleTime = document.getElementById('scheduleTime');
const scheduleEnabled = document.getElementById('scheduleEnabled');
const modalTitle = document.getElementById('modalTitle');
const themeToggle = document.getElementById('themeToggle');
const themeIcon = document.getElementById('themeIcon');
const settingsBtn = document.getElementById('settingsBtn');
const settingsModal = document.getElementById('settingsModal');
const closeSettingsModalBtn = document.getElementById('closeSettingsModal');
const cancelSettingsBtn = document.getElementById('cancelSettingsBtn');
const saveSettingsBtn = document.getElementById('saveSettingsBtn');
const esp32IpInput = document.getElementById('esp32IpInput');
const esp32PortInput = document.getElementById('esp32PortInput');
const testModeCheckbox = document.getElementById('testModeCheckbox');
const notificationsCheckbox = document.getElementById('notificationsCheckbox');
const logsPanel = document.getElementById('logsPanel');
const logsContent = document.getElementById('logsContent');
const openLogsBtn = document.getElementById('openLogsBtn');
const closeLogsBtn = document.getElementById('closeLogsBtn');
const clearLogsBtn = document.getElementById('clearLogsBtn');
const logBadge = document.getElementById('logBadge');
const historyContent = document.getElementById('historyContent');

// ============================================
// INICIALIZACIÓN
// ============================================

document.addEventListener('DOMContentLoaded', () => {
    initializeApp();
});

async function initializeApp() {
    loadConfig();
    loadHistory();
    setupEventListeners();
    initializeActivityChart();
    setupWidgetToggles();
    
    // Actualizar campos de configuración
    if (esp32IpInput) esp32IpInput.value = ESP32_IP;
    if (esp32PortInput) esp32PortInput.value = ESP32_PORT;
    if (testModeCheckbox) testModeCheckbox.checked = testMode;
    
    await checkConnection();
    await loadMotorState();
    await loadDuration();
    await loadSchedules();
    
    // Verificar conexión periódicamente
    setInterval(checkConnection, 5000);
    
    // Verificar horarios cada minuto
    setInterval(checkSchedules, 60000);
    
    addLog('Aplicación inicializada', 'success');
}

function setupEventListeners() {
    // Control del motor
    toggleMotorBtn.addEventListener('click', toggleMotor);
    
    // Configuración de duración
    durationSlider.addEventListener('input', (e) => {
        durationInput.value = e.target.value;
    });
    
    durationInput.addEventListener('input', (e) => {
        const value = Math.min(Math.max(parseInt(e.target.value) || 1, 1), 3600);
        durationSlider.value = Math.min(value, 300);
        durationInput.value = value;
    });
    
    saveDurationBtn.addEventListener('click', saveDuration);
    
    // Programación de horarios
    addScheduleBtn.addEventListener('click', () => openScheduleModal());
    closeModal.addEventListener('click', closeScheduleModal);
    cancelScheduleBtn.addEventListener('click', closeScheduleModal);
    saveScheduleBtn.addEventListener('click', saveSchedule);
    
    // Tema
    themeToggle.addEventListener('click', toggleTheme);
    
    // Configuración
    if (settingsBtn) {
        settingsBtn.addEventListener('click', () => openSettingsModal());
    }
    if (closeSettingsModalBtn) {
        closeSettingsModalBtn.addEventListener('click', () => closeSettingsModal());
    }
    if (cancelSettingsBtn) {
        cancelSettingsBtn.addEventListener('click', () => closeSettingsModal());
    }
    if (saveSettingsBtn) {
        saveSettingsBtn.addEventListener('click', saveSettings);
    }
    
    // Logs
    openLogsBtn.addEventListener('click', () => {
        logsPanel.classList.add('active');
        unreadLogs = 0;
        updateLogBadge();
    });
    closeLogsBtn.addEventListener('click', () => {
        logsPanel.classList.remove('active');
    });
    clearLogsBtn.addEventListener('click', clearLogs);
    
    // Cerrar modales al hacer clic fuera
    scheduleModal.addEventListener('click', (e) => {
        if (e.target === scheduleModal) closeScheduleModal();
    });
    settingsModal.addEventListener('click', (e) => {
        if (e.target === settingsModal) closeSettingsModal();
    });
}

function setupWidgetToggles() {
    document.querySelectorAll('.widget-toggle').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const widgetName = btn.getAttribute('data-widget');
            const widget = document.querySelector(`[data-widget="${widgetName}"]`);
            if (widget) {
                widget.classList.toggle('collapsed');
                saveConfig();
            }
        });
    });
}

// ============================================
// TEMA OSCURO/CLARO
// ============================================

function toggleTheme() {
    const currentTheme = document.documentElement.getAttribute('data-theme') || 'dark';
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', newTheme);
    updateThemeIcon(newTheme);
    saveConfig();
    addLog(`Tema cambiado a ${newTheme === 'dark' ? 'oscuro' : 'claro'}`, 'info');
}

function updateThemeIcon(theme) {
    if (themeIcon) {
        themeIcon.textContent = theme === 'dark' ? '🌙' : '☀️';
    }
}

// ============================================
// CONFIGURACIÓN
// ============================================

function openSettingsModal() {
    if (!settingsModal) {
        console.error('Modal de configuración no encontrado');
        return;
    }
    if (esp32IpInput) esp32IpInput.value = ESP32_IP;
    if (esp32PortInput) esp32PortInput.value = ESP32_PORT;
    if (testModeCheckbox) testModeCheckbox.checked = testMode;
    settingsModal.classList.add('active');
}

function closeSettingsModal() {
    if (settingsModal) {
        settingsModal.classList.remove('active');
    }
}

function saveSettings() {
    if (!esp32IpInput || !esp32PortInput || !testModeCheckbox) {
        showNotification('Error: elementos de configuración no encontrados', 'error');
        return;
    }
    
    const newIp = esp32IpInput.value.trim();
    const newPort = parseInt(esp32PortInput.value) || 80;
    
    if (!newIp) {
        showNotification('Por favor, ingresa una IP válida', 'error');
        return;
    }
    
    ESP32_IP = newIp;
    ESP32_PORT = newPort;
    API_BASE = `http://${ESP32_IP}:${ESP32_PORT}`;
    testMode = testModeCheckbox.checked;
    
    saveConfig();
    closeSettingsModal();
    showNotification('Configuración guardada correctamente', 'success');
    checkConnection();
}

// ============================================
// CONEXIÓN CON ESP32
// ============================================

async function checkConnection() {
    if (testMode) {
        connectionStatus = true;
        updateConnectionStatus(true);
        return;
    }
    
    try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 3000);
        
        const response = await fetch(`${API_BASE}/api/status`, {
            method: 'GET',
            signal: controller.signal
        });
        
        clearTimeout(timeoutId);
        
        if (response.ok) {
            connectionStatus = true;
            updateConnectionStatus(true);
        } else {
            throw new Error('Error en la respuesta');
        }
    } catch (error) {
        connectionStatus = false;
        updateConnectionStatus(false);
        if (!testMode) {
            addLog('Error de conexión: ' + (error.message || 'No se pudo conectar al ESP32'), 'error');
        }
    }
}

function updateConnectionStatus(connected) {
    if (connected) {
        connectionStatusDot.className = 'status-dot connected';
        connectionText.textContent = testMode ? 'Modo Prueba' : 'Conectado';
    } else {
        connectionStatusDot.className = 'status-dot disconnected';
        connectionText.textContent = 'Desconectado';
    }
}

// ============================================
// CONTROL DEL MOTOR
// ============================================

async function loadMotorState() {
    if (testMode) return;
    
    try {
        const response = await fetch(`${API_BASE}/api/motor/state`);
        if (response.ok) {
            const data = await response.json();
            motorState = data.state === 'on';
            updateMotorUI();
        }
    } catch (error) {
        addLog('Error al cargar estado del motor: ' + error.message, 'error');
    }
}

async function toggleMotor() {
    if (!testMode && !connectionStatus) {
        showNotification('No hay conexión con el ESP32. Activa el modo de prueba en configuración.', 'error');
        return;
    }
    
    toggleMotorBtn.disabled = true;
    const newState = !motorState;
    const duration = parseInt(durationInput.value) || 30;
    
    try {
        if (testMode) {
            // Simular en modo prueba
            await new Promise(resolve => setTimeout(resolve, 500));
            motorState = newState;
            updateMotorUI();
            
            if (newState) {
                addLog(`Motor ${newState ? 'encendido' : 'apagado'} (SIMULADO) - Duración: ${duration}s`, 'info');
                addToHistory('manual', duration);
                
                // Simular apagado automático
                setTimeout(() => {
                    if (motorState) {
                        motorState = false;
                        updateMotorUI();
                        addLog('Motor apagado automáticamente (SIMULADO)', 'info');
                    }
                }, duration * 1000);
            } else {
                addLog('Motor apagado manualmente (SIMULADO)', 'info');
            }
        } else {
            const response = await fetch(`${API_BASE}/api/motor/${newState ? 'on' : 'off'}`, {
                method: 'POST'
            });
            
            if (response.ok) {
                motorState = newState;
                updateMotorUI();
                
                if (newState) {
                    addLog(`Motor encendido - Duración: ${duration}s`, 'success');
                    addToHistory('manual', duration);
                } else {
                    addLog('Motor apagado', 'info');
                }
            } else {
                throw new Error('Error al cambiar estado del motor');
            }
        }
    } catch (error) {
        addLog('Error al cambiar estado del motor: ' + error.message, 'error');
        showNotification('Error al cambiar el estado del motor. Verifica la conexión.', 'error');
    } finally {
        toggleMotorBtn.disabled = false;
    }
}

function updateMotorUI() {
    const waterDrops = document.getElementById('waterDrops');
    
    if (motorState) {
        motorStatusCircle.classList.add('active');
        motorStatusText.textContent = 'Motor Encendido' + (testMode ? ' (Prueba)' : '');
        motorStatusText.classList.add('active');
        toggleMotorBtn.innerHTML = '<span class="btn-icon">⏸️</span><span>Apagar Motor</span>';
        
        if (waterDrops.children.length === 0) {
            for (let i = 0; i < 6; i++) {
                const drop = document.createElement('div');
                drop.className = 'water-drop';
                waterDrops.appendChild(drop);
            }
        }
    } else {
        motorStatusCircle.classList.remove('active');
        motorStatusText.textContent = 'Motor Apagado';
        motorStatusText.classList.remove('active');
        toggleMotorBtn.innerHTML = '<span class="btn-icon">⚡</span><span>Encender Motor</span>';
        waterDrops.innerHTML = '';
    }
}

// ============================================
// DURACIÓN DEL RIEGO
// ============================================

async function saveDuration() {
    if (!testMode && !connectionStatus) {
        showNotification('No hay conexión con el ESP32', 'error');
        return;
    }
    
    const duration = parseInt(durationInput.value);
    
    if (duration < 1 || duration > 3600) {
        showNotification('La duración debe estar entre 1 y 3600 segundos', 'error');
        return;
    }
    
    saveDurationBtn.disabled = true;
    saveDurationBtn.classList.add('loading');
    const originalText = saveDurationBtn.innerHTML;
    
    try {
        if (!testMode) {
            const response = await fetch(`${API_BASE}/api/duration`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ duration })
            });
            
            if (!response.ok) {
                throw new Error('Error al guardar duración');
            }
        }
        
        saveDurationBtn.classList.remove('loading');
        saveDurationBtn.classList.add('success-animation');
        showNotification('Duración guardada correctamente', 'success');
        addLog(`Duración de riego actualizada a ${duration} segundos`, 'success');
        setTimeout(() => {
            saveDurationBtn.classList.remove('success-animation');
        }, 500);
    } catch (error) {
        addLog('Error al guardar duración: ' + error.message, 'error');
        showNotification('Error al guardar la duración. Verifica la conexión.', 'error');
    } finally {
        saveDurationBtn.disabled = false;
        saveDurationBtn.innerHTML = originalText;
    }
}

async function loadDuration() {
    if (testMode) return;
    
    try {
        const response = await fetch(`${API_BASE}/api/duration`);
        if (response.ok) {
            const data = await response.json();
            durationInput.value = data.duration;
            durationSlider.value = Math.min(data.duration, 300);
        }
    } catch (error) {
        addLog('Error al cargar duración: ' + error.message, 'error');
    }
}

// ============================================
// HORARIOS
// ============================================

async function loadSchedules() {
    if (testMode) return;
    
    try {
        const response = await fetch(`${API_BASE}/api/schedules`);
        if (response.ok) {
            schedules = await response.json();
            renderSchedules();
        }
    } catch (error) {
        addLog('Error al cargar horarios: ' + error.message, 'error');
    }
}

function renderSchedules() {
    if (schedules.length === 0) {
        scheduleList.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">📅</div>
                <div class="empty-state-text">No hay horarios programados</div>
            </div>
        `;
        return;
    }
    
    scheduleList.innerHTML = schedules.map(schedule => {
        const days = schedule.days.map(day => `<span class="day-badge">${daysOfWeek[day]}</span>`).join('');
        const statusClass = schedule.enabled ? '' : 'disabled';
        const statusText = schedule.enabled ? 'Activo' : 'Inactivo';
        
        return `
            <div class="schedule-item ${statusClass}" data-id="${schedule.id}">
                <div class="schedule-info">
                    <div class="schedule-time">${schedule.time}</div>
                    <div class="schedule-days">
                        ${days}
                        <span style="margin-left: 0.5rem; color: var(--text-muted);">• ${statusText}</span>
                    </div>
                </div>
                <div class="schedule-actions">
                    <button class="btn btn-icon-only btn-edit" onclick="editSchedule(${schedule.id})">
                        ✏️
                    </button>
                    <button class="btn btn-icon-only btn-delete" onclick="deleteSchedule(${schedule.id})">
                        🗑️
                    </button>
                </div>
            </div>
        `;
    }).join('');
}

function openScheduleModal(scheduleId = null) {
    currentScheduleId = scheduleId;
    
    if (scheduleId !== null) {
        const schedule = schedules.find(s => s.id === scheduleId);
        if (schedule) {
            modalTitle.textContent = 'Editar Horario';
            scheduleTime.value = schedule.time;
            scheduleEnabled.checked = schedule.enabled;
            
            document.querySelectorAll('.day-input').forEach(input => {
                input.checked = schedule.days.includes(parseInt(input.value));
            });
        }
    } else {
        modalTitle.textContent = 'Nuevo Horario';
        scheduleTime.value = '';
        scheduleEnabled.checked = true;
        document.querySelectorAll('.day-input').forEach(input => {
            input.checked = false;
        });
    }
    
    scheduleModal.classList.add('active');
}

function closeScheduleModal() {
    scheduleModal.classList.remove('active');
    currentScheduleId = null;
}

async function saveSchedule() {
    if (!testMode && !connectionStatus) {
        showNotification('No hay conexión con el ESP32', 'error');
        return;
    }
    
    const time = scheduleTime.value;
    if (!time) {
        showNotification('Por favor, selecciona una hora', 'error');
        return;
    }
    
    const selectedDays = Array.from(document.querySelectorAll('.day-input:checked'))
        .map(input => parseInt(input.value));
    
    if (selectedDays.length === 0) {
        showNotification('Por favor, selecciona al menos un día', 'error');
        return;
    }
    
    const scheduleData = {
        time,
        days: selectedDays,
        enabled: scheduleEnabled.checked
    };
    
    saveScheduleBtn.disabled = true;
    
    try {
        if (testMode) {
            // Simular guardado
            await new Promise(resolve => setTimeout(resolve, 500));
            if (currentScheduleId === null) {
                const newSchedule = {
                    id: Date.now(),
                    ...scheduleData
                };
                schedules.push(newSchedule);
            } else {
                const index = schedules.findIndex(s => s.id === currentScheduleId);
                if (index !== -1) {
                    schedules[index] = { id: currentScheduleId, ...scheduleData };
                }
            }
            renderSchedules();
            addLog('Horario guardado (SIMULADO)', 'success');
        } else {
            let response;
            if (currentScheduleId !== null) {
                response = await fetch(`${API_BASE}/api/schedules/${currentScheduleId}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(scheduleData)
                });
            } else {
                response = await fetch(`${API_BASE}/api/schedules`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(scheduleData)
                });
            }
            
            if (response.ok) {
                await loadSchedules();
                addLog('Horario guardado correctamente', 'success');
            } else {
                throw new Error('Error al guardar horario');
            }
        }
        
        closeScheduleModal();
        showNotification('Horario guardado correctamente', 'success');
    } catch (error) {
        addLog('Error al guardar horario: ' + error.message, 'error');
        showNotification('Error al guardar el horario. Verifica la conexión.', 'error');
    } finally {
        saveScheduleBtn.disabled = false;
    }
}

function editSchedule(scheduleId) {
    openScheduleModal(scheduleId);
}

async function deleteSchedule(scheduleId) {
    if (!confirm('¿Estás seguro de que deseas eliminar este horario?')) {
        return;
    }
    
    if (!testMode && !connectionStatus) {
        showNotification('No hay conexión con el ESP32', 'error');
        return;
    }
    
    try {
        if (testMode) {
            schedules = schedules.filter(s => s.id !== scheduleId);
            renderSchedules();
            addLog('Horario eliminado (SIMULADO)', 'info');
        } else {
            const response = await fetch(`${API_BASE}/api/schedules/${scheduleId}`, {
                method: 'DELETE'
            });
            
            if (response.ok) {
                await loadSchedules();
                addLog('Horario eliminado correctamente', 'success');
            } else {
                throw new Error('Error al eliminar horario');
            }
        }
        
        showNotification('Horario eliminado correctamente', 'success');
    } catch (error) {
        addLog('Error al eliminar horario: ' + error.message, 'error');
        showNotification('Error al eliminar el horario. Verifica la conexión.', 'error');
    }
}

function checkSchedules() {
    if ((!testMode && !connectionStatus) || schedules.length === 0) {
        return;
    }
    
    const now = new Date();
    const currentTime = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;
    const currentDay = now.getDay() === 0 ? 6 : now.getDay() - 1;
    
    schedules.forEach(schedule => {
        if (schedule.enabled && schedule.time === currentTime && schedule.days.includes(currentDay)) {
            if (!motorState) {
                addLog(`Horario activado: ${schedule.time}`, 'info');
                toggleMotor();
                const duration = parseInt(durationInput.value) || 30;
                addToHistory('scheduled', duration);
            }
        }
    });
}

// ============================================
// HISTORIAL
// ============================================

function renderHistory() {
    if (irrigationHistory.length === 0) {
        historyContent.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">📊</div>
                <div class="empty-state-text">No hay historial aún</div>
            </div>
        `;
        return;
    }
    
    historyContent.innerHTML = irrigationHistory.map(entry => {
        const typeClass = entry.type === 'manual' ? 'manual' : 'scheduled';
        const typeText = entry.type === 'manual' ? 'Manual' : 'Programado';
        
        return `
            <div class="history-item">
                <div class="history-item-info">
                    <div class="history-item-time">${entry.time}</div>
                    <div class="history-item-details">
                        ${entry.date} • Duración: ${entry.duration}s
                    </div>
                </div>
                <span class="history-item-type ${typeClass}">${typeText}</span>
            </div>
        `;
    }).join('');
}

// ============================================
// GRÁFICO DE ACTIVIDAD
// ============================================

function initializeActivityChart() {
    const ctx = document.getElementById('activityChart');
    if (!ctx) return;
    
    activityChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: [],
            datasets: [{
                label: 'Riegos',
                data: [],
                backgroundColor: 'rgba(16, 185, 129, 0.6)',
                borderColor: 'rgba(16, 185, 129, 1)',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        stepSize: 1
                    }
                }
            },
            plugins: {
                legend: {
                    display: false
                }
            }
        }
    });
    
    updateActivityChart();
}

function updateActivityChart() {
    if (!activityChart) return;
    
    // Agrupar por hora del día
    const hourlyData = {};
    const today = new Date().toLocaleDateString('es-ES');
    
    irrigationHistory.filter(entry => entry.date === today).forEach(entry => {
        const hour = new Date(entry.timestamp).getHours();
        hourlyData[hour] = (hourlyData[hour] || 0) + 1;
    });
    
    // Crear datos para las últimas 24 horas
    const labels = [];
    const data = [];
    
    for (let i = 0; i < 24; i++) {
        labels.push(`${String(i).padStart(2, '0')}:00`);
        data.push(hourlyData[i] || 0);
    }
    
    activityChart.data.labels = labels;
    activityChart.data.datasets[0].data = data;
    activityChart.update();
}

// ============================================
// LOGS DEL SISTEMA
// ============================================

function addLog(message, type = 'info') {
    const timestamp = new Date().toLocaleTimeString('es-ES');
    const logEntry = {
        timestamp,
        message,
        type
    };
    
    logs.unshift(logEntry);
    if (logs.length > 100) {
        logs = logs.slice(0, 100);
    }
    
    renderLogs();
    
    if (!logsPanel.classList.contains('active')) {
        unreadLogs++;
        updateLogBadge();
    }
}

function renderLogs() {
    if (!logsContent) return;
    
    logsContent.innerHTML = logs.map(log => {
        return `
            <div class="log-entry ${log.type}">
                <span class="log-time">[${log.timestamp}]</span>
                <span class="log-message">${log.message}</span>
            </div>
        `;
    }).join('');
    
    logsContent.scrollTop = 0;
}

function clearLogs() {
    if (confirm('¿Estás seguro de que deseas limpiar todos los logs?')) {
        logs = [];
        renderLogs();
        unreadLogs = 0;
        updateLogBadge();
        addLog('Logs limpiados', 'info');
    }
}

function updateLogBadge() {
    if (logBadge) {
        if (unreadLogs > 0) {
            logBadge.textContent = unreadLogs > 99 ? '99+' : unreadLogs;
            logBadge.style.display = 'flex';
        } else {
            logBadge.style.display = 'none';
        }
    }
}

// ============================================
// NOTIFICACIONES
// ============================================

function showNotification(message, type = 'info') {
    if (!notificationsCheckbox || !notificationsCheckbox.checked) {
        return;
    }
    
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    
    const icon = type === 'success' ? '✅' : type === 'error' ? '❌' : 'ℹ️';
    notification.innerHTML = `
        <span style="margin-right: 0.5rem; font-size: 1.2rem;">${icon}</span>
        <span>${message}</span>
    `;
    
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: var(--bg-secondary);
        color: var(--text-primary);
        padding: 1rem 1.5rem;
        border-radius: var(--radius-md);
        border: 1px solid ${type === 'success' ? 'var(--primary-color)' : type === 'error' ? 'var(--danger-color)' : 'var(--border-color)'};
        box-shadow: var(--shadow-lg);
        z-index: 2000;
        display: flex;
        align-items: center;
        animation: slideIn 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
        max-width: 300px;
    `;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease-in';
        setTimeout(() => {
            if (notification.parentNode) {
                document.body.removeChild(notification);
            }
        }, 300);
    }, 3000);
}

// Agregar estilos de animación para notificaciones
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

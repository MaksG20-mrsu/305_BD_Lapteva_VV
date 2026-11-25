PRAGMA foreign_keys = ON;

-- 1. Кадровый учет работников (мастеров)
CREATE TABLE masters (
    id INTEGER PRIMARY KEY,
    last_name TEXT NOT NULL,
    first_name TEXT NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    hire_date DATE NOT NULL DEFAULT (date('now')),
    dismissal_date DATE, -- NULL означает, что мастер работает. Удаление запрещено через ON DELETE RESTRICT.
    revenue_share_percent REAL CHECK(revenue_share_percent > 0 AND revenue_share_percent <= 100) NOT NULL DEFAULT 50.0
);

-- 2. Справочник предоставляемых услуг
CREATE TABLE services (
    id INTEGER PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    duration_min INTEGER CHECK(duration_min > 0) NOT NULL,
    price REAL CHECK(price >= 0) NOT NULL
);

-- 3. Предварительная запись к мастеру
CREATE TABLE appointments (
    id INTEGER PRIMARY KEY,
    master_id INTEGER NOT NULL,
    client_name TEXT NOT NULL,
    client_phone TEXT NOT NULL,
    scheduled_at DATETIME NOT NULL,
    status TEXT CHECK(status IN ('planned', 'completed', 'cancelled')) NOT NULL DEFAULT 'planned',
    FOREIGN KEY (master_id) REFERENCES masters(id) ON DELETE RESTRICT
);

-- 4. Выбранные услуги в записи (связь многие-ко-многим)
CREATE TABLE appointment_services (
    appointment_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    PRIMARY KEY (appointment_id, service_id),
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE RESTRICT
);

-- 5. Учет фактически выполненных работ
CREATE TABLE work_records (
    id INTEGER PRIMARY KEY,
    appointment_id INTEGER NOT NULL,
    master_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    completed_at DATETIME NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE RESTRICT,
    FOREIGN KEY (master_id) REFERENCES masters(id) ON DELETE RESTRICT,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE RESTRICT
);

-- Индексы для ускорения поиска и построения отчетов
CREATE INDEX idx_masters_last_name ON masters(last_name);
CREATE INDEX idx_appointments_master_date ON appointments(master_id, scheduled_at);
CREATE INDEX idx_work_records_master_date ON work_records(master_id, completed_at);

-- ==========================================
-- Тестовые данные
-- ==========================================

-- Мастера
INSERT INTO masters (last_name, first_name, phone, revenue_share_percent) VALUES 
('Иванов', 'Иван', '+79001112233', 60.0),
('Петров', 'Петр', '+79004445566', 50.0),
('Сидоров', 'Сидор', '+79007778899', 55.0);

-- Услуги
INSERT INTO services (name, duration_min, price) VALUES 
('Замена масла', 30, 1500.0),
('Диагностика ходовой', 45, 1000.0),
('Развал-схождение', 60, 2500.0),
('Замена тормозных колодок', 90, 3000.0);

-- Предварительные записи
INSERT INTO appointments (master_id, client_name, client_phone, scheduled_at, status) VALUES 
(1, 'Алексеев Алексей', '+79991234567', '2026-11-26 10:00:00', 'planned'),
(2, 'Борисов Борис', '+79997654321', '2026-11-26 11:00:00', 'planned'),
(1, 'Викторов Виктор', '+79990001122', '2026-11-25 15:00:00', 'completed');

-- Услуги в записях
INSERT INTO appointment_services (appointment_id, service_id) VALUES 
(1, 1), (1, 2),
(2, 3),
(3, 4);

-- Фактически выполненные работы (для завершенной записи)
INSERT INTO work_records (appointment_id, master_id, service_id, completed_at) VALUES 
(3, 1, 4, '2026-11-25 16:30:00');
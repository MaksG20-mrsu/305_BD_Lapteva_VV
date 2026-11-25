<?php
// Подключение к БД через PDO
$dbPath = __DIR__ . '/sto.db';
try {
    $pdo = new PDO("sqlite:$dbPath", null, null, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
} catch (PDOException $e) {
    die("Ошибка подключения к БД: " . $e->getMessage() . "\n");
}

// 1. Получаем список мастеров для меню
$stmt = $pdo->query("SELECT id, last_name, first_name FROM masters ORDER BY last_name");
$masters = $stmt->fetchAll();

echo "Доступные мастера:\n";
echo str_repeat("-", 30) . "\n";
foreach ($masters as $master) {
    printf("%-4d | %s %s\n", $master['id'], $master['last_name'], $master['first_name']);
}
echo str_repeat("-", 30) . "\n";

// 2. Запрос номера мастера с валидацией
echo "Введите номер мастера (или нажмите Enter для вывода по всем): ";
$input = trim(fgets(STDIN));

$masterId = null;
if ($input !== '') {
    // Проверка: является ли ввод целым положительным числом
    if (!ctype_digit($input)) {
        die("Ошибка: введите корректный числовой номер мастера.\n");
    }
    
    $masterId = (int)$input;
    
    // Проверка: существует ли такой мастер в базе
    $checkStmt = $pdo->prepare("SELECT 1 FROM masters WHERE id = :id");
    $checkStmt->execute([':id' => $masterId]);
    if (!$checkStmt->fetch()) {
        die("Ошибка: мастер с номером {$masterId} не найден в базе данных.\n");
    }
}

// 3. Формируем основной запрос с подготовленными параметрами
$sql = "
    SELECT 
        m.id AS master_id, 
        m.last_name || ' ' || m.first_name AS full_name,
        wr.completed_at, 
        s.name AS service_name, 
        s.price
    FROM work_records wr
    JOIN masters m ON wr.master_id = m.id
    JOIN services s ON wr.service_id = s.id
";

$params = [];
if ($masterId !== null) {
    $sql .= " WHERE m.id = :master_id";
    $params[':master_id'] = $masterId;
}
$sql .= " ORDER BY m.last_name ASC, wr.completed_at ASC";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$records = $stmt->fetchAll();

// 4. Вывод таблицы с псевдографикой
echo "\n";
echo "+------+----------------------+---------------------+----------------------------+------------+\n";
echo "| №    | ФИО Мастера          | Дата работы         | Услуга                     | Стоимость  |\n";
echo "+------+----------------------+---------------------+----------------------------+------------+\n";

if (count($records) === 0) {
    echo "| Нет данных для отображения                                               |\n";
} else {
    foreach ($records as $row) {
        printf(
            "| %-4d | %-20s | %-19s | %-26s | %10.2f |\n",
            $row['master_id'],
            mb_substr($row['full_name'], 0, 20, 'UTF-8'),
            $row['completed_at'],
            mb_substr($row['service_name'], 0, 26, 'UTF-8'),
            $row['price']
        );
    }
}
echo "+------+----------------------+---------------------+----------------------------+------------+\n";
echo "Всего записей: " . count($records) . "\n";
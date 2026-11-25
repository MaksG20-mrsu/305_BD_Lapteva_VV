<?php
// Подключение к БД через PDO
$dbPath = __DIR__ . '/sto.db';
try {
    $pdo = new PDO("sqlite:$dbPath", null, null, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);
} catch (PDOException $e) {
    die("Ошибка подключения к БД: " . htmlspecialchars($e->getMessage()));
}

// Получаем список мастеров для выпадающего списка
$stmt = $pdo->query("SELECT id, last_name, first_name FROM masters ORDER BY last_name");
$masters = $stmt->fetchAll();

// Обрабатываем ввод из формы (GET-параметр)
$masterId = null;
if (isset($_GET['master_id']) && $_GET['master_id'] !== '') {
    $masterId = (int)$_GET['master_id'];
}

// Формируем запрос с подготовленными параметрами
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
?>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Отчет по работам СТО</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f9f9f9; }
        h2 { text-align: center; color: #333; }
        form { text-align: center; margin-bottom: 20px; }
        select, button { padding: 8px 12px; font-size: 14px; margin: 0 5px; }
        button { background-color: #007bff; color: white; border: none; cursor: pointer; border-radius: 4px; }
        button:hover { background-color: #0056b3; }
        table { border-collapse: collapse; width: 90%; margin: 0 auto; background-color: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background-color: #f2f2f2; font-weight: bold; }
        .no-data { text-align: center; margin-top: 20px; color: #666; }
    </style>
</head>
<body>

    <h2>Отчет по оказанным услугам</h2>

    <form method="GET">
        <label for="master_id">Выберите мастера:</label>
        <select name="master_id" id="master_id">
            <option value="">Все мастера</option>
            <?php foreach ($masters as $master): ?>
                <option value="<?= htmlspecialchars($master['id']) ?>" <?= $masterId === (int)$master['id'] ? 'selected' : '' ?>>
                    <?= htmlspecialchars($master['id']) ?> - <?= htmlspecialchars($master['last_name'] . ' ' . $master['first_name']) ?>
                </option>
            <?php endforeach; ?>
        </select>
        <button type="submit">Показать</button>
    </form>

    <?php if (count($records) > 0): ?>
        <table>
            <thead>
                <tr>
                    <th>№ Мастера</th>
                    <th>ФИО Мастера</th>
                    <th>Дата работы</th>
                    <th>Услуга</th>
                    <th>Стоимость (₽)</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($records as $row): ?>
                    <tr>
                        <td><?= htmlspecialchars($row['master_id']) ?></td>
                        <td><?= htmlspecialchars($row['full_name']) ?></td>
                        <td><?= htmlspecialchars($row['completed_at']) ?></td>
                        <td><?= htmlspecialchars($row['service_name']) ?></td>
                        <td><?= number_format($row['price'], 2, '.', ' ') ?></td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    <?php else: ?>
        <p class="no-data">Записи о выполненных работах не найдены.</p>
    <?php endif; ?>

</body>
</html>
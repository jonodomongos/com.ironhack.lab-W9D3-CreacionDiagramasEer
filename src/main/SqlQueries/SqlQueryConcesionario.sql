-- Creamos la BD
CREATE DATABASE IF NOT EXISTS concesionario
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_spanish_ci;

USE concesionario;

-- Creamos la tabla concesionarios
CREATE TABLE concesionarios (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  nombre       VARCHAR(120) NOT NULL,
  ciudad       VARCHAR(80)  NOT NULL,
  telefono     VARCHAR(20)  NULL,
  alta         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_concesionario (nombre, ciudad)
) ENGINE=InnoDB;

-- Creamos la tabla coches
CREATE TABLE coches (
  id               INT AUTO_INCREMENT PRIMARY KEY,
  marca            VARCHAR(60)  NOT NULL,
  modelo           VARCHAR(80)  NOT NULL,
  ano             SMALLINT     NOT NULL,
  precio           DECIMAL(12,2) NOT NULL,
  concesionario_id INT          NOT NULL,
  creado_en        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_coches_conce (concesionario_id),
  CONSTRAINT fk_coches_concesionario
    FOREIGN KEY (concesionario_id)
    REFERENCES concesionarios(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Añadimos datos a la tabla concesionario
INSERT INTO concesionarios (nombre, ciudad, telefono) VALUES
('AutoPrime',       'Madrid',     '+34 910 000 111'),
('MotorHouse',      'Barcelona',  '+34 930 111 222'),
('Rueda&Run',       'Valencia',   '+34 960 222 333');

SELECT * FROM concesionarios;

-- Añadimos datos a la tabla coches
INSERT INTO `coches` (`marca`, `modelo`, `ano`, `precio`, `concesionario_id`) VALUES
('Toyota', 'Corolla', 2022, 20500.00, 1),
('BMW', '320i', 2021, 32990.00, 1),
('Seat', 'Leon FR', 2023, 25990.00, 2),
('Tesla', 'Model 3', 2024, 38990.00, 2),
('Kia', 'Sportage', 2022, 28950.00, 3);

SELECT * FROM coches;

-- CONSULTAS MULTITABLA
-- 1. Listado de coches con su concesionario (JOIN)
SELECT
  c.id AS coche_id,
  CONCAT(c.marca, ' ', c.modelo) AS coche,
  c.ano AS año,
  CONCAT(co.nombre, ' (', co.ciudad, ')') AS concesionario,
  CONCAT(FORMAT(c.precio, 2), ' €') AS precio_EUR
FROM coches c
JOIN concesionarios co ON c.concesionario_id = co.id
ORDER BY co.ciudad, c.marca, c.modelo;

-- 2. Top 3 coches más caros (LIMIT)
SELECT
  CONCAT(c.marca, ' ', c.modelo) AS coche,
  c.ano AS año,
  CONCAT(FORMAT(c.precio, 2), ' €') AS precio_EUR,
  co.nombre AS concesionario
FROM coches c
JOIN concesionarios co ON co.id = c.concesionario_id
ORDER BY c.precio DESC
LIMIT 3;

-- 3. Precio medio por concesionario (GROUP BY + FORMAT + ORDER BY)
SELECT
  co.nombre AS concesionario,
  co.ciudad,
  CONCAT(FORMAT(AVG(c.precio), 2), ' €') AS precio_medio
FROM concesionarios co
JOIN coches c ON c.concesionario_id = co.id
GROUP BY co.id, co.nombre, co.ciudad
ORDER BY AVG(c.precio) DESC;

-- 4. Buscar coches por texto (LIKE)
SELECT
  CONCAT(c.marca, ' ', c.modelo) AS coche,
  co.nombre AS concesionario,
  CONCAT(FORMAT(c.precio, 2), ' €') AS precio_EUR
FROM coches c
JOIN concesionarios co ON co.id = c.concesionario_id
WHERE CONCAT(c.marca, ' ', c.modelo) LIKE '%Model%'
ORDER BY c.precio DESC;

-- 5. Coches por rango de años (ORDER BY)
SELECT
  CONCAT(c.marca, ' ', c.modelo) AS coche,
  c.ano AS año,
  co.ciudad,
  CONCAT(FORMAT(c.precio, 2), ' €') AS precio_EUR
FROM coches c
JOIN concesionarios co ON co.id = c.concesionario_id
WHERE c.ano BETWEEN 2022 AND 2024
ORDER BY c.ano DESC, c.precio DESC;

-- 6. Conteo de coches por concesionario (LEFT JOIN para ver concesionarios sin coches)
SELECT
  co.nombre AS concesionario,
  co.ciudad,
  COUNT(c.id) AS total_coches
FROM concesionarios co
LEFT JOIN coches c ON c.concesionario_id = co.id
GROUP BY co.id, co.nombre, co.ciudad
ORDER BY total_coches DESC, co.nombre;

-- 7. “Ficha” de concesionario (CONCAT)
SELECT
  co.id,
  CONCAT(co.nombre, ' - ', co.ciudad, ' | ', COALESCE(co.telefono,'(sin teléfono)')) AS ficha
FROM concesionarios co
ORDER BY co.ciudad, co.nombre;

--primer ejercicio
CREATE OR REPLACE VIEW vista_peliculas_info AS
SELECT 
    f.film_id,
    f.title AS nombre_pelicula,
    GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS actores,
    GROUP_CONCAT(DISTINCT c.name SEPARATOR ', ') AS categorias,
    CONCAT(ci.city, ', ', co.country) AS ubicacion_tienda
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
JOIN inventory i ON f.film_id = i.film_id
JOIN store s ON i.store_id = s.store_id
JOIN address ad ON s.address_id = ad.address_id
JOIN city ci ON ad.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
GROUP BY f.film_id, f.title, ci.city, co.country;

--Segundo ejercicio
CREATE OR REPLACE VIEW vista_ganancias_pelicula_tienda AS
SELECT
    f.film_id,
    f.title AS nombre_pelicula,
    s.store_id,
    CONCAT(ci.city, ', ', co.country) AS ubicacion_tienda,
    SUM(p.amount) AS total_ganancias
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN store s ON i.store_id = s.store_id
JOIN address ad ON s.address_id = ad.address_id
JOIN city ci ON ad.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
GROUP BY f.film_id, f.title, s.store_id, ci.city, co.country;


--Tercer ejercicio

DELIMITER //

CREATE PROCEDURE sp_generar_compra (
    IN p_film_id INT,
    IN p_customer_id INT,
    IN p_staff_id INT,
    OUT p_total_out DECIMAL(5,2),
    OUT p_payment_id_out INT
)
BEGIN
    DECLARE v_inventory_id INT;
    DECLARE v_rental_id INT;
    DECLARE v_amount DECIMAL(5,2);
    DECLARE v_payment_date DATETIME;

    SET v_payment_date = NOW();

    -- Obtener inventory_id disponible
    SELECT inventory_id
    INTO v_inventory_id
    FROM inventory
    WHERE film_id = p_film_id
    LIMIT 1;

    -- Insertar en rental
    INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id)
    VALUES (v_payment_date, v_inventory_id, p_customer_id, p_staff_id);

    SET v_rental_id = LAST_INSERT_ID();

    -- Obtener precio
    SELECT rental_rate INTO v_amount
    FROM film
    WHERE film_id = p_film_id;

    -- Insertar en payment
    INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
    VALUES (p_customer_id, p_staff_id, v_rental_id, v_amount, v_payment_date);

    SET p_total_out = v_amount;
    SET p_payment_id_out = LAST_INSERT_ID();
END //

DELIMITER ;



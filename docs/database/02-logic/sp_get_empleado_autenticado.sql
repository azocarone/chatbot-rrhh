-- MySQL Stored Procedure en Railway

CREATE PROCEDURE sp_get_empleado_autenticado(p_input_completo VARCHAR(255)) SELECT id, nombre, email, departamento, puesto, fecha_ingreso, saldo_vacaciones, banco_horas, modalidad FROM empleados WHERE nombre = TRIM(SUBSTRING_INDEX(p_input_completo, ',', 1)) AND email = TRIM(SUBSTRING_INDEX(p_input_completo, ',', -1));

-- Comandos del procedimiento:
-- 
-- SQL: `CALL sp_get_empleado_autenticado('José Azócar, azocarone@freelance.com');`
-- n8n: `CALL sp_get_empleado_autenticado('{{ $json.input }}');`
-- SQL: `DROP PROCEDURE IF EXISTS sp_get_empleado_autenticado;
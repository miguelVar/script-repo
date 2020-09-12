-- BOC
-- ============
-- DESCRIPCION:
-- Creacion de procedimientos y funciones para calcular la nomina
-- Tablas involucradas:
-- EMPLOYEES:   Empleados
-- NUM_DAYS:    Numero de dias
-- JOB_YEARS:   Anios
-- JOBS:        Trabajos
-- ============
-- PARAMETROS
-- ============
--
-- ============
-- HISTORIA
-- ============
-- 12/09/2020 MVARGAS: Creacion
-- NOTA: Uso de procedimientos y funciones almacenadas en la base de datos para el ejercicio Nomina
-- EOC
--
CREATE OR REPLACE FUNCTION traer_salario_emp(pidempleado employees.employee_id%TYPE) RETURN NUMBER
    IS
    myrespsalario NUMBER;
    myidempleado  employees.employee_id%TYPE := pidempleado;
BEGIN
    BEGIN
        SELECT
            salary
        INTO myrespsalario
        FROM
            employees
        WHERE
            employee_id = myidempleado;
    EXCEPTION
        WHEN OTHERS THEN myrespsalario := 0;
    END;
    --
    RETURN (myrespsalario);
END;
--
-- Funcion para traer el numero de dias laborados
CREATE OR REPLACE FUNCTION traer_dias_laborados_emp(pidempleado employees.employee_id%TYPE) RETURN NUMBER
    IS
    myrespdiaslaborados NUMBER;
    myidempleado        employees.employee_id%TYPE := pidempleado;
BEGIN
    BEGIN
        SELECT
            num_days
        INTO myrespdiaslaborados
        FROM
            num_days
        WHERE
            employee_id = myidempleado;
    EXCEPTION
        WHEN OTHERS THEN myrespdiaslaborados := 0;
    END;
    --
    RETURN (myrespdiaslaborados);
END;
--
-- Funcion para calcular el salario basico
CREATE OR REPLACE FUNCTION obtener_asignacion_basica(psalario employees.salary%TYPE, pdiaslaborados NUMBER) RETURN NUMBER
    IS
    myrespasignacion  NUMBER;
    mysalario         employees.salary%TYPE := psalario;
    mydiaslaborados   NUMBER                := pdiaslaborados;
    dias_mes CONSTANT NUMBER                := 30;
    asignacion_basica number;
BEGIN
    BEGIN
        asignacion_basica := ((mysalario / dias_mes) * mydiaslaborados);
    EXCEPTION
        WHEN OTHERS THEN myrespasignacion := 0;
    END;
    --
    RETURN (asignacion_basica);
END;
--
-- Funcion para traer el numero de anios laborados
CREATE OR REPLACE FUNCTION traer_anios_laborados(pidempleado employees.employee_id%TYPE) RETURN NUMBER
    IS
    myresanioslaborados NUMBER;
BEGIN
    BEGIN
        SELECT
            years
        INTO myresanioslaborados
        FROM
            job_years
        WHERE
            employee_id = pidempleado;
    EXCEPTION
        WHEN OTHERS THEN myresanioslaborados := 0;
    END;
    RETURN (myresanioslaborados);
END;
-- Funcion para traer el cargo del empleado
CREATE OR REPLACE FUNCTION traer_cargo_emp(pidempleado employees.employee_id%TYPE) RETURN VARCHAR2
    IS
    myrespcargo  VARCHAR2(100);
    myidempleado employees.employee_id%TYPE := pidempleado;
BEGIN
    BEGIN
        SELECT
            j.job_title
        INTO myrespcargo
        FROM
            jobs j
                JOIN employees e ON e.job_id = j.job_id AND e.employee_id = myidempleado;
    EXCEPTION
        WHEN OTHERS THEN myrespcargo := 'Invalid ID';
    END;
    RETURN (myrespcargo);
END;

--procedimiento para saber si es jefe
CREATE OR REPLACE PROCEDURE obtain_prima_servicio(cargo_emp IN varchar2, salario_basico IN number,
                                                  prima_servicio OUT number)
AS
BEGIN

    IF cargo_emp LIKE '%Manager%' THEN
        prima_servicio := salario_basico * 0.20;
    ELSE
        prima_servicio := 0;
    END IF;
END;

--procedimiento para saber calcular subsidio de alimentacion
CREATE OR REPLACE PROCEDURE obtain_subsidio_alimentacion(salario IN number, dias_laborados IN number,
                                                         subsidio_alimentacion OUT number)
AS
BEGIN

    IF salario < 3000 THEN
        subsidio_alimentacion := (100 / 30) * dias_laborados;
    ELSE
        subsidio_alimentacion := 0;
    END IF;
END;

--procedimiento para saber calcular subsidio de alimentacion
CREATE OR REPLACE PROCEDURE obtain_subsidio_transporte(salario IN number, dias_laborados IN number,
                                                       subsidio_transporte OUT number)
AS
BEGIN

    IF salario < 3000 THEN
        subsidio_transporte := (80 / 30) * dias_laborados;
    ELSE
        subsidio_transporte := 0;
    END IF;
END;

--procedimiento para saber calcular total_devengado
CREATE OR REPLACE PROCEDURE obtain_total_devengado(salario_basico IN number, prima_antiguedad IN number,
                                                   prima_servicio IN number, subs_alimentaicon IN number,
                                                   subs_trensporte IN number, total_devengado OUT number)
AS
BEGIN
    total_devengado := salario_basico + prima_antiguedad + prima_servicio + subs_alimentaicon + subs_trensporte;
END;

--procedimiento para saber calcular subsidio de alimentacion
CREATE OR REPLACE PROCEDURE obtain_salud(salario_basico IN number, total_salud OUT number)
AS
BEGIN
    total_salud := salario_basico * 0.12;
END;

--procedimiento para saber calcular pension
CREATE OR REPLACE PROCEDURE obtain_pension(salario_basico IN number, total_pension OUT number)
AS
BEGIN
    total_pension := salario_basico * 0.16;
END;

--procedimiento para saber calcular retefuente
CREATE OR REPLACE PROCEDURE obtain_retefuente(salario IN number, salario_basico IN number, retefuente OUT number)
AS
BEGIN

    IF salario BETWEEN 0 AND 1999 THEN
        retefuente := salario_basico * 0;
    ELSIF salario BETWEEN 2000 AND 4999 THEN
        retefuente := salario_basico * 0.05;
    ELSIF salario BETWEEN 5000 AND 8999 THEN
        retefuente := salario_basico * 0.1;
    ELSE
        retefuente := salario_basico * 0.15;
    END IF;
END;

--procedimiento para calcular total_deudcido
CREATE OR REPLACE PROCEDURE obtain_total_deducido(salud IN number, pension IN number, retefuente IN number,
                                                  total_deducido OUT number)
AS
BEGIN
    total_deducido := salud + pension + retefuente;
END;
--
--procedimiento para calcular valor_neto
CREATE OR REPLACE PROCEDURE obtain_valor_neto(total_devengado IN number, total_deducido IN number,
                                              total_neto OUT number)
AS
BEGIN
    total_neto := total_devengado - total_deducido;
END;

--procedimiento para calcular valor_neto
CREATE OR REPLACE PROCEDURE obtain_prima_antiguedad(antiguedad IN number, salario_basico IN number,
                                                    prima_antiguedad OUT number)
AS
BEGIN
    IF antiguedad BETWEEN 0 AND 10 THEN
        prima_antiguedad := salario_basico * 0.1;
    ELSIF antiguedad BETWEEN 11 AND 20 THEN
        prima_antiguedad := salario_basico * 0.15;
    ELSE
        prima_antiguedad := salario_basico * 0.20;
    END IF;
END;

CREATE OR REPLACE PROCEDURE calcularnomina(valor_neto OUT number)
AS
    salario_basico        number := 0;
    prima_antiguedad      number := 0;
    prima_servicios       number := 0;
    subsidio_alimentacion number := 0;
    subsidio_transporte   number := 0;
    total_devengado       number := 0;
    salud                 number := 0;
    pension               number := 0;
    retefuente            number := 0;
    total_deducido        number := 0;
    codigo                number := 0;
    CURSOR employee_data IS SELECT
                                e.employee_id
                            FROM
                                employees e;
    c_data                employee_data%ROWTYPE;
BEGIN
    DELETE from payroll;
    FOR c_data IN employee_data
        LOOP
            salario_basico := 0;
            prima_antiguedad := 0;
            prima_servicios := 0;
            subsidio_alimentacion := 0;
            subsidio_transporte := 0;
            total_devengado := 0;
            salud := 0;
            pension := 0;
            retefuente := 0;
            total_deducido := 0;
            valor_neto := 0;
            salario_basico := obtener_asignacion_basica(traer_salario_emp(c_data.employee_id),
                                                        traer_dias_laborados_emp(c_data.employee_id));
            obtain_prima_antiguedad(traer_anios_laborados(c_data.employee_id),
                                    salario_basico, prima_antiguedad);
            obtain_prima_servicio(traer_cargo_emp(c_data.employee_id), salario_basico, prima_servicios);
            obtain_subsidio_alimentacion(traer_salario_emp(c_data.employee_id),
                                         traer_dias_laborados_emp(c_data.employee_id), subsidio_alimentacion);
            obtain_subsidio_transporte(traer_salario_emp(c_data.employee_id),
                                       traer_dias_laborados_emp(c_data.employee_id), subsidio_transporte);
            obtain_total_devengado(salario_basico, prima_antiguedad, prima_servicios, subsidio_alimentacion,
                                   subsidio_transporte, total_devengado);
            obtain_salud(salario_basico, salud);

            obtain_pension(salario_basico, pension);
            obtain_retefuente(traer_salario_emp(c_data.employee_id), salario_basico, retefuente);
            obtain_total_deducido(salud, pension, retefuente, total_deducido);
            obtain_valor_neto(total_devengado, total_deducido, valor_neto);
            dbms_output.put_line(valor_neto || ' ' || c_data.employee_id);

            IF salario_basico > 0 THEN
                codigo := 1;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (c_data.employee_id, codigo, salario_basico);
            END IF;
            IF prima_antiguedad > 0 THEN
                codigo := 2;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (c_data.employee_id, codigo, prima_antiguedad);
            END IF;
            IF prima_servicios > 0 THEN
                codigo := 3;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (c_data.employee_id, codigo, prima_servicios);
            END IF;
            IF subsidio_alimentacion > 0 THEN
                codigo := 4;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (c_data.employee_id, codigo, subsidio_alimentacion);
            END IF;
            IF subsidio_transporte > 0 THEN
                codigo := 5;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (c_data.employee_id, codigo, subsidio_transporte);
            END IF;
            IF total_devengado > 0 THEN
                codigo := 10;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (c_data.employee_id, codigo, total_devengado);
            END IF;
            IF salud > 0 THEN
                codigo := 11;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (c_data.employee_id, codigo, salud);
            END IF;
            IF pension > 0 THEN
                codigo := 12;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (c_data.employee_id, codigo, pension);
            END IF;
            IF retefuente > 0 THEN
                codigo := 13;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (c_data.employee_id, codigo, retefuente);
            END IF;
            IF total_deducido > 0 THEN
                codigo := 20;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (c_data.employee_id, codigo, total_deducido);
            END IF;
            IF valor_neto > 0 THEN
                codigo := 30;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (c_data.employee_id, codigo, valor_neto);
            END IF;
        END LOOP;
END;
--
--
--
--
DECLARE
    valor_neto number := 0;
BEGIN
    calcularnomina(valor_neto);
--     dbms_output.PUT_LINE(valor_neto);
END;

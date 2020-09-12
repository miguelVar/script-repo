-- BOC
-- ============
-- DESCRIPCION:
-- Creacion de package que contiene procedimientos y funciones que permiten calcular la nomina
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
-- NOTA: Uso de package para organizacion de codigo y poder reallizar el ejercicio Nomina
-- EOC
--
    CREATE OR REPLACE PACKAGE pkg_nomina
IS
    --
    FUNCTION traer_salario_emp(pidempleado number) RETURN NUMBER;
    FUNCTION traer_dias_laborados_emp(pidempleado employees.employee_id%TYPE) RETURN NUMBER;
    FUNCTION obtener_asignacion_basica(psalario employees.salary%TYPE, pdiaslaborados NUMBER) RETURN NUMBER;
    FUNCTION traer_anios_laborados(pidempleado employees.employee_id%TYPE) RETURN NUMBER;
    FUNCTION obtener_cargo_emp(pidempleado employees.employee_id%TYPE) RETURN VARCHAR2;
    PROCEDURE obtain_calculo_prima_antiguedad(antiguedad IN NUMBER, salario_basico IN NUMBER,
                                              prima_antiguedad OUT NUMBER);
    PROCEDURE obtain_prima_servicios(pcargo IN VARCHAR2, salariobasico IN NUMBER, primaservicio OUT NUMBER);
    PROCEDURE obtain_subsidio_alimentacion(psalario IN employees.salary%TYPE, pdiaslaborados IN NUMBER,
                                           subsidio_alimentacion OUT NUMBER);
    PROCEDURE obtain_subsidio_transporte(psalario IN employees.salary%TYPE, pdiaslaborados IN NUMBER,
                                         subsidio_transporte OUT NUMBER);
    PROCEDURE obtain_total_devengado(salario_basico IN number, prima_antiguedad IN number,
                                     prima_servicio IN number, subs_alimentaicon IN number,
                                     subs_trensporte IN number, total_devengado OUT number);
    PROCEDURE obtener_salud(pasignacionbasica IN NUMBER, salud OUT NUMBER);
    PROCEDURE obtener_pension(pasignacionbasica IN NUMBER, pension OUT NUMBER);
    PROCEDURE obtener_retefuente(psalario IN employees.salary%TYPE, pasignacionbasica IN NUMBER, retefuente OUT NUMBER);
    PROCEDURE obtain_total_deducido(salud IN number, pension IN number, retefuente IN number,
                                    total_deducido OUT number);
    PROCEDURE obtener_total_neto(ptotdevengado IN NUMBER, ptotdeducido IN NUMBER, valor_neto OUT NUMBER);
    --
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_nomina
IS
    --
    -- Funcion para buscar el salario del empleado
    FUNCTION traer_salario_emp(pidempleado number) RETURN NUMBER
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
    FUNCTION traer_dias_laborados_emp(pidempleado employees.employee_id%TYPE) RETURN NUMBER
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
    FUNCTION obtener_asignacion_basica(psalario employees.salary%TYPE, pdiaslaborados NUMBER) RETURN NUMBER
        IS
        asignacion_basica NUMBER;
        myrespasignacion  NUMBER;
        mysalario         employees.salary%TYPE := psalario;
        mydiaslaborados   NUMBER                := pdiaslaborados;
        dias_mes CONSTANT NUMBER                := 30;
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
    FUNCTION traer_anios_laborados(pidempleado employees.employee_id%TYPE) RETURN NUMBER
        IS
        myresanioslaborados NUMBER;
        myidempleado        employees.employee_id%TYPE := pidempleado;
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
    --
    -- Funcion para traer el cargo
    FUNCTION obtener_cargo_emp(pidempleado employees.employee_id%TYPE) RETURN VARCHAR2
        IS
        cargo        VARCHAR2(100);
        myidempleado employees.employee_id%TYPE := pidempleado;
    BEGIN
        BEGIN
            SELECT
                job_title
            INTO cargo
            FROM
                jobs
                    INNER JOIN employees e ON jobs.job_id = e.job_id
            WHERE
                employee_id = myidempleado;
        EXCEPTION
            WHEN OTHERS THEN cargo := '';
        END;
        --
        RETURN (cargo);
    END;
    --
    -- Procedimiento para calcular la prima de antiguedad
    PROCEDURE obtain_calculo_prima_antiguedad(antiguedad IN NUMBER, salario_basico IN NUMBER,
                                              prima_antiguedad OUT NUMBER)
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
    --
    --procedimiento para calcular prima de servicios por jefatura
    PROCEDURE obtain_prima_servicios(pcargo IN VARCHAR2, salariobasico IN NUMBER, primaservicio OUT NUMBER)
    AS
    BEGIN
        IF pcargo LIKE '%Manager%' THEN
            primaservicio := salariobasico * 0.20 ;
        ELSE
            primaservicio := 0;
        END IF;
    END;
    --
    -- Procedimiento para calcular el subsidio de alimentacion
    PROCEDURE obtain_subsidio_alimentacion(psalario IN employees.salary%TYPE, pdiaslaborados IN NUMBER,
                                           subsidio_alimentacion OUT NUMBER)
    AS
    BEGIN
        IF psalario < 3000 THEN
            subsidio_alimentacion := (100 / 30) * pdiaslaborados;
        ELSE
            subsidio_alimentacion := 0;
        END IF;
    END;
    --
    -- Procedimiento para calcular el subsidio de transporte
    PROCEDURE obtain_subsidio_transporte(psalario IN employees.salary%TYPE, pdiaslaborados IN NUMBER,
                                         subsidio_transporte OUT NUMBER)
    AS
    BEGIN
        IF psalario < 3000 THEN
            subsidio_transporte := (80 / 30) * pdiaslaborados;
        ELSE
            subsidio_transporte := 0;
        END IF;
    END;
    --
    --procedimiento para saber calcular total_devengado
    PROCEDURE obtain_total_devengado(salario_basico IN number, prima_antiguedad IN number,
                                     prima_servicio IN number, subs_alimentaicon IN number,
                                     subs_trensporte IN number, total_devengado OUT number)
    AS
    BEGIN
        total_devengado := salario_basico + prima_antiguedad + prima_servicio + subs_alimentaicon + subs_trensporte;
    END;
    --
    -- Procedimiento para calcular salud
    PROCEDURE obtener_salud(pasignacionbasica IN NUMBER, salud OUT NUMBER)
    AS
    BEGIN
        salud := pasignacionbasica * 0.12;
    END;
    --
    -- Procedimiento para calcular pension
    PROCEDURE obtener_pension(pasignacionbasica IN NUMBER, pension OUT NUMBER)
    AS
    BEGIN
        pension := pasignacionbasica * 0.16;
    END;
    --
    -- Procedimiento para calcular la retefuente
    PROCEDURE obtener_retefuente(psalario IN employees.salary%TYPE, pasignacionbasica IN NUMBER, retefuente OUT NUMBER)
    AS
    BEGIN
        IF psalario >= 0 AND psalario <= 1999 THEN
            retefuente := pasignacionbasica * 0;
        ELSIF psalario >= 2000 AND psalario <= 4999 THEN
            retefuente := pasignacionbasica * 0.05;
        ELSIF psalario >= 5000 AND psalario <= 8999 THEN
            retefuente := pasignacionbasica * 0.10;
        ELSE
            retefuente := pasignacionbasica * 0.15;
        END IF;
    END;
    --
--procedimiento para calcular total_deudcido
    PROCEDURE obtain_total_deducido(salud IN number, pension IN number, retefuente IN number,
                                    total_deducido OUT number)
    AS
    BEGIN
        total_deducido := salud + pension + retefuente;
    END;
    --
    -- Procedimiento para calcular el total neto
    PROCEDURE obtener_total_neto(ptotdevengado IN NUMBER, ptotdeducido IN NUMBER, valor_neto OUT NUMBER)
    AS
    BEGIN
        valor_neto := ptotdevengado - ptotdeducido;
    END;
END;
--

DECLARE
    CURSOR employee_data IS SELECT
                                e.employee_id
                            FROM
                                employees e;
    c_data                employee_data%ROWTYPE;
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
    valor_neto            number := 0;
    codigo                number := 0;
BEGIN
    DELETE FROM payroll;
    FOR c_data IN employee_data
        LOOP
            salario_basico := pkg_nomina.obtener_asignacion_basica(pkg_nomina.traer_salario_emp(c_data.employee_id),
                                                                   pkg_nomina.traer_dias_laborados_emp(c_data.employee_id));
            pkg_nomina.obtain_calculo_prima_antiguedad(pkg_nomina.traer_anios_laborados(c_data.employee_id),
                                                       salario_basico, prima_antiguedad);
            pkg_nomina.obtain_prima_servicios(pkg_nomina.obtener_cargo_emp(c_data.employee_id), salario_basico,
                                              prima_servicios);
            pkg_nomina.obtain_subsidio_alimentacion(pkg_nomina.traer_salario_emp(c_data.employee_id),
                                                    pkg_nomina.traer_dias_laborados_emp(c_data.employee_id),
                                                    subsidio_alimentacion);
            pkg_nomina.obtain_subsidio_transporte(pkg_nomina.traer_salario_emp(c_data.employee_id),
                                                  pkg_nomina.traer_dias_laborados_emp(c_data.employee_id),
                                                  subsidio_transporte);
            pkg_nomina.obtain_total_devengado(salario_basico, prima_antiguedad, prima_servicios, subsidio_alimentacion,
                                              subsidio_transporte, total_devengado);
            pkg_nomina.obtener_salud(salario_basico, salud);
            pkg_nomina.obtener_pension(salario_basico, pension);
            pkg_nomina.obtener_retefuente(pkg_nomina.traer_salario_emp(c_data.employee_id), salario_basico,
                                          retefuente);
            pkg_nomina.obtain_total_deducido(salud, pension, retefuente, total_deducido);
            pkg_nomina.obtener_total_neto(total_devengado, total_deducido, valor_neto);

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
                INSERT INTO payroll(employee_id, pyd, pyd_value)
                VALUES (c_data.employee_id, codigo, subsidio_alimentacion);
            END IF;
            IF subsidio_transporte > 0 THEN
                codigo := 5;
                INSERT INTO payroll(employee_id, pyd, pyd_value)
                VALUES (c_data.employee_id, codigo, subsidio_transporte);
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

SELECT *
FROM
    payroll
WHERE
    employee_id = 105;
SELECT
    sum(pyd_value)
FROM
    payroll
WHERE
    pyd = 30;
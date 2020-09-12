-- BOC
-- ============
-- DESCRIPCION:
-- Uso de excepciones en PL/SQL para calcular el ejercicio de Nomina
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
-- 12/09/2020 MVARGAS(OAPS): Creacion
-- NOTA: Uso de excepciones ejercicio Nomina
-- EOC
DECLARE
    --
    -- Variables para las funciones
    --
    mi_id_empleado        employees.employee_id%TYPE;
    mi_salario            NUMBER := 0;
    mis_dias_laborados    NUMBER := 0;
    dias_mes CONSTANT     NUMBER := 30;
    asignacion_basica     mi_salario%TYPE;
    anios_laborados       NUMBER;
    cargo                 VARCHAR2(100);
    --
    -- Conceptos
    --
    prima_antiguedad      mi_salario%TYPE;
    prima_servicios       mi_salario%TYPE;
    subsidio_alimentacion mi_salario%TYPE;
    subsidio_transporte   mi_salario%TYPE;
    valor_devengado       mi_salario%TYPE;
    salud                 mi_salario%TYPE;
    pension               mi_salario%TYPE;
    retefuente            mi_salario%TYPE;
    valor_deducido        mi_salario%TYPE;
    valor_neto            mi_salario%TYPE;
    --
    -- Codigos sentencia
    --
    codigo                NUMBER;
    --
    -- Declaramos el cursor
    CURSOR c_data IS
        SELECT
            e.employee_id
        FROM
            employees e;
    --
    -- Declaramos las funciones
    --
    -- Funcion para buscar el salario del empleado
    FUNCTION traer_salario_emp(pidempleado employees.employee_id%TYPE) RETURN NUMBER
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
    -- Funcion para obtener el total devengado
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
--
BEGIN
    <<inicio_ejecucion>>
    DELETE
    FROM
        payroll;
    FOR r_data IN c_data
        LOOP
            mi_id_empleado := r_data.employee_id;
            --
            --Llamamos y usamos las funciones
            --
            mi_salario := traer_salario_emp(mi_id_empleado);
            mis_dias_laborados := traer_dias_laborados_emp(mi_id_empleado);
            anios_laborados := traer_anios_laborados(mi_id_empleado);
            cargo := obtener_cargo_emp(mi_id_empleado);

            --Inicio calculos de conceptos
            asignacion_basica := obtener_asignacion_basica(mi_salario, mis_dias_laborados);
            obtain_calculo_prima_antiguedad(anios_laborados, asignacion_basica, prima_antiguedad);
            obtain_prima_servicios(cargo, asignacion_basica, prima_servicios);
            obtain_subsidio_alimentacion(mi_salario, mis_dias_laborados, subsidio_alimentacion);
            obtain_subsidio_transporte(mi_salario, mis_dias_laborados, subsidio_transporte);
            obtain_total_devengado(asignacion_basica, prima_antiguedad, prima_servicios, subsidio_alimentacion,
                                   subsidio_transporte, valor_devengado);
            obtener_salud(asignacion_basica, salud);
            obtener_pension(asignacion_basica, pension);
            obtener_retefuente(mi_salario, asignacion_basica, retefuente);
            obtain_total_deducido(salud, pension, retefuente, valor_deducido);
            obtener_total_neto(valor_devengado, valor_deducido, valor_neto);
            --
            --
            IF asignacion_basica > 0 THEN
                codigo := 1;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id_empleado, codigo, asignacion_basica);
            END IF;
            IF prima_antiguedad > 0 THEN
                codigo := 2;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id_empleado, codigo, prima_antiguedad);
            END IF;
            IF prima_servicios > 0 THEN
                codigo := 3;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id_empleado, codigo, prima_servicios);
            END IF;
            IF subsidio_alimentacion > 0 THEN
                codigo := 4;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id_empleado, codigo, subsidio_alimentacion);
            END IF;
            IF subsidio_transporte > 0 THEN
                codigo := 5;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id_empleado, codigo, subsidio_transporte);
            END IF;
            IF valor_devengado > 0 THEN
                codigo := 10;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id_empleado, codigo, valor_devengado);
            END IF;
            IF salud > 0 THEN
                codigo := 11;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id_empleado, codigo, salud);
            END IF;
            IF pension > 0 THEN
                codigo := 12;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id_empleado, codigo, pension);
            END IF;
            IF retefuente > 0 THEN
                codigo := 13;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id_empleado, codigo, retefuente);
            END IF;
            IF valor_deducido > 0 THEN
                codigo := 20;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id_empleado, codigo, valor_deducido);
            END IF;
            IF valor_neto > 0 THEN
                codigo := 30;
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id_empleado, codigo, valor_neto);
            END IF;
        END LOOP;
END;
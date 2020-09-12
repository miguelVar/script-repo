DECLARE
    mi_cedula NUMBER := 203;
    mi_nombre VARCHAR2(100);
    mi_salida NUMBER := 0;
--
    FUNCTION get_emp_name(pcedula employees.employee_id%TYPE) RETURN VARCHAR2
        IS
        mystring VARCHAR2(100);
        mycedula employees.employee_id%TYPE := pcedula;
--
    BEGIN
        SELECT
            first_name || ' ' || last_name
        INTO mystring
        FROM
            employees
        WHERE
            employee_id = mycedula;
        --
        RETURN (mystring);
    EXCEPTION
        WHEN OTHERS THEN mystring := 'Invalid Id';
        --RAISE_APPLICATION_ERROR(-20000, myString);
        RETURN (mystring);
    END;

    --
    PROCEDURE exec_operation(pnum1 NUMBER, pnum2 NUMBER, pnumber3 OUT NUMBER)
    AS
    BEGIN
        pnumber3 := pnum1 * pnum2;
    END;
--
BEGIN
    --
    --mi_nombre := get_emp_name(mi_cedula);
    --
    --DBMS_OUTPUT.PUT_LINE(mi_nombre);
    dbms_output.put_line(get_emp_name(pcedula=>mi_cedula));
    --
    exec_operation(1, 2, mi_salida);
END;
--


----------------------------------------------------------------
DROP FUNCTION get_salary;
CREATE FUNCTION get_salary(id IN number)
    RETURN number
    IS
    response_salary number;
BEGIN
    SELECT
        em.salary
    INTO response_salary
    FROM
        employees em
    WHERE
        em.employee_id = id;
    RETURN response_salary;
END;

SELECT
    get_salary(100)
FROM
    employees;
SELECT *
FROM
    employees
WHERE
    employee_id = 100;

DROP PROCEDURE salario_basico;

CREATE PROCEDURE salario_basico(em_id IN number, basic_salary IN OUT number)
    IS
BEGIN
    BEGIN
        SELECT
            nd.num_days
        INTO basic_salary
        FROM
            employees e
                INNER JOIN num_days nd ON e.employee_id = nd.employee_id
                INNER JOIN job_years jy ON e.employee_id = jy.employee_id
                INNER JOIN jobs j ON e.job_id = j.job_id
        WHERE
            e.employee_id = em_id;
--         basic_salary:=(salario/30)*dias_laborados;
    END;
END;

DECLARE
    salida number := 0;
BEGIN

    dbms_output.put_line(salario_basico(100, salida));
END;

DROP PROCEDURE obtain_ismanager;

CREATE PROCEDURE obtain_ismanager(id IN number, outsalary OUT boolean)
AS
    cargo varchar2(100);
BEGIN
    SELECT
        j.job_title
    INTO cargo
    FROM
        employees e
            INNER JOIN num_days nd ON e.employee_id = nd.employee_id
            INNER JOIN job_years jy ON e.employee_id = jy.employee_id
            INNER JOIN jobs j ON e.job_id = j.job_id
    WHERE
        e.employee_id = id;
    IF cargo LIKE '%Manager%' THEN
        outsalary := TRUE;
    ELSE
        outsalary := FALSE;
    END IF;
END;



CREATE OR REPLACE PROCEDURE obtain_prima_servicios(cargo_emp IN varchar2, salariobasico IN number, primaservicio OUT number)
AS
BEGIN
    IF cargo_emp LIKE '%Manager%' THEN
        primaservicio := salariobasico * 0.20 ;
    ELSE
        primaservicio := 0;
    END IF;
END;


DECLARE
    id        number := 108;
    salaryout number := 0;
BEGIN
    obtain_prima_servicios('presidente Manager', 24000, salaryout);
--     dbms_output.PUT_LINE('-->'||sys.diutil.bool_to_int(salaryout));
    dbms_output.put_line('-->' || salaryout);
END;



SELECT
    e.employee_id
  , j.job_title
FROM
    employees e
        INNER JOIN num_days nd ON e.employee_id = nd.employee_id
        INNER JOIN job_years jy ON e.employee_id = jy.employee_id
        INNER JOIN jobs j ON e.job_id = j.job_id
WHERE
    j.job_title LIKE '%Manager%';


--------------------------------------------
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
-- 05/09/2020 JDCACERESA(OAPS): Creacion
-- NOTA: Uso de excepciones ejercicio Nomina
-- EOC
DECLARE
    --
    -- Variables para las funciones
    --
    mi_id_empleado     NUMBER := ?;
    mi_salario         NUMBER := 0;
    mis_dias_laborados NUMBER := 0;
    antiguedad         Number := 0;
    ismanager          boolean;
    dias_mes CONSTANT  NUMBER := 30;
    asignacion_basica  mi_salario%TYPE;
    prima_antiguedad   Number := 0;
    cargo_emp          varchar2(100);
    --
    -- Declaramos la funcion
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
    -- Funcion para traer la antiguedad
    FUNCTION traer_antiguedad_emp(pidempleado employees.employee_id%TYPE) RETURN NUMBER
        IS
        anitiguedad  NUMBER;
        myidempleado employees.employee_id%TYPE := pidempleado;
    BEGIN
        BEGIN
            SELECT
                years
            INTO anitiguedad
            FROM
                job_years
            WHERE
                employee_id = myidempleado;
        EXCEPTION
            WHEN OTHERS THEN anitiguedad := 0;
        END;
        --
        RETURN (anitiguedad);
    END;
    --
    -- Funcion para calcular el salario basico
    FUNCTION obtener_asignacion_basica(psalario employees.salary%TYPE, pdiaslaborados NUMBER) RETURN NUMBER
        IS
        myrespasignacion NUMBER;
        mysalario        employees.salary%TYPE := psalario;
        mydiaslaborados  NUMBER                := pdiaslaborados;
    BEGIN
        BEGIN
            asignacion_basica := ((mysalario / 30) * mydiaslaborados);
        EXCEPTION
            WHEN OTHERS THEN myrespasignacion := 0;
        END;
        --
        RETURN (asignacion_basica);
    END;
    --
    -- Funcion para calcular la prima de antiguedad
    FUNCTION obtener_prima_antiguedad(psalario employees.salary%TYPE, antiguedad_years NUMBER) RETURN NUMBER
        IS
        mysalario employees.salary%TYPE := psalario;
    BEGIN
        BEGIN

            IF antiguedad_years BETWEEN 0 AND 10 THEN
                prima_antiguedad := mysalario * 0.1;
            ELSIF antiguedad_years BETWEEN 11 AND 20 THEN
                prima_antiguedad := mysalario * 0.15;
            ELSE
                prima_antiguedad := mysalario * 0.20;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN prima_antiguedad := 0;
        END;
        --
        RETURN (prima_antiguedad);
    END;
    --
    -- Funcion para traer el CARGO
    FUNCTION obtener_cargo_emp(pidempleado employees.employee_id%TYPE) RETURN varchar2
        IS
        cargo        varchar2(100);
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
BEGIN
    mi_salario := traer_salario_emp(mi_id_empleado);
    mis_dias_laborados := traer_dias_laborados_emp(mi_id_empleado);
    antiguedad := traer_antiguedad_emp(mi_id_empleado);
    asignacion_basica := obtener_asignacion_basica(mi_salario, mis_dias_laborados);
    prima_antiguedad := obtener_prima_antiguedad(asignacion_basica, antiguedad);
    cargo_emp := obtener_cargo_emp(mi_id_empleado);

    --
    dbms_output.put_line(
                mi_salario || ' ' || mis_dias_laborados || ' ' || asignacion_basica || ' ' || antiguedad || ' ' ||
                prima_antiguedad || ' ' || cargo_emp);
END;

----------------------------
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
-- 05/09/2020 JDCACERESA(OAPS): Creacion
-- NOTA: Uso de excepciones ejercicio Nomina
-- EOC
DECLARE
    --
    -- Variables para las funciones
    --
    mi_id_empleado     employees.employee_id%TYPE;
    mi_salario         NUMBER := 0;
    mis_dias_laborados NUMBER := 0;
    dias_mes CONSTANT  NUMBER := 30;
    asignacion_basica  mi_salario%TYPE;
    anios_laborados    NUMBER;
    cargo              VARCHAR2(100);
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
    -- Funcion para traer el cargo del empleado
    FUNCTION traer_cargo_emp(pidempleado employees.employee_id%TYPE) RETURN VARCHAR2
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
        END;
    EXCEPTION
        WHEN OTHERS THEN myrespcargo := 'Invalid ID';
        RETURN (myrespcargo);
    END;
--
BEGIN
    <<inicio_ejecucion>>
    FOR r_data IN c_data
        LOOP
            mi_id_empleado := r_data.employee_id;
            --cargo                  := r_data.job_title;
            --
            --Llamamos y usamos las funciones
            --
            mi_salario := traer_salario_emp(mi_id_empleado);
            mis_dias_laborados := traer_dias_laborados_emp(mi_id_empleado);
            anios_laborados := traer_anios_laborados(mi_id_empleado);
            cargo := traer_cargo_emp(mi_id_empleado);

            --Inicio calculos de conceptos
            asignacion_basica := obtener_asignacion_basica(mi_salario, mis_dias_laborados);
            --
            dbms_output.put_line(
                        mi_salario || ' ' || mis_dias_laborados || ' ' || asignacion_basica || ' ' || anios_laborados ||
                        ' ' || cargo);
        END LOOP;

END;
/
------------------------------------------------------------------------------------------------
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
-- 05/09/2020 JDCACERESA(OAPS): Creacion
-- NOTA: Uso de excepciones ejercicio Nomina
-- EOC
DECLARE
    --
    -- Variables para las funciones
    --
    mi_id_empleado     employees.employee_id%TYPE;
    mi_salario         NUMBER := 0;
    mis_dias_laborados NUMBER := 0;
    dias_mes CONSTANT  NUMBER := 30;
    asignacion_basica  mi_salario%TYPE;
    anios_laborados    NUMBER;
    cargo              VARCHAR2(100);
    outsalary          BOOLEAN;
    --
    -- Codigos sentencia
    --
    codigo             NUMBER;
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
    --procedimiento para saber si es jefe
    PROCEDURE obtain_ismanager(id IN number, outsalary OUT BOOLEAN)
    AS
        cargo varchar2(100);
    BEGIN
        SELECT
            j.job_title
        INTO cargo
        FROM
            employees e
                INNER JOIN num_days nd ON e.employee_id = nd.employee_id
                INNER JOIN job_years jy ON e.employee_id = jy.employee_id
                INNER JOIN jobs j ON e.job_id = j.job_id
        WHERE
            e.employee_id = id;

        IF cargo LIKE '%Manager%' THEN
            outsalary := TRUE;
        ELSE
            outsalary := FALSE;
        END IF;
    END;
    --
    -- Procedimiento para calcular la prima de antiguedad
    --PROCEDURE exec_calculo_prima_antiguedad (pAniosLaborados NUMBER, pAsignacionBasica NUMBER, respPrimaAnt OUT NUMBER)
    --AS
    --   BEGIN
    --  IF pAniosLaborados >= 0 THEN
    --    respPrimaAnt := pAsignacionBasica * 0.10;
    --  END IF;
    --END;
--
BEGIN
    <<inicio_ejecucion>>
    FOR r_data IN c_data
        LOOP
            mi_id_empleado := r_data.employee_id;
            --
            --Llamamos y usamos las funciones
            --
            mi_salario := traer_salario_emp(mi_id_empleado);
            mis_dias_laborados := traer_dias_laborados_emp(mi_id_empleado);
            anios_laborados := traer_anios_laborados(mi_id_empleado);
            outsalary := obtain_ismanager(mi_id_empleado, outsalary);

            --Inicio calculos de conceptos
            codigo := 1;
            asignacion_basica := obtener_asignacion_basica(mi_salario, mis_dias_laborados);
            --
            dbms_output.put_line(
                        mi_id_empleado || ' ' || mi_salario || ' ' || mis_dias_laborados || ' ' || asignacion_basica ||
                        ' ' || anios_laborados || ' ' || sys.diutil.bool_to_int(outsalary));
        END LOOP;

END;
/
/**









 */

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
-- 05/09/2020 JDCACERESA(OAPS): Creacion
-- NOTA: Uso de excepciones ejercicio Nomina
-- EOC
DECLARE
    --
    -- Variables para las funciones
    --
    mi_id_empleado     employees.employee_id%TYPE;
    mi_salario         NUMBER := 0;
    mis_dias_laborados NUMBER := 0;
    dias_mes CONSTANT  NUMBER := 30;
    asignacion_basica  mi_salario%TYPE;
    anios_laborados    NUMBER;
    cargo              VARCHAR2(100);
    outsalary          BOOLEAN;
    prima_servicio     number := 0;
    --
    -- Codigos sentencia
    --
    codigo             NUMBER;
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
    -- Funcion para traer el cargo del empleado
    FUNCTION traer_cargo_emp(pidempleado employees.employee_id%TYPE) RETURN VARCHAR2
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
        END;
    EXCEPTION
        WHEN OTHERS THEN myrespcargo := 'Invalid ID';
        RETURN (myrespcargo);
    END;
    --
    --procedimiento para saber si es jefe
    PROCEDURE obtain_ismanager(cargo_emp IN varchar2, salario_basico IN number, prima_servicio OUT number)
    AS
    BEGIN

        IF cargo_emp LIKE '%Manager%' THEN
            prima_servicio := salario_basico * 0.20;
        ELSE
            prima_servicio := 0;
        END IF;
    END;
    --
    -- Procedimiento para calcular la prima de antiguedad
    --PROCEDURE exec_calculo_prima_antiguedad (pAniosLaborados NUMBER, pAsignacionBasica NUMBER, respPrimaAnt OUT NUMBER)
    --AS
    --   BEGIN
    --  IF pAniosLaborados >= 0 THEN
    --    respPrimaAnt := pAsignacionBasica * 0.10;
    --  END IF;
    --END;
--
BEGIN
    <<inicio_ejecucion>>
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
            prima_servicio := obtain_ismanager(cargo, mi_salario, prima_servicio);

            --Inicio calculos de conceptos
            codigo := 1;
            asignacion_basica := obtener_asignacion_basica(mi_salario, mis_dias_laborados);
            --
            dbms_output.put_line(
                        mi_id_empleado || ' ' || mi_salario || ' ' || mis_dias_laborados || ' ' || asignacion_basica ||
                        ' ' || anios_laborados || ' ' || prima_servicio);
        END LOOP;

END;
/


------crear las furnicones en la base de datos-----
--
--
--
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

DECLARE
    prima_antiguedad number;
    salario          number := 0;
BEGIN
    obtain_prima_antiguedad(9, 45000, prima_antiguedad);
    dbms_output.put_line(prima_antiguedad);
END;



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
BEGIN
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
                                    traer_salario_emp(c_data.employee_id), prima_antiguedad);
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
        END LOOP;
END;
DECLARE
    valor_neto number:=0;
BEGIN
    calcularnomina(valor_neto);
--     dbms_output.PUT_LINE(valor_neto);
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
    CURSOR employee_data IS SELECT
                                e.employee_id
                            FROM
                                employees e;
    c_data                employee_data%ROWTYPE;
BEGIN
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
                                    traer_salario_emp(c_data.employee_id), prima_antiguedad);
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
        END LOOP;
END;


CREATE OR REPLACE PACKAGE pck_nomina AS
    PROCEDURE calcularnomina(valor_neto OUT number);
    end pck_nomina;



--------------------------------------package --------------------------------------------------
   CREATE or REPLACE PACKAGE pkg_nomina
   IS
   --
   FUNCTION traer_salario_emp(pIdEmpleado number) RETURN NUMBER;
   FUNCTION traer_dias_laborados_emp(pIdEmpleado employees.employee_id%TYPE) RETURN NUMBER;
   FUNCTION obtener_asignacion_basica(pSalario employees.salary%TYPE, pDiasLaborados NUMBER) RETURN NUMBER;
   FUNCTION traer_anios_laborados (pIdEmpleado employees.employee_id%TYPE) RETURN NUMBER;
   FUNCTION obtener_cargo_emp(pidempleado employees.employee_id%TYPE) RETURN VARCHAR2;
   PROCEDURE obtain_calculo_prima_antiguedad (pAniosLaborados IN NUMBER, pAsignacionBasica IN NUMBER, prima_antiguedad OUT NUMBER);
   PROCEDURE obtain_prima_servicios(pCargo IN VARCHAR2, salarioBasico IN NUMBER, primaServicio OUT NUMBER);
   PROCEDURE obtain_subsidio_alimentacion (pSalario IN employees.salary%TYPE, pDiasLaborados IN NUMBER, subsidio_alimentacion OUT NUMBER);
   PROCEDURE obtain_subsidio_transporte (pSalario IN employees.salary%TYPE, pDiasLaborados IN NUMBER, subsidio_transporte OUT NUMBER);
   FUNCTION obtener_total_devengado(pIdEmpleado employees.employee_id%TYPE) RETURN NUMBER;
   PROCEDURE obtener_salud (pAsignacionBasica IN NUMBER, salud OUT NUMBER);
   PROCEDURE obtener_pension (pAsignacionBasica IN NUMBER, pension OUT NUMBER);
   PROCEDURE obtener_retefuente (pSalario IN employees.salary%TYPE, pAsignacionBasica IN NUMBER, retefuente OUT NUMBER);
   FUNCTION obtener_total_deducido(pIdEmpleado employees.employee_id%TYPE) RETURN NUMBER;
   PROCEDURE obtener_total_neto (pTotDevengado IN NUMBER, pTotDeducido IN NUMBER, valor_neto OUT NUMBER);
   --
   END;
   /
   CREATE or REPLACE PACKAGE BODY pkg_nomina
   IS
   --
   -- Funcion para buscar el salario del empleado
   FUNCTION traer_salario_emp(pIdEmpleado number) RETURN NUMBER
   IS
    myRespSalario    NUMBER;
    myIdEmpleado     employees.employee_id%TYPE := pIdEmpleado;
    BEGIN
        BEGIN
            SELECT salary INTO myRespSalario
            FROM employees
            WHERE employee_id = myIdEmpleado;
        EXCEPTION
            WHEN OTHERS THEN myRespSalario := 0;
        END;
    --
    RETURN (myRespSalario);
    END;
    --
    -- Funcion para traer el numero de dias laborados
    FUNCTION traer_dias_laborados_emp(pIdEmpleado employees.employee_id%TYPE) RETURN NUMBER
    IS
    myRespDiasLaborados NUMBER;
    myIdEmpleado     employees.employee_id%TYPE := pIdEmpleado;
    BEGIN
        BEGIN
            SELECT num_days INTO myRespDiasLaborados
            FROM num_days
            WHERE employee_id = myIdEmpleado;
        EXCEPTION
            WHEN OTHERS THEN myRespDiasLaborados := 0;
        END;
    --
    RETURN (myRespDiasLaborados);
    END;
    --
    -- Funcion para calcular el salario basico
    FUNCTION obtener_asignacion_basica(pSalario employees.salary%TYPE, pDiasLaborados NUMBER) RETURN NUMBER
    IS
    asignacion_basica   NUMBER;
    myRespAsignacion    NUMBER;
    mySalario           employees.salary%TYPE := pSalario;
    myDiasLaborados     NUMBER := pDiasLaborados;
    dias_mes            CONSTANT NUMBER := 30;
    BEGIN
        BEGIN
            asignacion_basica := (( mySalario / dias_mes ) * myDiasLaborados );
        EXCEPTION
            WHEN OTHERS THEN myRespAsignacion := 0;
        END;
    --
    RETURN (asignacion_basica);
    END;
    --
    -- Funcion para traer el numero de anios laborados
    FUNCTION traer_anios_laborados (pIdEmpleado employees.employee_id%TYPE) RETURN NUMBER
    IS
    myResAniosLaborados     NUMBER;
    myIdEmpleado     employees.employee_id%TYPE := pIdEmpleado;
    BEGIN
        BEGIN
            SELECT years INTO myResAniosLaborados
            FROM job_years
            WHERE employee_id = pIdEmpleado;
        EXCEPTION
            WHEN OTHERS THEN myResAniosLaborados := 0;
        END;
    RETURN (myResAniosLaborados);
    END;
    --
    -- Funcion para traer el cargo
    FUNCTION obtener_cargo_emp(pidempleado employees.employee_id%TYPE) RETURN VARCHAR2
        IS
        cargo        VARCHAR2(100);
        myidempleado employees.employee_id%TYPE := pidempleado;
    BEGIN
        BEGIN
            SELECT job_title INTO cargo
            FROM jobs
            INNER JOIN employees e ON jobs.job_id = e.job_id
            WHERE employee_id = myidempleado;
        EXCEPTION
            WHEN OTHERS THEN cargo := '';
        END;
        --
        RETURN (cargo);
    END;
    --
    -- Procedimiento para calcular la prima de antiguedad
    PROCEDURE obtain_calculo_prima_antiguedad (pAniosLaborados IN NUMBER, pAsignacionBasica IN NUMBER, prima_antiguedad OUT NUMBER)
    AS
        anios_laborados    NUMBER;
        BEGIN
        IF pAniosLaborados >= 0 THEN
            prima_antiguedad := pAsignacionBasica * 0.10;
        ELSIF pAnioslaborados >= 11 AND anios_laborados <= 20 THEN
            prima_antiguedad := pAsignacionBasica * 0.15;
        ELSE
            prima_antiguedad := (pAsignacionbasica * 0.20);
        END IF;
    END;
    --
    --procedimiento para calcular prima de servicios por jefatura
    PROCEDURE obtain_prima_servicios(pCargo IN VARCHAR2, salarioBasico IN NUMBER, primaServicio OUT NUMBER)
    AS
    BEGIN
        IF pCargo LIKE '%Manager%' THEN
            primaServicio :=salariobasico*0.20 ;
        ELSE
            primaServicio := 0;
        END IF;
    END;
    --
    -- Procedimiento para calcular el subsidio de alimentacion
    PROCEDURE obtain_subsidio_alimentacion (pSalario IN employees.salary%TYPE, pDiasLaborados IN NUMBER, subsidio_alimentacion OUT NUMBER)
    AS
    BEGIN
        IF pSalario < 3000 THEN
            subsidio_alimentacion := ( 100 / 30 ) * pDiasLaborados;
        ELSE
            subsidio_alimentacion := 0;
        END IF;
    END;
    --
    -- Procedimiento para calcular el subsidio de transporte
    PROCEDURE obtain_subsidio_transporte (pSalario IN employees.salary%TYPE, pDiasLaborados IN NUMBER, subsidio_transporte OUT NUMBER)
    AS
    BEGIN
        IF pSalario < 3000 THEN
            subsidio_transporte := ( 80 / 30 ) * pDiasLaborados;
        ELSE
            subsidio_transporte := 0;
        END IF;
    END;
    --
    -- Funcion para obtener el total devengado
    FUNCTION obtener_total_devengado(pIdEmpleado employees.employee_id%TYPE) RETURN NUMBER
        IS
        resTotDevcargo        NUMBER;
        myIdEmpleado employees.employee_id%TYPE := pIdEmpleado;
    BEGIN
        BEGIN
            SELECT SUM(p.pyd_value) INTO resTotDevcargo
            FROM payroll p
            WHERE pyd BETWEEN 1 AND 9 AND p.employee_id = myIdEmpleado
            GROUP BY p.employee_id;
        EXCEPTION
            WHEN OTHERS THEN resTotDevcargo := 0;
        END;
        --
        RETURN (resTotDevcargo);
    END;
    --
    -- Procedimiento para calcular salud
    PROCEDURE obtener_salud (pAsignacionBasica IN NUMBER, salud OUT NUMBER)
    AS
    BEGIN
        salud := pAsignacionBasica * 0.16;
    END;
    --
    -- Procedimiento para calcular pension
    PROCEDURE obtener_pension (pAsignacionBasica IN NUMBER, pension OUT NUMBER)
    AS
    BEGIN
        pension := pAsignacionBasica * 0.12;
    END;
    --
    -- Procedimiento para calcular la retefuente
    PROCEDURE obtener_retefuente (pSalario IN employees.salary%TYPE, pAsignacionBasica IN NUMBER, retefuente OUT NUMBER)
    AS
    BEGIN
        IF pSalario >= 0 AND pSalario <= 1999 THEN
        retefuente := pAsignacionBasica * 0;
    ELSIF pSalario >= 2000 AND pSalario <= 4999 THEN
        retefuente := pAsignacionBasica * 0.05;
    ELSIF pSalario >= 5000 AND pSalario <= 8999 THEN
        retefuente := pAsignacionBasica * 0.10;
    ELSE
        retefuente := pAsignacionBasica * 0.15;
    END IF;
    END;
    --
    -- Funcion para obtener el total deducido
    FUNCTION obtener_total_deducido(pIdEmpleado employees.employee_id%TYPE) RETURN NUMBER
        IS
        resTotDedcargo        NUMBER;
        valor_deducido        NUMBER;
        myIdEmpleado employees.employee_id%TYPE := pIdEmpleado;
    BEGIN
        BEGIN
            SELECT SUM(p.pyd_value) INTO valor_deducido
            FROM payroll p
            WHERE pyd BETWEEN 11 AND 19 AND p.employee_id = myIdEmpleado
            GROUP BY p.employee_id;
        EXCEPTION
            WHEN OTHERS THEN resTotDedcargo := 0;
        END;
        --
        RETURN (resTotDedcargo);
    END;
    --
    -- Procedimiento para calcular el total neto
    PROCEDURE obtener_total_neto (pTotDevengado IN NUMBER, pTotDeducido IN NUMBER, valor_neto OUT NUMBER)
    AS
    BEGIN
        valor_neto := pTotDevengado - pTotDeducido;
    END;
END;
--

DECLARE
  cedula NUMBER;
  valor  NUMBER;
  --
BEGIN
  cedula := 105;
  valor := pkg_nomina.traer_salario_emp(cedula);
  dbms_output.put_line('VALOR = ' || valor);
END;
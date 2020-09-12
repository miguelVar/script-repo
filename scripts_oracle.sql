SELECT
    p.employee_id
  , p.pyd
FROM
    payroll p
WHERE
    pyd = 30;

SELECT *
FROM
    employees e
        INNER JOIN job_history jh ON e.employee_id = jh.employee_id;

INSERT
INTO payroll
    (employee_id, pyd, pyd_value)
SELECT
    p.employee_id
  , 20
  , Sum(p.pyd_value) AS deducido
FROM
    payroll p
WHERE
    p.pyd BETWEEN 11 AND 19
GROUP BY
    p.employee_id;

DECLARE
    mi_salario number;
BEGIN
    SELECT
        salary
    INTO mi_salario
    FROM
        employees
    WHERE
        employee_id = '105';
    dbms_output.put_line('El salario es: ' || mi_salario);
END;

-- set timing on, para medir el tiempo de ejecucion dela consulta
--  mi_salario number:= 8;

DECLARE
    mi_salario number;
    mi_nombre  varchar2(100);
BEGIN
    SELECT
        salary
      , first_name || ' ' || last_name
    INTO mi_salario,mi_nombre
    FROM
        employees
    WHERE
        employee_id = '100';
    dbms_output.put_line('El colaborador: ' || mi_nombre || ' El salario es: ' || mi_salario);
END;



DECLARE
    mi_salario  number;
    mi_nombre   varchar2(100);
    mi_id       varchar2(20) := ?;
    mi_empleado employees%ROWTYPE;
BEGIN
    SELECT
        salary
      , first_name || ' ' || last_name
    INTO mi_salario,mi_nombre
    FROM
        employees
    WHERE
        employee_id = mi_id;
    dbms_output.put_line('El colaborador: ' || mi_nombre || ' El salario es: ' || mi_salario);
END;


DECLARE
    mi_id      varchar2(20) := ?;
    mi_salario number;
    mi_nombre  varchar2(100);
BEGIN
    SELECT
        e.first_name || ' ' || e.last_name
      , (e.salary / 30) * n.num_days
    INTO mi_nombre,mi_salario
    FROM
        employees e
            INNER JOIN num_days n ON e.employee_id = n.employee_id
    WHERE
        e.employee_id = mi_id;
    dbms_output.put_line(
                'Para ' || mi_nombre || ', el salario para este mes es de' || TO_CHAR(mi_salario, '$999,999.99') ||
                ' dolares');
END;


DECLARE
    mi_id              varchar2(20) := ?;
    num_dias_laborados number       := ?;
    mi_salario         number;
    mi_nombre          varchar2(100);
BEGIN
    SELECT
        e.first_name || ' ' || e.last_name
      , (e.salary / num_dias_laborados) * n.num_days
    INTO mi_nombre,mi_salario
    FROM
        employees e
            INNER JOIN num_days n ON e.employee_id = n.employee_id
    WHERE
        e.employee_id = mi_id;
    dbms_output.put_line(
                'Para ' || mi_nombre || ', el salario para este mes es de $' || TO_CHAR(mi_salario, '$999,999.99') ||
                ' dolares');
END;



DECLARE
    mi_id      varchar2(20) := ?;
    mi_salario number;
    mi_nombre  varchar2(100);
BEGIN
    SELECT
        e.first_name || ' ' || e.last_name
      , (e.salary / 30) * n.num_days
    INTO mi_nombre,mi_salario
    FROM
        employees e
            INNER JOIN num_days n ON e.employee_id = n.employee_id
    WHERE
        e.employee_id = mi_id;
    dbms_output.put_line(
                'Para ' || mi_nombre || ', el salario para este mes es de' || TO_CHAR(mi_salario, '$999,999.99') ||
                ' dolares');
END;



SELECT
    DECODE(SIGN(30 - 30), 1, 10, 20)
FROM
    dual;
SELECT
    e.salary
  , SIGN(e.salary - 10999)
FROM
    employees e
WHERE
    employee_id = 100;



SELECT
    e.employee_id
  , e.salary
  , nd.num_days
  , DECODE(SIGN(e.salary - 1999), -1, 0,
           0, 0,
           1, DECODE(SIGN(e.salary - 4999), -1, ((e.salary / 30) * nd.num_days) * 0.05,
                     0, e.salary * 0.05,
                     1, DECODE(SIGN(e.salary - 4999), -1, ((e.salary / 30) * nd.num_days) * 0.1,
                               0, ((e.salary / 30) * nd.num_days) * 0.1,
                               1, ((e.salary / 30) * nd.num_days) * 0.15
                         ))) retefuente
FROM
    employees e
        INNER JOIN num_days nd ON e.employee_id = nd.employee_id;


DECLARE
    mi_id         number := ?;
    mi_salario    number;
    dias          number;
    mi_asignacion number := (mi_salario / 30) * dias;
    retefuente    number;
BEGIN
    SELECT
        e.salary
      , nd.num_days
      , DECODE(SIGN(e.salary - 1999), -1, 0,
               0, 0,
               1, DECODE(SIGN(e.salary - 4999), -1, mi_asignacion * 0.05,
                         0, e.salary * 0.05,
                         1, DECODE(SIGN(e.salary - 4999), -1, mi_asignacion * 0.1,
                                   0, mi_asignacion * 0.1,
                                   1, mi_asignacion * 0.15
                             ))) retefuente
    INTO mi_salario,dias,retefuente
    FROM
        employees e
            INNER JOIN num_days nd ON e.employee_id = nd.employee_id
    WHERE
        e.employee_id = 100;
    dbms_output.put_line('La retefuente para: ' || mi_id || ' es: ' || retefuente);
END;



SELECT
    e.employee_id
  , 13
  , CASE
        WHEN e.salary >= 0
            AND e.salary <= 1999 THEN
            ((e.salary / 30) * nd.num_days) * 0
        WHEN e.salary >= 2000
            AND e.salary <= 4999 THEN
            ((e.salary / 30) * nd.num_days) * 0.05
        WHEN e.salary >= 5000
            AND e.salary <= 8999 THEN
            ((e.salary / 30) * nd.num_days) * 0.10
        ELSE ((e.salary / 30) * nd.num_days) * 0.15
        END AS rete_fuente
FROM
    employees e
        INNER JOIN jobs j
                   ON e.job_id = j.job_id
        INNER JOIN num_days nd
                   ON e.employee_id = nd.employee_id;



DECLARE
    mi_id                 number := ?;
    mi_salario            number;
    dias_laborados        number;
    antiguedad            number;
    cargo                 varchar2(100);
    mi_asignacion         number := 0;
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
    SELECT
        e.employee_id
      , e.salary
      , nd.num_days
      , jy.years
      , j.job_title
    INTO mi_asignacion,mi_salario,dias_laborados,antiguedad,cargo
    FROM
        employees e
            INNER JOIN num_days nd ON e.employee_id = nd.employee_id
            INNER JOIN job_years jy ON e.employee_id = jy.employee_id
            INNER JOIN jobs j ON e.job_id = j.job_id
    WHERE
        e.employee_id = mi_id;

    --------------------SALARIO BASICO-------------------------------------------------------------------
    salario_basico := (mi_salario / 30) * dias_laborados;
    dbms_output.put_line(mi_salario);
    dbms_output.put_line('El salario basico para el id: ' || mi_id || ' es: ' || salario_basico);


    -------------------------PRIMA ANTIGUEDAD-------------------------------------------------------------
    IF antiguedad BETWEEN 0 AND 10 THEN
        prima_antiguedad := salario_basico * 0.1;
    ELSIF antiguedad BETWEEN 11 AND 20 THEN
        prima_antiguedad := salario_basico * 0.15;
    ELSE
        prima_antiguedad := salario_basico * 0.20;
    END IF;

    dbms_output.put_line('La prima de antiguedad para el id: ' || mi_id || ' es: ' || prima_antiguedad);


    -------------------------PRIMA SERVICIOS --------------------------------------------------------------
    IF cargo LIKE '%Manager%' THEN
        prima_servicios := salario_basico * 0.20;
    END IF;

    dbms_output.put_line('La prima de servicios para el id: ' || mi_id || ' es: ' || prima_servicios);

    ------------------SUBSIDIO ALIMENTACION------------------------------------------------------------------

    IF mi_salario < 3000 THEN
        subsidio_alimentacion := (100 / 30) * dias_laborados;
    END IF;

    dbms_output.put_line('El subsidio de alimentacion para el id: ' || mi_id || ' es: ' || subsidio_alimentacion);

    -----------------------SUBSIDIO TRANSPORTE----------------------------------------------------------------------

    IF mi_salario < 3000 THEN
        subsidio_transporte := (80 / 30) * dias_laborados;
    END IF;

    dbms_output.put_line('El subsidio de transporte para el id: ' || mi_id || ' es: ' || subsidio_transporte);


    -------------------------------TOTAL DEVENGADO-----------------------------------------------------------------
    total_devengado :=
                salario_basico + prima_antiguedad + prima_servicios + subsidio_alimentacion + subsidio_transporte;
    dbms_output.put_line('El total devengado para el id: ' || mi_id || ' es: ' || total_devengado);

    ------------------------------------SALUD ------------------------------------------------------------------
    salud := salario_basico * 0.12;
    dbms_output.put_line('Salud para el id: ' || mi_id || ' es: ' || salud);

    ------------------------------------PENSION-----------------------------------------------------------------
    pension := salario_basico * 0.16;
    dbms_output.put_line('Pension para el id: ' || mi_id || ' es: ' || pension);


    ----------------------------------RETEFUENTE ----------------------------------------------------------------
    IF mi_salario BETWEEN 0 AND 1999 THEN
        retefuente := salario_basico * 0;
    ELSIF mi_salario BETWEEN 2000 AND 4999 THEN
        retefuente := salario_basico * 0.05;
    ELSIF mi_salario BETWEEN 5000 AND 8999 THEN
        retefuente := salario_basico * 0.1;
    ELSE
        retefuente := salario_basico * 0.15;
    END IF;

    dbms_output.put_line('La retefuente para el id: ' || mi_id || ' es: ' || retefuente);

    --------------------------TOTAL DEDUCIDO ----------------------------------------------------------------
    total_deducido := salud + pension + retefuente;
    dbms_output.put_line('El total deducido para el id: ' || mi_id || ' es: ' || total_deducido);

    ---------------------------VALOR NETO --------------------------------------------------------------------
    valor_neto := total_devengado - total_deducido;
    dbms_output.put_line('El valor neto para el id: ' || mi_id || ' es: ' || valor_neto);
END;

SELECT *
FROM
    job_years j
WHERE
    j.employee_id = 105;
SELECT
    e.hire_date
FROM
    employees e
WHERE
    e.employee_id = 105;
SELECT *
FROM
    payroll p
WHERE
    p.employee_id = 105;
SELECT
    SYSDATE
FROM
    dual;
SELECT
    to_char(sysdate, 'YYYY')
FROM
    dual;


BEGIN
    FOR i IN 1..10
        LOOP
            dbms_output.put_line('########################## TABLA DEL ' || i || ' #######################');
            FOR j IN 1..10
                LOOP
                    dbms_output.put_line(i || ' * ' || j || '=' || i * j);
                END LOOP;
        END LOOP;
END;

-- BEGIN
--     FOR i IN (
--         SELECT
--             e.employee_id
--           , e.salary
--           , nd.num_days
--           , jy.years
--           , j.job_title
--         FROM
--             employees e
--                 INNER JOIN num_days nd ON e.employee_id = nd.employee_id
--                 INNER JOIN job_years jy ON e.employee_id = jy.employee_id
--                 INNER JOIN jobs j ON e.job_id = j.job_id
--         )
--         LOOP
--         END LOOP;
-- END;


DECLARE
    mi_id                 number := 0;
    mi_salario            number;
    dias_laborados        number;
    antiguedad            number;
    cargo                 varchar2(100);
    mi_asignacion         number := 0;
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
    FOR i IN (SELECT
                  e.employee_id
                , e.salary
                , nd.num_days
                , jy.years
                , j.job_title
              INTO mi_asignacion,mi_salario,dias_laborados,antiguedad,cargo
              FROM
                  employees e
                      INNER JOIN num_days nd ON e.employee_id = nd.employee_id
                      INNER JOIN job_years jy ON e.employee_id = jy.employee_id
                      INNER JOIN jobs j ON e.job_id = j.job_id
        )
        LOOP
            dbms_output.put_line(mi_salario);

            --------------------SALARIO BASICO-------------------------------------------------------------------
            salario_basico := (mi_salario / 30) * dias_laborados;
            dbms_output.put_line(mi_salario);
            dbms_output.put_line('El salario basico para el id: ' || mi_id || ' es: ' || salario_basico);


            -------------------------PRIMA ANTIGUEDAD-------------------------------------------------------------
            IF antiguedad BETWEEN 0 AND 10 THEN
                prima_antiguedad := salario_basico * 0.1;
            ELSIF antiguedad BETWEEN 11 AND 20 THEN
                prima_antiguedad := salario_basico * 0.15;
            ELSE
                prima_antiguedad := salario_basico * 0.20;
            END IF;

            dbms_output.put_line('La prima de antiguedad para el id: ' || mi_id || ' es: ' || prima_antiguedad);


            -------------------------PRIMA SERVICIOS --------------------------------------------------------------
            IF cargo LIKE '%Manager%' THEN
                prima_servicios := salario_basico * 0.20;
            END IF;

            dbms_output.put_line('La prima de servicios para el id: ' || mi_id || ' es: ' || prima_servicios);

            ------------------SUBSIDIO ALIMENTACION------------------------------------------------------------------

            IF mi_salario < 3000 THEN
                subsidio_alimentacion := (100 / 30) * dias_laborados;
            END IF;

            dbms_output.put_line(
                        'El subsidio de alimentacion para el id: ' || mi_id || ' es: ' || subsidio_alimentacion);

            -----------------------SUBSIDIO TRANSPORTE----------------------------------------------------------------------

            IF mi_salario < 3000 THEN
                subsidio_transporte := (80 / 30) * dias_laborados;
            END IF;

            dbms_output.put_line('El subsidio de transporte para el id: ' || mi_id || ' es: ' || subsidio_transporte);


            -------------------------------TOTAL DEVENGADO-----------------------------------------------------------------
            total_devengado :=
                        salario_basico + prima_antiguedad + prima_servicios + subsidio_alimentacion +
                        subsidio_transporte;
            dbms_output.put_line('El total devengado para el id: ' || mi_id || ' es: ' || total_devengado);

            ------------------------------------SALUD ------------------------------------------------------------------
            salud := salario_basico * 0.12;
            dbms_output.put_line('Salud para el id: ' || mi_id || ' es: ' || salud);

            ------------------------------------PENSION-----------------------------------------------------------------
            pension := salario_basico * 0.16;
            dbms_output.put_line('Pension para el id: ' || mi_id || ' es: ' || pension);


            ----------------------------------RETEFUENTE ----------------------------------------------------------------
            IF mi_salario BETWEEN 0 AND 1999 THEN
                retefuente := salario_basico * 0;
            ELSIF mi_salario BETWEEN 2000 AND 4999 THEN
                retefuente := salario_basico * 0.05;
            ELSIF mi_salario BETWEEN 5000 AND 8999 THEN
                retefuente := salario_basico * 0.1;
            ELSE
                retefuente := salario_basico * 0.15;
            END IF;

            dbms_output.put_line('La retefuente para el id: ' || mi_id || ' es: ' || retefuente);

            --------------------------TOTAL DEDUCIDO ----------------------------------------------------------------
            total_deducido := salud + pension + retefuente;
            dbms_output.put_line('El total deducido para el id: ' || mi_id || ' es: ' || total_deducido);

            ---------------------------VALOR NETO --------------------------------------------------------------------
            valor_neto := total_devengado - total_deducido;
            dbms_output.put_line('El valor neto para el id: ' || mi_id || ' es: ' || valor_neto);
        END LOOP;
END;


DECLARE
    -- BOC
-- ============
-- DESCRIPCION:
-- Carga datos desde RUES_LDR_EXT a RUES, despues de la revision
-- Tablas involucradas:
-- RUES_LDR_EXT: Informacion recibida
-- RUES: Registro Unico EmpreSarial
-- ============
-- PARAMETROS
-- ============
-- p_fecha DATE: fecha de generacion de los datos, inmersa en el nombre del archivo recibido
-- ============
-- HISTORIA
-- ============
-- 12/04/2019 JCSOTOO(OAPS): Creacion
-- NOTA: Se debe revisar la posibilidad de hacer carga por lotes ...
-- EOC
    mi_asignacion         number := 0;
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
    FOR i IN (SELECT
                  e.employee_id
                , e.salary
                , nd.num_days
                , jy.years
                , j.job_title
              FROM
                  employees e
                      INNER JOIN num_days nd ON e.employee_id = nd.employee_id
                      INNER JOIN job_years jy ON e.employee_id = jy.employee_id
                      INNER JOIN jobs j ON e.job_id = j.job_id)
        LOOP

            dbms_output.put_line(i.employee_id);

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
            --------------------SALARIO BASICO-------------------------------------------------------------------
            salario_basico := (i.salary / 30) * i.num_days;
            dbms_output.put_line('El salario basico para el id: ' || i.employee_id || ' es: ' || salario_basico);


            -------------------------PRIMA ANTIGUEDAD-------------------------------------------------------------
            IF i.years BETWEEN 0 AND 10 THEN
                prima_antiguedad := salario_basico * 0.1;
            ELSIF i.years BETWEEN 11 AND 20 THEN
                prima_antiguedad := salario_basico * 0.15;
            ELSE
                prima_antiguedad := salario_basico * 0.20;
            END IF;

            dbms_output.put_line('La prima de antiguedad para el id: ' || i.employee_id || ' es: ' || prima_antiguedad);


            -------------------------PRIMA SERVICIOS --------------------------------------------------------------
            IF i.job_title LIKE '%Manager%' THEN
                prima_servicios := salario_basico * 0.20;
            END IF;

            dbms_output.put_line('La prima de servicios para el id: ' || i.employee_id || ' es: ' || prima_servicios);

            ------------------SUBSIDIO ALIMENTACION------------------------------------------------------------------

            IF i.salary < 3000 THEN
                subsidio_alimentacion := (100 / 30) * i.num_days;
            END IF;

            dbms_output.put_line('El subsidio de alimentacion para el id: ' || i.employee_id || ' es: ' ||
                                 subsidio_alimentacion);

            -----------------------SUBSIDIO TRANSPORTE----------------------------------------------------------------------

            IF i.salary < 3000 THEN
                subsidio_transporte := (80 / 30) * i.num_days;
            END IF;

            dbms_output.put_line(
                        'El subsidio de transporte para el id: ' || i.employee_id || ' es: ' || subsidio_transporte);


            -------------------------------TOTAL DEVENGADO-----------------------------------------------------------------
            total_devengado :=
                        salario_basico + prima_antiguedad + prima_servicios + subsidio_alimentacion +
                        subsidio_transporte;
            dbms_output.put_line('El total devengado para el id: ' || i.employee_id || ' es: ' || total_devengado);

            ------------------------------------SALUD ------------------------------------------------------------------
            salud := salario_basico * 0.12;
            dbms_output.put_line('Salud para el id: ' || i.employee_id || ' es: ' || salud);

            ------------------------------------PENSION-----------------------------------------------------------------
            pension := salario_basico * 0.16;
            dbms_output.put_line('Pension para el id: ' || i.employee_id || ' es: ' || pension);


            ----------------------------------RETEFUENTE ----------------------------------------------------------------
            IF i.salary BETWEEN 0 AND 1999 THEN
                retefuente := salario_basico * 0;
            ELSIF i.salary BETWEEN 2000 AND 4999 THEN
                retefuente := salario_basico * 0.05;
            ELSIF i.salary BETWEEN 5000 AND 8999 THEN
                retefuente := salario_basico * 0.1;
            ELSE
                retefuente := salario_basico * 0.15;
            END IF;

            dbms_output.put_line('La retefuente para el id: ' || i.employee_id || ' es: ' || retefuente);

            --------------------------TOTAL DEDUCIDO ----------------------------------------------------------------
            total_deducido := salud + pension + retefuente;
            dbms_output.put_line('El total deducido para el id: ' || i.employee_id || ' es: ' || total_deducido);

            ---------------------------VALOR NETO --------------------------------------------------------------------
            valor_neto := total_devengado - total_deducido;
            dbms_output.put_line('El valor neto para el id: ' || i.employee_id || ' es: ' || valor_neto);


            IF salario_basico > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (i.employee_id, 1, salario_basico);
            END IF;
            IF prima_antiguedad > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (i.employee_id, 2, prima_antiguedad);
            END IF;
            IF prima_servicios > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (i.employee_id, 3, prima_servicios);
            END IF;
            IF subsidio_alimentacion > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (i.employee_id, 4, subsidio_alimentacion);
            END IF;
            IF subsidio_transporte > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (i.employee_id, 5, subsidio_transporte);
            END IF;
            IF total_devengado > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (i.employee_id, 10, total_devengado);
            END IF;
            IF salud > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (i.employee_id, 11, salud);
            END IF;
            IF pension > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (i.employee_id, 12, pension);
            END IF;
            IF retefuente > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (i.employee_id, 13, retefuente);
            END IF;
            IF total_deducido > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (i.employee_id, 20, total_deducido);
            END IF;
            IF valor_neto > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (i.employee_id, 30, valor_neto);
            END IF;

        END LOOP;
END;


SELECT
    salary
FROM
    employees
WHERE
    employee_id = '105';

SELECT
    SUM(pyd_value)
FROM
    payroll
WHERE
    pyd = 30;
DELETE
FROM
    payroll;
SELECT *
FROM
    payroll;
SELECT *
FROM
    payroll
WHERE
    employee_id = 206;


----Cursores--------------------------------------


DECLARE
    mi_id                 number;
    mi_salario            number;
    dias_laborados        number;
    antiguedad            number;
    cargo                 varchar2(100);
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

    dup_val_on_index EXCEPTION;
    PRAGMA EXCEPTION_INIT (dup_val_on_index, -00001);

    parent_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT (parent_not_found, -2291);

    valor_no_valido EXCEPTION;

    CURSOR employee_data IS SELECT
                                e.employee_id
                              , e.salary
                              , nd.num_days
                              , jy.years
                              , j.job_title
                            FROM
                                employees e
                                    INNER JOIN num_days nd ON e.employee_id = nd.employee_id
                                    INNER JOIN job_years jy ON e.employee_id = jy.employee_id
                                    INNER JOIN jobs j ON e.job_id = j.job_id;
BEGIN
    --     DELETE FROM payroll;
    OPEN employee_data;
    LOOP
        FETCH employee_data INTO mi_id,mi_salario,dias_laborados,antiguedad,cargo;
        EXIT WHEN employee_data%NOTFOUND;
        ------
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
        --------------------SALARIO BASICO-------------------------------------------------------------------
        BEGIN

            IF dias_laborados > 0 THEN
                salario_basico := (mi_salario / 30) * dias_laborados;
                dbms_output.put_line(mi_salario);
                dbms_output.put_line('El salario basico para el id: ' || mi_id || ' es: ' || salario_basico);
            ELSIF dias_laborados < 0 THEN
                RAISE valor_no_valido;
            END IF;
        EXCEPTION
            WHEN valor_no_valido THEN
                dbms_output.put_line('El valor de los dias laborados debe ser mayor o igual a cero');
        END;
        -------------------------PRIMA ANTIGUEDAD-------------------------------------------------------------
        IF antiguedad BETWEEN 0 AND 10 THEN
            prima_antiguedad := salario_basico * 0.1;
        ELSIF antiguedad BETWEEN 11 AND 20 THEN
            prima_antiguedad := salario_basico * 0.15;
        ELSE
            prima_antiguedad := salario_basico * 0.20;
        END IF;

        dbms_output.put_line('La prima de antiguedad para el id: ' || mi_id || ' es: ' || prima_antiguedad);


        -------------------------PRIMA SERVICIOS --------------------------------------------------------------
        IF cargo LIKE '%Manager%' THEN
            prima_servicios := salario_basico * 0.20;
        END IF;

        dbms_output.put_line('La prima de servicios para el id: ' || mi_id || ' es: ' || prima_servicios);

        ------------------SUBSIDIO ALIMENTACION------------------------------------------------------------------

        IF mi_salario < 3000 THEN
            subsidio_alimentacion := (100 / 30) * dias_laborados;
        END IF;

        dbms_output.put_line('El subsidio de alimentacion para el id: ' || mi_id || ' es: ' || subsidio_alimentacion);

        -----------------------SUBSIDIO TRANSPORTE----------------------------------------------------------------------

        IF mi_salario < 3000 THEN
            subsidio_transporte := (80 / 30) * dias_laborados;
        END IF;

        dbms_output.put_line('El subsidio de transporte para el id: ' || mi_id || ' es: ' || subsidio_transporte);


        -------------------------------TOTAL DEVENGADO-----------------------------------------------------------------
        total_devengado :=
                    salario_basico + prima_antiguedad + prima_servicios + subsidio_alimentacion + subsidio_transporte;
        dbms_output.put_line('El total devengado para el id: ' || mi_id || ' es: ' || total_devengado);

        ------------------------------------SALUD ------------------------------------------------------------------
        salud := salario_basico * 0.12;
        dbms_output.put_line('Salud para el id: ' || mi_id || ' es: ' || salud);

        ------------------------------------PENSION-----------------------------------------------------------------
        pension := salario_basico * 0.16;
        dbms_output.put_line('Pension para el id: ' || mi_id || ' es: ' || pension);


        ----------------------------------RETEFUENTE ----------------------------------------------------------------
        IF mi_salario BETWEEN 0 AND 1999 THEN
            retefuente := salario_basico * 0;
        ELSIF mi_salario BETWEEN 2000 AND 4999 THEN
            retefuente := salario_basico * 0.05;
        ELSIF mi_salario BETWEEN 5000 AND 8999 THEN
            retefuente := salario_basico * 0.1;
        ELSE
            retefuente := salario_basico * 0.15;
        END IF;

        dbms_output.put_line('La retefuente para el id: ' || mi_id || ' es: ' || retefuente);

        --------------------------TOTAL DEDUCIDO ----------------------------------------------------------------
        total_deducido := salud + pension + retefuente;
        dbms_output.put_line('El total deducido para el id: ' || mi_id || ' es: ' || total_deducido);

        ---------------------------VALOR NETO --------------------------------------------------------------------
        valor_neto := total_devengado - total_deducido;
        dbms_output.put_line('El valor neto para el id: ' || mi_id || ' es: ' || valor_neto);

        BEGIN
            IF salario_basico > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id, 1, salario_basico);
            END IF;

            IF prima_antiguedad > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id, 2, prima_antiguedad);
            END IF;
            IF prima_servicios > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id, 3, prima_servicios);
            END IF;
            IF subsidio_alimentacion > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id, 4, subsidio_alimentacion);
            END IF;
            IF subsidio_transporte > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id, 5, subsidio_transporte);
            END IF;
            IF total_devengado > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id, 10, total_devengado);
            END IF;
            IF salud > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id, 0, salud);
            END IF;
            IF pension > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id, 12, pension);
            END IF;
            IF retefuente > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id, 13, retefuente);
            END IF;
            IF total_deducido > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id, 20, total_deducido);
            END IF;
            IF valor_neto > 0 THEN
                INSERT INTO payroll(employee_id, pyd, pyd_value) VALUES (mi_id, 30, valor_neto);
            END IF;

        EXCEPTION
            WHEN parent_not_found THEN
                dbms_output.put_line('El concepto que se esta ingresando, NO EXISTE');
            WHEN dup_val_on_index THEN
                dbms_output.put_line('ELIMINAR LA DATA');
        END;


    END LOOP;
    CLOSE employee_data;
END;


SELECT *
FROM
    employees
WHERE
    salary < 5000;


-------Excepciones------------------------
DECLARE
--
    mi_salario NUMBER := 0;
    --
    rx EXCEPTION;
    --
    parent_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT (parent_not_found, -2291);
    --
    still_have_employees EXCEPTION;
    PRAGMA EXCEPTION_INIT (still_have_employees, -2292);
    --
    error_ud EXCEPTION;
    PRAGMA EXCEPTION_INIT (error_ud, -20000);
    --
BEGIN
    BEGIN
        SELECT
            salary
        INTO mi_salario
        FROM
            employees
        WHERE
            employee_id = 153;
        IF mi_salario < 25000 THEN
            RAISE rx;
        ELSIF mi_salario < 80000 THEN
            RAISE_APPLICATION_ERROR(-20000, 'Error user defined');
        END IF;
    EXCEPTION
        WHEN no_data_found THEN
            BEGIN
                dbms_output.put_line('(S) NO hay datos para el empleado.');
                -- INSERT INTO monitor_errores(aplicacion, modulo, fecha, error_txt)
                -- VALUES( 'App01','Operativo', sysdate,SQLERRM);
            END;
        WHEN error_ud THEN dbms_output.put_line('Error user defined');
        WHEN rx THEN
            BEGIN
                mi_salario := mi_salario * 2;
                dbms_output.put_line('(S) Nuevo salario asignado.');
            END;
    END;
--
    BEGIN
        INSERT INTO payroll VALUES (0, 40, 23223);
        --
    EXCEPTION
        WHEN parent_not_found THEN dbms_output.put_line(
                '(I) Revisar informacion de empleado o del concepto a liquidar.');
    END;
    --
    BEGIN
        DELETE FROM employees WHERE employee_id = 203;
        --
    EXCEPTION
        WHEN still_have_employees THEN dbms_output.put_line(
                '(D) Please delete data from payroll or job history before delete employee data.');
    END;
    --
END;
SELECT * from employees;
select * from payroll where employee_id=100;
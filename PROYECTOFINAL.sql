


-------------------------------------------//BD-CLINICA VETERINARIA//-----------------------------------------

------------------------------------------1. CREACION DE LAS TABLAS-------------------------------------------

CREATE TABLE Cliente(
    cl_id_cliente NUMBER CONSTRAINT cl_id_cliente_pk  PRIMARY KEY NOT NULL,
    cl_nombre NVARCHAR2(25) NOT NULL,
    cL_apellido NVARCHAR2(25) NOT NULL,
    cl_cedula NVARCHAR2(12) NOT NULL,
    cl_telefono NUMBER NOT NULL,
    cl_correo NVARCHAR2(25) NOT NULL,
    cl_direccion NVARCHAR2(25) NOT NULL
);

CREATE TABLE Tipo_ocupacion(
    to_id_tipo NUMBER CONSTRAINT to_id_tipo_pk  PRIMARY KEY NOT NULL,
    to_descripcion NVARCHAR2(15) NOT NULL
);

CREATE TABLE Tipo_mascota(
    tm_id_tipo NUMBER CONSTRAINT tm_id_tipo_pk  PRIMARY KEY NOT NULL,
    tm_descripcion NVARCHAR2(15) NOT NULL,
    tm_raza NVARCHAR2(15) NOT NULL
);

CREATE TABLE Empleado(
    e_id_empleado NUMBER CONSTRAINT e_id_empleado_pk  PRIMARY KEY NOT NULL,
    e_nombre NVARCHAR2(25) NOT NULL,
    e_apellido NVARCHAR2(25) NOT NULL,
    e_cedula NVARCHAR2(12) NOT NULL,
    e_telefono NUMBER NOT NULL,
    e_salario NUMBER(15,2) NOT NULL,
    e_ocupacion NUMBER NOT NULL,
    CONSTRAINT e_ocupacion_fk FOREIGN KEY (e_ocupacion) REFERENCES Tipo_ocupacion(to_id_tipo)
);

CREATE TABLE Factura(
    f_id_factura NUMBER CONSTRAINT f_id_factura_pk  PRIMARY KEY NOT NULL,
    f_fecha DATE NOT NULL,
    f_subtotal NUMBER(15,2) NOT NULL,
    f_total NUMBER(15,2) NOT NULL,
    f_itbms NUMBER(15,2) NOT NULL,
    f_id_empleado NUMBER,
    CONSTRAINT f_id_empleado_fk FOREIGN KEY (f_id_empleado) REFERENCES Empleado(e_id_empleado)
);

CREATE TABLE Servicio(
    s_id_servicio NUMBER CONSTRAINT s_id_servicio_pk  PRIMARY KEY NOT NULL,
    s_descripcion NVARCHAR2(25) NOT NULL,
    s_costo NUMBER(15,2) NOT NULL
);

CREATE TABLE Mascota(
    m_id_mascota NUMBER CONSTRAINT m_id_mascota_pk  PRIMARY KEY NOT NULL,
    m_nombre NVARCHAR2(15) NOT NULL,
    m_sexo CHAR(1) NOT NULL,
    m_nacimiento DATE NOT NULL,
    m_peso NUMBER NOT NULL,
    m_id_dueno NUMBER NOT NULL,
    m_id_tipo NUMBER NOT NULL,
    CONSTRAINT m_id_mascota_fk FOREIGN KEY (m_id_tipo) REFERENCES Tipo_mascota(tm_id_tipo),
    CONSTRAINT m_id_dueno_fk FOREIGN KEY (m_id_dueno) REFERENCES Cliente(cl_id_cliente)
);

CREATE TABLE Cita(
    c_id_cita NUMBER CONSTRAINT c_id_cita_pk  PRIMARY KEY NOT NULL,
    c_descripcion NVARCHAR2(15) NOT NULL,
    c_fecha DATE NOT NULL
);

CREATE TABLE Atencion(
    a_id_cita NUMBER NOT NULL,
    a_id_empleado NUMBER NOT NULL,
    a_id_mascota NUMBER NOT NULL,
    CONSTRAINT atencion_pk PRIMARY KEY (a_id_cita,a_id_empleado),
	CONSTRAINT a_id_cita_fk FOREIGN KEY (a_id_cita) REFERENCES Cita(c_id_cita),
	CONSTRAINT a_id_empleado_fk FOREIGN KEY (a_id_empleado) REFERENCES Empleado(e_id_empleado),
    CONSTRAINT a_id_mascota_fk FOREIGN KEY (a_id_mascota) REFERENCES Mascota(m_id_mascota)
);

CREATE TABLE Adquirir(
    ad_id_servicio NUMBER NOT NULL,
    ad_id_cliente NUMBER NOT NULL,
    ad_id_factura NUMBER NOT NULL,
    ad_id_mascota NUMBER NOT NULL,   
    ad_id_solicitud NUMBER NOT NULL,
    CONSTRAINT adquirir_pk PRIMARY KEY (ad_id_cliente,ad_id_servicio, ad_id_solicitud),
	CONSTRAINT ad_id_cliente_fk FOREIGN KEY (ad_id_cliente) REFERENCES Cliente(cl_id_cliente),
	CONSTRAINT ad_id_factura_fk FOREIGN KEY (ad_id_factura) REFERENCES Factura(f_id_factura),
    CONSTRAINT ad_id_servicio_fk FOREIGN KEY (ad_id_servicio) REFERENCES Servicio(s_id_servicio),
    CONSTRAINT ad_id_mascota_fk FOREIGN KEY (ad_id_mascota) REFERENCES Mascota(m_id_mascota)
);

CREATE TABLE auditoria_costos(
    audc_num_accion NUMBER NOT NULL PRIMARY KEY,
    audc_tabla NVARCHAR2(20) NOT NULL,
    audc_id_servicio NUMBER NOT NULL,
    audc_costo_anterior NUMBER(15,2) NOT NULL,
    audc_costo_nuevo NUMBER(15,2) NOT NULL,
    audc_tipo_cambio NVARCHAR2(10) NOT NULL,
    audc_diferencia NUMBER(15,2) NOT NULL,
    audc_fecha_cambio DATE NOT NULL
);

CREATE TABLE auditoria_salarial(
    auds_num_accion NUMBER NOT NULL PRIMARY KEY,
    auds_tabla NVARCHAR2(25) NOT NULL,
    auds_id_empleado NUMBER NOT NULL,
    auds_nombre NVARCHAR2(25) NOT NULL,
    auds_apellido NVARCHAR2(25) NOT NULL,
    auds_salario_anterior NUMBER(15,2) NOT NULL,
    auds_salario_nuevo NUMBER(15,2) NOT NULL,
    auds_monto_aumento NUMBER(15,2) NOT NULL,
    auds_fecha_cambio DATE NOT NULL
);

CREATE TABLE inventario_atencion(
    inv_num_accion NUMBER NOT NULL PRIMARY KEY,
    inv_tabla NVARCHAR2(25) NOT NULL,
    inv_id_empleado NUMBER NOT NULL,
    inv_id_cita NUMBER NOT NULL,
    inv_id_mascota NUMBER NOT NULL,
    inv_fecha  DATE NOT NULL,
    inv_estado NVARCHAR2(25) NOT NULL
 );


--------------------------------2. PROCEDIMIENTOS DE INSERCIÓN-------------------------------------

    ------------------A. Procedimiento Insertar Tipo_Ocupación---------------------
CREATE OR REPLACE PROCEDURE  Insert_Tipo_Ocupacion(
    p_to_id_tipo            Tipo_ocupacion.to_id_tipo%TYPE,
    p_to_descripcion        Tipo_ocupacion.to_descripcion%TYPE
) AS
BEGIN
    INSERT INTO Tipo_ocupacion(to_id_tipo, to_descripcion)
    	VALUES (p_to_id_tipo, p_to_descripcion);
	COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ya existe este registro en la base de datos');
    WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('ERROR: Ocurrió un error en le proceso.');

END Insert_Tipo_Ocupacion;
/

    ------------------B. Procedimiento Insertar Tipo_Mascota---------------------
CREATE OR REPLACE PROCEDURE  Insert_Tipo_Mascota(
    p_tm_id_tipo          Tipo_mascota.tm_id_tipo%TYPE,
    p_tm_descripcion      Tipo_mascota.tm_descripcion%TYPE,
    p_tm_raza             Tipo_mascota.tm_raza%TYPE
) AS
BEGIN
    INSERT INTO Tipo_mascota(tm_id_tipo, tm_descripcion, tm_raza)
    	VALUES (p_tm_id_tipo, p_tm_descripcion, p_tm_raza);
	COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ya existe este registro en la base de datos');
    WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('ERROR: Ocurrió un error en le proceso.');

END Insert_Tipo_Mascota;
/

    ------------------C. Procedimiento Insertar Cliente---------------------
CREATE OR REPLACE PROCEDURE  Insert_Cliente(
    p_cl_id_cliente         Cliente.cl_id_cliente%TYPE,
    p_cl_nombre             Cliente.cl_nombre%TYPE,
    p_cL_apellido           Cliente.cL_apellido%TYPE,
    p_cl_cedula             Cliente.cl_cedula%TYPE,
    p_cl_telefono           Cliente.cl_telefono%TYPE,
    p_cl_correo             Cliente.cl_correo%TYPE,
    p_cl_direccion          Cliente.cl_direccion%TYPE
) AS
BEGIN
    INSERT INTO Cliente(cl_id_cliente, cl_nombre, cL_apellido, cl_cedula, cl_telefono, cl_correo, cl_direccion)
    	VALUES (p_cl_id_cliente, p_cl_nombre, p_cL_apellido, p_cl_cedula, p_cl_telefono, p_cl_correo, p_cl_direccion);
	COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ya existe este registro en la base de datos');
    WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('ERROR: Ocurrió un error en le proceso.');
END Insert_Cliente;
/

    ------------------D. Procedimiento Insertar Empleado---------------------
CREATE OR REPLACE PROCEDURE  Insert_Empleado(
    p_e_id_empleado               Empleado.e_id_empleado%TYPE,
    p_e_nombre                    Empleado.e_nombre%TYPE,
    p_e_apellido                  Empleado.e_apellido%TYPE,
    p_e_cedula                    Empleado.e_cedula%TYPE,
    p_e_telefono                  Empleado.e_telefono%TYPE,
    p_e_salario                   Empleado.e_salario%TYPE,
    p_e_ocupacion                 Empleado.e_ocupacion%TYPE
) AS
BEGIN
    INSERT INTO Empleado(e_id_empleado , e_nombre, e_apellido, e_cedula, e_telefono, e_salario, e_ocupacion)
    	VALUES (p_e_id_empleado, p_e_nombre, p_e_apellido, p_e_cedula, p_e_telefono, p_e_salario, p_e_ocupacion);
	COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ya existe este registro en la base de datos');
    WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('ERROR: Ocurrió un error en le proceso.');
END Insert_Empleado;
/

    ------------------E. Procedimiento Insertar Mascota---------------------
CREATE OR REPLACE PROCEDURE  Insert_Mascota(
    p_m_id_mascota            Mascota.m_id_mascota%TYPE,
    p_m_nombre                Mascota.m_nombre%TYPE,
    p_m_sexo                  Mascota.m_sexo%TYPE,
    p_m_nacimiento            Mascota.m_nacimiento%TYPE,
    p_m_peso                  Mascota.m_peso%TYPE,
    p_m_id_dueno              Mascota.m_id_dueno%TYPE,
    p_m_id_tipo               Mascota.m_id_tipo%TYPE
) AS
BEGIN
    INSERT INTO Mascota(m_id_mascota, m_nombre, m_sexo, m_nacimiento, m_peso, m_id_dueno, m_id_tipo)
    	VALUES (p_m_id_mascota, p_m_nombre, p_m_sexo, p_m_nacimiento, p_m_peso, p_m_id_dueno, p_m_id_tipo);
	COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ya existe este registro en la base de datos');
    WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('ERROR: Ocurrió un error en le proceso.');
END Insert_Mascota;
/

    ------------------F. Procedimiento Insertar Servicio---------------------

CREATE OR REPLACE PROCEDURE  Insert_Servicio(
    p_s_id_servicio       Servicio.s_id_servicio%TYPE,
    p_s_descripcion       Servicio.s_descripcion%TYPE,
    p_s_costo             Servicio.s_costo%TYPE
) AS
BEGIN
    INSERT INTO Servicio(s_id_servicio, s_descripcion, s_costo)
    	VALUES (p_s_id_servicio, p_s_descripcion, p_s_costo);
	COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ya existe este registro en la base de datos');
    WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('ERROR: Ocurrió un error en le proceso.');
END Insert_Servicio;
/




-----------------------------3. SECUENCIAS------------------------------------------
CREATE SEQUENCE seq_id_factura
START WITH 1
INCREMENT BY 1
NOCACHE;

CREATE SEQUENCE seq_id_solicitud
START WITH 1
INCREMENT BY 1
NOCACHE;


CREATE SEQUENCE seq_id_cita
START WITH 1
INCREMENT BY 1
NOCACHE;


CREATE SEQUENCE seq_trg_salarios
START WITH 1
INCREMENT BY 1
NOCACHE;

CREATE SEQUENCE seq_inv_num
START WITH 1
INCREMENT BY 1
NOCACHE;

CREATE SEQUENCE seq_costos
START WITH 1
INCREMENT BY 1
NOCACHE;





-----------------4. BLOQUES PARA INSERTAR LOS DATOS EN LAS TABLAS PRIMITIVAS----------------------

  ------------------A. Procedimiento Insertar Tipo_Ocupacion--------------------

BEGIN
  Insert_Tipo_Ocupacion(1, 'Asistente');
  Insert_Tipo_Ocupacion(2, 'Veterinario');
  Insert_Tipo_Ocupacion(3, 'Vacunador');
  Insert_Tipo_Ocupacion(4, 'Recepcionista');
  Insert_Tipo_Ocupacion(5, 'Gerente');
END;
/

  ------------------B. Procedimiento Insertar Tipo_Mascota---------------------

BEGIN
  Insert_Tipo_Mascota(1, 'Perro', 'Labrador');
  Insert_Tipo_Mascota(2, 'Gato', 'Siames');
  Insert_Tipo_Mascota(3, 'Ave','Canario');
END;
/

    ------------------C. Procedimiento Insertar Cliente---------------------

BEGIN
  Insert_Cliente(123, 'Camilo', 'Perez', '8-969-22', 66788888, 'juanperez@email.com', 'Via Brasil, Ciudad de Panamá');
  Insert_Cliente(456, 'Julia', 'Gonzalez', '8-549-1023', 66755555, 'gonzalez@email.com', 'Calle 50, Bella Vista');
  Insert_Cliente(789, 'Pedro', 'Rodriguez', '7-321-674', 67333333, 'pedrorodriguez@email.com', 'venida Balboa, Ancón');
END;
/


  ------------------D. Procedimiento Insertar Mascota---------------------
BEGIN

  Insert_Mascota(1, 'Max', 'M', TO_DATE('2023-01-01', 'YYYY-MM-DD'), 10, 123, 1);
  Insert_Mascota(2, 'Garfield', 'M', TO_DATE('2022-08-02', 'YYYY-MM-DD'), 5, 456, 2);
  Insert_Mascota(3, 'Lye', 'F', TO_DATE('2023-01-03', 'YYYY-MM-DD'), 1, 789, 3);
END;
/

   ------------------E. Procedimiento Insertar Empleado---------------------

BEGIN
  Insert_Empleado(1, 'Ana', 'Martinez', '8-000-001', 67554444, 1000, 1);
  Insert_Empleado(2, 'Dr. Juan', 'Gonzalez', '7-654-444', 64333333, 1500, 2);
  Insert_Empleado(3, 'Carlos', 'López', '8-643-6541', 61943221, 900, 3);
  Insert_Empleado(4, 'Camilla', 'Blanco', '8-123-432', 623131, 800, 3);
  END;
  /
  
    ------------------F. Procedimiento Insertar Servicio---------------------

BEGIN
  Insert_Servicio(1, 'Baño',30.00);
  Insert_Servicio(2, 'Manicura', 15.00);
  Insert_Servicio(3, 'Corte', 25.00);
  Insert_Servicio(4, 'Consulta Veterinaria', 20.00);
  Insert_Servicio(5, 'Vacuna', 35.00);
END;
/

SELECT * FROM Tipo_ocupacion;
SELECT * FROM Tipo_mascota;
SELECT * FROM Cliente;
SELECT * FROM Mascota;
SELECT * FROM Empleado;
SELECT * FROM Insert_Servicio;




--------------------------------------5. PROCEDIMIENTOS DE CÁLCULOS-------------------------------------
------------------------PROCEDIMIENTO 1:------------------------
CREATE OR REPLACE PROCEDURE  Aumentar_salario(
    p_id_empelado empleado.e_id_empleado%TYPE,
    p_monto NUMBER
) AS
BEGIN
    UPDATE empleado
    SET e_salario=e_salario+p_monto
    WHERE e_id_empleado=p_id_empelado;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('ERROR: No se encontró el ID.');
    WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('ERROR: Ocurrió un error en le proceso.');
END Aumentar_salario;
/

----------------------------FUNCION 1: ------------------------


CREATE OR REPLACE FUNCTION calcular_itbms(
    p_costoservicio     Servicio.s_costo%TYPE
)RETURN NUMBER IS
    itbms Factura.f_itbms%TYPE;
BEGIN
    itbms := p_costoservicio * (7 / 100);
    RETURN itbms;
EXCEPTION
    WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('ERROR: Ocurrió un error en le proceso.');
END calcular_itbms;
/




-------------------- PROCEDIMIENTO 2: ---------------------------

CREATE OR REPLACE PROCEDURE adquirir_servicio(

    p_id_cliente IN Cliente.cl_id_cliente%TYPE,
    p_id_mascota IN Mascota.m_id_mascota%TYPE,
    p_servicio IN SYS.ODCINUMBERLIST

)AS

    v_subtotal  Factura.f_total%TYPE := 0;
    v_costo  Servicio.s_costo%TYPE;
    v_itbms Factura.f_itbms%TYPE;
    v_factura Factura.f_id_factura%TYPE;
    v_total Factura.f_total%TYPE;
    v_solicitud NUMBER;
    v_comprobar NUMBER;

    CURSOR c_mascotas IS
	SELECT m_id_dueno, m_id_mascota
	FROM Mascota;
BEGIN 
    v_comprobar := 0;

    FOR i IN c_mascotas LOOP
        IF i.m_id_dueno = p_id_cliente AND i.m_id_mascota = p_id_mascota THEN
            v_factura:= seq_id_factura.NEXTVAL;
            
            INSERT INTO Factura(f_id_factura, f_fecha, f_subtotal, f_total, f_itbms, f_id_empleado)
            VALUES(v_factura, SYSDATE, 0,0, 0, 4);
            COMMIT;

            FOR i IN 1..p_servicio.COUNT LOOP
                SELECT s_costo  
                INTO v_costo
                FROM Servicio
                WHERE s_id_servicio = p_servicio(i);
                
                v_subtotal:= v_subtotal+v_costo;

                v_solicitud:= seq_id_solicitud.NEXTVAL;

                INSERT INTO Adquirir(ad_id_cliente,ad_id_factura,ad_id_servicio,ad_id_mascota,ad_id_solicitud)
                VALUES(p_id_cliente, v_factura, p_servicio(i), p_id_mascota,v_solicitud);
                COMMIT;

            END LOOP;


            v_itbms:= calcular_itbms(v_subtotal);
            v_total:=v_subtotal+v_itbms;

            UPDATE Factura
            SET f_subtotal=v_subtotal , f_total=v_total, f_itbms=v_itbms
            WHERE f_id_factura=v_factura;
            v_comprobar := 1;
        END IF;
    END LOOP;

    IF v_comprobar = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Proceso exitoso');
    ELSE
        DBMS_OUTPUT.PUT_LINE('ERROR: La macota y el dueño no concuerdan.');
    END IF;

EXCEPTION 
    WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('ERROR: No se encontró el ID.');
    WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('ERROR: Ocurrió un error en le proceso.');

END adquirir_servicio;
/

------------------PROCEDIMIETNO 3:----------------------

CREATE OR REPLACE PROCEDURE Actualizar_citas_pendientes(
    p_id_cita IN SYS.ODCINUMBERLIST
)AS 
BEGIN

    FOR i IN 1..p_id_cita.COUNT LOOP
        DELETE FROM Atencion WHERE a_id_cita = p_id_cita(i);
    END LOOP;
    COMMIT;

EXCEPTION 
    WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('ERROR: No se encontró el ID.');
    WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('ERROR: Ocurrió un error en le proceso.');

END Actualizar_citas_pendientes;
/

---------------------PROCEDIMIENTO 4------------------------
CREATE OR REPLACE PROCEDURE Actualizar_precio_servicio(
        p_porcentaje   IN  NUMBER,
        p_id_servicio   IN servicio.s_id_servicio%TYPE,
        p_tipo_actualizacion  IN  auditoria_costos.audc_tipo_cambio%TYPE
)AS
BEGIN
    IF p_tipo_actualizacion NOT IN ('descuento', 'aumento') THEN
        DBMS_OUTPUT.PUT_LINE( 'ERROR: Tipo de actualización no válido. Solo se permiten "descuento" o "aumento".');

    ELSIF p_tipo_actualizacion = 'descuento' THEN 
        UPDATE servicio
        SET s_costo=s_costo-(s_costo*(p_porcentaje/100), '999.99')
        WHERE s_id_servicio=p_id_servicio;

    ELSIF p_tipo_actualizacion = 'aumento' THEN 
        UPDATE servicio
        SET s_costo=s_costo+(s_costo*(p_porcentaje/100))
        WHERE s_id_servicio=p_id_servicio;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('ERROR: No se encontró el ID.');
    WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('ERROR: Ocurrió un error en le proceso.');
END Actualizar_precio_servicio;
/



--------------------------------- 6. TRIGGERS --------------------------------------------------


--------------------TRIGGER 1:------------------
CREATE OR REPLACE TRIGGER trg_atencion_finalizada 
    AFTER DELETE ON Atencion
    FOR EACH ROW
BEGIN
    INSERT INTO inventario_atencion(inv_num_accion,inv_tabla,inv_id_cita,inv_id_empleado,inv_id_mascota,inv_fecha,inv_estado)
    VALUES(seq_inv_num.NEXTVAL, 'atencion',:OLD.a_id_cita, :OLD.a_id_empleado, :OLD.a_id_mascota,SYSDATE, 'realizado');

END trg_atencion_finalizada;
/



--------------------TRIGGER 2:------------------
CREATE OR REPLACE TRIGGER trg_agendar_cita 
    AFTER INSERT ON Adquirir
    FOR EACH ROW
DECLARE
    v_id_cita NUMBER;
    v_descripcion servicio.s_descripcion%TYPE;
    v_servicio servicio.s_id_servicio%TYPE;
    v_empleado Empleado.e_id_empleado%TYPE;
BEGIN 
    v_servicio := :NEW.ad_id_servicio;
    v_id_cita := seq_id_cita.NEXTVAL;

    SELECT s_descripcion 
    INTO v_descripcion
    FROM Servicio
    WHERE s_id_servicio = v_servicio;

    IF v_servicio = 1 OR v_servicio=2 OR v_servicio=3 THEN
        v_empleado:=1;
    ELSIF v_servicio=4 THEN
        v_empleado:=2;
    ELSIF v_servicio=5 THEN
        v_empleado:=3;
    END IF;

    INSERT INTO Cita(c_id_cita, c_descripcion, c_fecha) 
    VALUES (v_id_cita, v_descripcion, SYSDATE);

    INSERT INTO Atencion(a_id_cita,a_id_empleado,a_id_mascota)
    VALUES(v_id_cita, v_empleado, :NEW.ad_id_mascota);

    INSERT INTO inventario_atencion(inv_num_accion,inv_tabla,inv_id_cita,inv_id_empleado,inv_id_mascota,inv_fecha,inv_estado)
    VALUES(seq_inv_num.NEXTVAL, 'atencion',v_id_cita, v_empleado, :NEW.ad_id_mascota,SYSDATE, 'pendiente');
END trg_agendar_cita;
/


---------------------------TRIGGER 3:------------------------
CREATE OR REPLACE TRIGGER trg_gestion_servicios
    AFTER UPDATE ON Servicio
    FOR EACH ROW
DECLARE 
    v_monto NUMBER;
    v_tabla NVARCHAR2(10);
    v_tipo_c NVARCHAR2(10);

BEGIN
        v_tabla:='Servicio';
        v_monto:=:NEW.s_costo-:OLD.s_costo;
        
        IF :NEW.s_costo > :OLD.s_costo THEN
            v_tipo_c:='AUMENTO';
        ELSE 
            v_tipo_c:='DESCUENTO';
        END IF;
        INSERT INTO auditoria_costos(audc_num_accion ,audc_tabla , audc_id_servicio , audc_costo_anterior ,  audc_costo_nuevo , audc_tipo_cambio , audc_diferencia,  audc_fecha_cambio)
        VALUES(seq_costos.NEXTVAL,v_tabla, :NEW.s_id_servicio,:OLD.s_costo,:NEW.s_costo,v_tipo_c,v_monto,SYSDATE );

END trg_gestion_servicios;
/


-------------------------TRIGGER 4:----------------------------------
CREATE OR REPLACE TRIGGER trg_gestion_salario
    AFTER UPDATE ON Empleado
    FOR EACH ROW
DECLARE
    v_monto NUMBER;
    v_tabla NVARCHAR2(25);
BEGIN 
    v_tabla:='EMPLEADO';

    v_monto:= :NEW.e_salario - :OLD.e_salario;

    INSERT INTO auditoria_salarial(auds_num_accion,auds_tabla,auds_id_empleado,auds_nombre,auds_apellido,auds_salario_anterior, auds_salario_nuevo, auds_monto_aumento,auds_fecha_cambio)
    VALUES(seq_trg_salarios.NEXTVAL, v_tabla, :NEW.e_id_empleado,:NEW.e_nombre,:NEW.e_apellido,:OLD.e_salario,:NEW.e_salario,v_monto,SYSDATE);
    END IF;

END trg_gestion_salario;
/



-----------------INVOCACION A PROCEDIMIENTOS PARA ADQUIRIR SERVICIOS------------------
DECLARE
  servicios SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(3, 4);
BEGIN
  adquirir_servicio(123, 1, servicios);
END;
/

DECLARE
  servicios SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(1, 2);
BEGIN
  adquirir_servicio(456, 2, servicios);
END;
/

DECLARE
  servicios SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(5);
BEGIN
  adquirir_servicio(789, 3, servicios);
END;
/

SELECT * FROM Adquirir;
SELECT * FROM Factura;
SELECT * FROM Atencion;
SELECT * FROM inventario_atencion;

-----------------ACTUALIZAR LA LISTA DE CITAS PENDIENTES POR ATENDER------------------

DECLARE
    citas SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(1, 2);
BEGIN
    Actualizar_citas_pendientes(citas);
END;
/


SELECT * FROM Adquirir;
SELECT * FROM Factura;
SELECT * FROM Atencion;
SELECT * FROM inventario_atencion;

--------------INVOCACION PARA ACTUALIZAR LOS PRECIOS DE LOS SERVICIOS QUE SE OFRECEN----------------
BEGIN 
    Actualizar_precio_servicio(20, 1, 'descuento');
    Actualizar_precio_servicio(15, 4, 'aumento');
END;
/

SELECT * FROM Servicio;
SELECT * FROM auditoria_costos;

-------------INVOCACION A PROCEDIMIENTO PARA ADQUIRIR SERVICIOS DESPUES DE ACTUALIZAR PRECIO--------------
DECLARE
  servicios SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(1, 4);
BEGIN
  adquirir_servicio(123, 1, servicios);
END;
/


SELECT * FROM Adquirir;
SELECT * FROM Factura;
SELECT * FROM Atencion;
SELECT * FROM inventario_atencion;

-------------INVOCACION PARA ACTUALIZAR (AUMENTAR) SALARIO DE LOS EMPLEADOS----------------
BEGIN
    Aumentar_salario(1, 150);
    Aumentar_salario(1, 100);
END;
/

SELECT * FROM Empleado;
SELECT * FROM auditoria_salarial;
-----------------------------------------VISTAS---------------------------------------


-----------------------1. VISTA--------------------------
CREATE OR REPLACE VIEW vista_empleado
AS
SELECT c.cl_nombre AS Nombre_Cliente, a.a_id_mascota AS ID_Mascota, m.m_nombre AS Nombre_Mascota, e.e_nombre AS Empleado_asignado, t.to_descripcion AS Ocupacion, ci.c_descripcion AS Cita_descripcion, ci.c_fecha AS Fecha_cita
FROM Mascota m
JOIN Cliente c
ON m.m_id_dueno = c.cl_id_cliente
JOIN Atencion a
ON m.m_id_mascota = a.a_id_mascota
JOIN Empleado e
ON a.a_id_empleado = e.e_id_empleado
JOIN Tipo_ocupacion t
ON e.e_ocupacion = t.to_id_tipo
JOIN Cita ci
ON a.a_id_cita = ci.c_id_cita;
/
-----------------------2.VISTA-----------------------

CREATE VIEW vista_gerente AS
SELECT
    e.e_cedula AS cedula_empleado,
    e.e_nombre AS nombre_empleado,
    e.e_apellido AS apellido_empleado,
    e.e_salario AS salario_empleado,
    t.to_descripcion AS Ocupacion
FROM Empleado e
JOIN Tipo_Ocupacion t
ON e.e_ocupacion = t.to_id_tipo;

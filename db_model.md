# Proyecto: Climatic

## Nombre de la base de datos: Termostato

> **Nota**: La ID de los objetos obtenidos es generada automáticamente por Firebase.

### Firestore Database - Colecciones

#### usuarios

- **contrasenia_usu** (String)
- **email_usu** (String)
- **nombre_usu** (String)

#### dispositivos

> **Nota**: ``codigo_dis`` se debe insertar para acceder al dispositivo en tiempo real, es como el id de la placa ESP32.

- **codigo_dis** (String)
- **correo_usu** (String)
- **estado_dis** (Boolean)
- **nombre_dis** (String)

#### historial

- **codigo_his** (String): Código asignado de la placa.
- **fecha_his** (Timestamp)
- **temp_actual_his** (Number)
- **temp_objetivo_his** (Number)

#### globalconfig

> **Nota**: Únicamente se emplea un objeto de esta colección para en base a los minutos, calcular el periodo de espera en la API del proyecto y guardar los datos en el historial de los dispositivos en el Realtime Database.

- **tiempo_espera_his** (Timestamp)

---

### Firebase Auth

- **Identificador** => `Es el correo electrónico`
- **Password** => `Contraseña`

## Real Time Database

> **Nota**: ``codigo_dis`` se proporciona como placa de fabricante del módulo ESP32, se configura desde Real Time Database.

```json
{
  "codigo_dis": {
    "temp_actual_dis": Number,
    "temp_objetivo_dis": Number
  }
}
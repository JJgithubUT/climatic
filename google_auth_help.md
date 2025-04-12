# flutter_fbase

## En el archivo ¨Yaml¨ se deben instalar las extensiones con el siguiente formato

- flutter upgrade --force

## instalación de firebase para flutter

1) instalar firebase tools:
<https://firebase.google.com/docs/cli?hl=es&authuser=0#windows-npm>
 npm install -g firebase-tools
2) dart pub global activate flutterfire_cli
3) firebase Login
4) flutterfire configure (No ejecutar en bash, si no en powershell de vscode)
5) instalar firebase core y cloud fire store
<https://pub.dev/packages/firebase_core/install>
 flutter pub add firebase_core
<https://pub.dev/packages/cloud_firestore/install>
 flutter pub add cloud_firestore
En casos extremos:

- firebase --versión
- firebase Login --reauth
- flutter clean
- flutter pub get
En casos aun más extremos
- flutter pub upgrade --force

A new Flutter project.

## google authentication

keytool -genkey -v -keystore my-release-key.keystore -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000

- Enter keystore password( llave del archivo generado ): XXXXXXXX

- Name
- Org unit
- Org unit2
- Huamantla
- Tlaxcala
- MX

Comando para abrir el archivo:

- keytool -list -v -keystore [ruta_del_nuevo_keystore] -alias my-key-alias
- keytool -list -v -keystore my-release-key.keystore -alias my-key-alias

Certificate fingerprints:
        SHA1: XXXXXXXXXXXXXXXXXXXXXx
        SHA256: XXXXXXXXXXXXXXXXXXXXXx

Configuración de proyecto

- -> Seleccionar la app(s) para android -> agregar huellla digital con el algoritmo SHA indicado

- Authentication -> Google -> habilitar -> descargar json -> reemplazar en la carpeta android/apps

## Instalar Firebase Auth y Google SignIn

- flutter pub add firebase_auth

- flutter pub add google_sign_in

### PASOS 'ULTIMOS'

flutter clean

flutter pub get

flutter pub outdated

cd android

./gradlew signinReport

### IMPORTANTE

1) LAS KEYS SE GENERAN CON `JAVA` (importante generarlas con la version que este en el build.gradle)
2) REVISAR VARIABLES DEL ENTORNO, VERIFICAR VERSIÓN DE JAVA.
    CHECAR VAR JAVA_HOME (SESIÓN DE SISTEMA)
3) LA VERSIÓN DE JAVA (build grade) DEFINE LA VERSIÓN DE FLUTTER Y DE GRADLE (kotlin)
    -- JAVA21 => FLUTTER 31
    -- JAVA17 => FLUTTER 29
4) REVISAR QUE ANDROID STUDIO ESTÉ ACTUALIZANDO
5) ACTUALIZAR FLUTTER
    -- VER LA VERSION: flutter --version
    -- ACTUALIZAR flutter upgrade --force
(5.1) - En caso de no poder actualizar a otra versión más avanzada, ejecutar:
    -- flutter channel beta
    -- flutter upgrade
    -- flutter channel stable
    -- flutter upgrade
    - Por último, antes de ir al siguiente punto, actualizar flutter:
    -- `flutter upgrade --force`
6) EL ARCHIVO .keystore DEBE ESTAR EN:
    -- tu_proyecto/android/app, Y REVISAR QUE LOS VALORES ESTÉN EN LA CONSOLA DE GOOGLE.
    TAMBIÉN PUEDES ACTUALIZAR google.services.json
7) VERIFICAR QUE LAS HUELLAS FUNCIONEN CON `gradlew signinReport` => BUILD SUCCESFUL
    -- ir a /android y ejecutar `./gradlew sininReport` en powershell de Windows
8) SI TODO ESTÁ BIEN, EJECUTAR:
    -- flutter clean
    -- flutter pub get
    -- flutter pub outdated (marca dependencias obsoletas)
9) DESINTALAR LA APP EN EL EMULADOR:
    -- adb uninstall com.example.tu.proyecto
10) CORRER EL PROYECTO, SE PUEDE CORRER CON
    -- flutter run --release
    -- (CON ESTE COMANDO LA APP SE DETIENE CON ``Alt + 0``)

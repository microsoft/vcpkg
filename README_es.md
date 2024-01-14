# Vcpkg

[中文总览](README_zh_CN.md)
[English](README.md)
[한국어](README_ko_KR.md)
[Français](README_fr.md)

Vcpkg ayuda a manejar bibliotecas de C y C++ en Windows, Linux y MacOS.
Esta herramienta y ecosistema se encuentran en constante evolución ¡Siempre apreciamos contribuciones nuevas!

Si nunca ha usado Vcpkg antes,
o si está intentando aprender a usar vcpkg, consulte nuestra sección
[Primeros pasos](#primeros-pasos) para iniciar a usar Vcpkg.

Para una descripción corta de los comandos disponibles,
una vez instalado Vcpkg puede ejecutar `vcpkg help`, o
`vcpkg help [comando]` para obtener ayuda específica de un comando.

* ports en: [vcpkg GitHub](https://github.com/microsoft/vcpkg)
* este programa en: [vcpkg-tool GitHub](https://github.com/microsoft/vcpkg-tool)
* [Slack](https://cppalliance.org/slack/), en el canal #vcpkg
* Discord: [\#include \<C++\>](https://www.includecpp.org), en el canal #🌏vcpkg
* Docs: [Documentación](https://learn.microsoft.com/vcpkg)

## Tabla de contenido

- [Vcpkg](#vcpkg)
  - [Tabla de contenido](#tabla-de-contenido)
  - [Primeros pasos](#primeros-pasos)
    - [Inicio Rápido: Windows](#inicio-rápido-windows)
    - [Inicio rápido: Unix](#inicio-rápido-unix)
    - [Instalando Herramientas de desarrollo en Linux](#instalando-herramientas-de-desarrollo-en-linux)
    - [Instalando Herramientas de desarrollo en macOS](#instalando-herramientas-de-desarrollo-en-macos)
    - [Usando Vcpkg con CMake](#usando-vcpkg-con-cmake)
      - [Visual Studio Code con CMake Tools](#visual-studio-code-con-cmake-tools)
      - [Vcpkg con proyectos de Visual Studio(CMake)](#vcpkg-con-proyectos-de-visual-studiocmake)
      - [Vcpkg con CLion](#vcpkg-con-clion)
      - [Vcpkg como Submódulo](#vcpkg-como-submódulo)
    - [Inicio rápido: Manifiestos](#inicio-rápido-manifiestos)
  - [Completado-Tab/Autocompletado](#completado-tabautocompletado)
  - [Ejemplos](#ejemplos)
  - [Contribuyendo](#contribuyendo)
  - [Licencia](#licencia)
- [Seguridad](#seguridad)
  - [Telemetría](#telemetría)

## Primeros pasos

Antes de iniciar, siga la guía ya sea para [Windows](#inicio-rápido-windows),
o [macOS y Linux](#inicio-rápido-unix) dependiendo del SO que use.

Para más información, ver [Instalando y Usando Paquetes][getting-started:using-a-package].
Si una biblioteca que necesita no está presente en el catálogo de vcpkg,
puede [abrir una incidencia en el repositorio de GitHub][contributing:submit-issue] 
donde el equipo de vcpkg y la comunidad pueden verlo, y potencialmente hacer un port a vcpkg.

Después de tener Vcpkg instalado y funcionando,
puede que desee añadir [completado con tab](#Completado-TabAutoCompletado) en su terminal.

Finalmente, si está interesado en el futuro de Vcpkg,
puede ver la guía de [archivos de manifiesto][getting-started:manifest-spec]!
esta es una característica experimental y es probable que tenga errores,
así que se recomienda revisar y [crear incidencias][contributing:submit-issue]!

### Inicio Rápido: Windows

Prerrequisitos:

- Windows 7 o superior
- [Git][getting-started:git]
- [Visual Studio][getting-started:visual-studio] 2015 Update 3 o superior con el paquete Inglés de Visual Studio.

Primero, descargue y compile vcpkg; puede ser instalado en cualquier lugar, pero por lo general recomendamos usar vcpkg  
como submódulo, asi el repositorio que lo consume puede permanecer autónomo.
Alternativamente vcpkg puede ser instalado globalmente;
recomendamos que sea en un lugar como `C:\src\vcpkg` o `C:\dev\vcpkg`, 

ya que de otra forma puede encontrarse problemas de ruta para algunos sistemas de port. 

```cmd
> git clone https://github.com/microsoft/vcpkg
> .\vcpkg\bootstrap-vcpkg.bat
```

Para instalar las bibliotecas para su proyecto, ejecute:

```cmd
> .\vcpkg\vcpkg install [paquetes a instalar]
```

también puede buscar bibliotecas que necesite usar el comando `search`:

```cmd
> .\vcpkg\vcpkg search [término de búsqueda]
```

Para poder utilizar vcpkg con Visual Studio,
ejecute el siguiente comando (puede requerir privilegios de administrador):

```cmd
> .\vcpkg\vcpkg integrate install
```

Después de esto, puede crear un nuevo proyecto que no sea de CMake(MSBuild) o abrir uno existente.
Todas las bibliotecas estarán listas para ser incluidas y
usadas en su proyecto sin configuración adicional.

Si está usando CMake con Visual Studio,
continúe [aquí](#vcpkg-con-proyectos-de-visual-studio\(CMake\)).

Para utilizar Vcpkg con CMake sin un IDE,
puede utilizar el archivo de herramientas incluido:

```cmd
> cmake -B [directorio de compilación] -S . "-DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake"
> cmake --build [directorio de compilación]
```

Con CMake, todavía necesitara `find_package` y las configuraciones adicionales de la biblioteca.
Revise la [Sección de Cmake](#usando-vcpkg-con-cmake) para más información,
incluyendo el uso de CMake con un IDE.

### Inicio rápido: Unix

Prerrequisitos para Linux:

- [Git][getting-started:git]
- [G++/GCC][getting-started:linux-gcc] >= 6

Prerrequisitos para macOS:

- [Herramientas de desarrollo de Apple][getting-started:macos-dev-tools]

Primero, descargue y compile vcpkg, puede ser instalado donde lo desee,
pero recomendamos usar vcpkg como un submodulo.

```sh
$ git clone https://github.com/microsoft/vcpkg
$ ./vcpkg/bootstrap-vcpkg.sh
```

Para instalar las bibliotecas para su proyecto, ejecute:

```sh
$ ./vcpkg/vcpkg install [paquetes a instalar]
```

Nota: por defecto se instalarán las bibliotecas x86, para instalar x64, ejecute:

```cmd
> .\vcpkg\vcpkg install [paquete a instalar]:x64-windows
```

O si desea instalar varios paquetes:

```cmd
> .\vcpkg\vcpkg install [paquetes a instalar] --triplet=x64-windows
```

También puede buscar las bibliotecas que necesita con el subcomando `search`:

```sh
$ ./vcpkg/vcpkg search [término de búsqueda]
```

Para usar vcpkg con CMake, tiene que usar el siguiente archivo toolchain:

```sh
$ cmake -B [directorio de compilación] -S . "-DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake"
$ cmake --build [directorio de compilación]
```

Con CMake, todavía necesitara `find_package` y las configuraciones adicionales de la biblioteca.
Revise la [Sección de CMake](#usando-vcpkg-con-cmake)
para más información en cómo aprovechar mejor Vcpkg con CMake,
y CMake tools para VSCode.

Para cualquier otra herramienta, visite la [guía de integración][getting-started:integration].

### Instalando Herramientas de desarrollo en Linux

Según las distribuciones de Linux, hay diferentes paquetes
que necesitará instalar:

- Debian, Ubuntu, popOS, y otra distribución basada en Debian:

```sh
$ sudo apt-get update
$ sudo apt-get install build-essential tar curl zip unzip
```

- CentOS

```sh
$ sudo yum install centos-release-scl
$ sudo yum install devtoolset-7
$ scl enable devtoolset-7 bash
```

Para cualquier otra distribución, asegúrese que dispone de g++ 6 o superior.
Si desea añadir instrucción para una distribución específica,
[cree un pull request][contributing:submit-pr]

### Instalando Herramientas de desarrollo en macOS

En macOS 10.15, solo tiene que ejecutar el siguiente comando en la terminal:

```sh
$ xcode-select --install
```

Luego seguir los pasos que aparecerán en las ventanas que se muestran.

Posteriormente podrá compilar vcpkg junto con la [guía de inicio rápido](#inicio-rápido-unix)

### Usando Vcpkg con CMake

¡Si está usando Vcpkg con CMake, lo siguiente puede ayudar!

#### Visual Studio Code con CMake Tools

Agregando lo siguiente al espacio de trabajo `settings.json` permitirá que
CMake Tools use automáticamente Vcpkg para las bibliotecas:

```json
{
  "cmake.configureSettings": {
    "CMAKE_TOOLCHAIN_FILE": "[raíz de vcpkg]/scripts/buildsystems/vcpkg.cmake"
  }
}
```

#### Vcpkg con proyectos de Visual Studio(CMake)

Abra el editor de Ajustes de CMake, bajo la sección `CMake toolchain file`,
posteriormente agregue al path el archivo de cadena de herramientas de Vcpkg:

```sh
[raíz de vcpkg]/scripts/buildsystems/vcpkg.cmake
```

#### Vcpkg con CLion

Abra los ajustes de Cadena de Herramientas (Toolchains)
(File > Settings en Windows y Linux, Clion > Preferences en macOS),
y entre en la sección de ajustes de CMake (Build, Execution, Deployment > CMake).
Finalmente, en `CMake options`, agregue la línea siguiente:

```sh
-DCMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

Desafortunadamente, tendrá que hacerlo para cada perfil.

#### Vcpkg como Submódulo

Cuando este usando Vcpkg como un submódulo para su proyecto,
puede agregar lo siguiente as su CMakeLists,txt antes de la primera llamada a `project()`,
en vez de pasar `CMAKE_TOOLCHAIN_FILE` a la invocación de CMake.

```cmake
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake"
  CACHE STRING "Vcpkg toolchain file")
```

Esto permitirá a las personas no usar Vcpkg,
indicando el `CMAKE_TOOLCHAIN_FILE` directamente,
sin embargo, hará el proceso de configuración y compilación más sencillo.

### Inicio rápido: Manifiestos

Así que desea ver cómo será el futuro de Vcpkg!
realmente lo apreciamos. Sin embargo, primero una advertencia:
el soporte de archivos de manifiesto aún está en beta,
aun así la mayoría debería funcionar,
pero no hay garantía de esto y es muy probable que encuentre uno o más bugs
mientras use Vcpkg en este modo.
Adicionalmente, es probablemente que se rompan comportamientos antes de que se pueda considerar estable,
así que está advertido.
Por favor [Abra un Problema][contributing:submit-issue] si encuentra algún error

Primero, instale vcpkg normalmente para [Windows](#inicio-rápido-windows) o
[Unix](#inicio-rápido-unix).
Puede que desee instalar Vcpkg en un lugar centralizado,
ya que el directorio existe localmente,
y está bien ejecutar múltiples comandos desde el mismo directorio de vcpkg al mismo tiempo.

Luego, se requiere activar la bandera de característica `manifests` en vcpkg agregando
`manifests` a los valores separados por coma en la opción `--feature-flags`,
o agregándole en los valores separados por coma en la variable de entorno `VCPKG_FEATURE_FLAGS`

también puede que desee agregar Vcpkg al `PATH`.

Luego, todo lo que hay que hacer es crear un manifiesto;
cree un archivo llamado `vcpkg.json`, y escriba lo siguiente:

```json
{
  "name": "<nombre de su proyecto>",
  "version-string": "<versión de su proyecto>",
  "dependencies": [
    "abseil",
    "boost"
  ]
}
```

Las bibliotecas serán instaladas en el directorio `vcpkg_installed`,
en el mismo directorio que su `vcpkg.json`.
Si puede usar el regular conjunto de herramientas de CMake,
o mediante la integración de Visual Studio/MSBuild,
este instalará las dependencias automáticamente,
pero necesitará ajustar `VcpkgManifestEnabled` en `On` para MSBuild.
Si desea instalar sus dependencias sin usar CMake o MSBuild,
puede usar un simple `vcpkg install --feature-flags=manifests`

Para más información, revise la especificación de [manifiesto][getting-started:manifest-spec]

[getting-started:using-a-package]: https://learn.microsoft.com/vcpkg/examples/installing-and-using-packages
[getting-started:git]: https://git-scm.com/downloads
[getting-started:cmake-tools]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools
[getting-started:linux-gcc]: #Instalando-Herramientas-de-desarrollo-en-Linux
[getting-started:macos-dev-tools]: #Instalando-Herramientas-de-desarrollo-en-macOS
[getting-started:visual-studio]: https://visualstudio.microsoft.com/
[getting-started:manifest-spec]: https://learn.microsoft.com/en-us/vcpkg/users/manifests

## Completado-Tab/Autocompletado

`vcpkg` soporta autocompletado para los comandos, nombres de paquetes,
y opciones, tanto en PowerShell como en bash.
para activar el autocompletado en la terminal de elección ejecute:

```pwsh
> .\vcpkg integrate powershell
```

o

```sh
$ ./vcpkg integrate bash # o zsh
```

según la terminal que use, luego reinicie la consola.

## Ejemplos

ver la [documentación](https://learn.microsoft.com/vcpkg) para tutoriales específicos, incluyendo
[instalando y usando un paquete](https://learn.microsoft.com/vcpkg/examples/installing-and-using-packages),
[agregando un nuevo paquete desde un archivo comprimido](https://learn.microsoft.com/vcpkg/examples/packaging-zipfiles),
[agregando un nuevo paquete desde un repositorio en GitHub](https://learn.microsoft.com/vcpkg/examples/packaging-github-repos).

Nuestra documentación también esta disponible en nuestro sitio web [vcpkg.io](https://vcpkg.io/).
Si necesita ayuda puede [crear un incidente](https://github.com/vcpkg/vcpkg.github.io/issues).
¡Apreciamos cualquier retroalimentación!

Ver un [video de demostración](https://www.youtube.com/watch?v=y41WFKbQFTw) de 4 minutos.

## Contribuyendo

Vcpkg es un proyecto de código abierto, y está construido con sus contribuciones.
Aquí hay unas de las maneras en las que puede contribuir:

* [Creando Incidencias][contributing:submit-issue] en vcpkg o paquetes existentes
* [Creando Correcciones y Nuevos Paquetes][contributing:submit-pr]

Por favor visite nuestra [Guía de Contribución](CONTRIBUTING.md) para más detalles.

Este proyecto ha adoptado el [Código de Conducta de Microsoft de Código Abierto][contributing:coc].
Para más información ver [Preguntas frecuentes del Código de Conducta][contributing:coc-faq]
o envíe un correo a [opencode@microsoft.com](mailto:opencode@microsoft.com)
con cualquier pregunta adicional o comentarios.

[contributing:submit-issue]: https://github.com/microsoft/vcpkg/issues/new/choose
[contributing:submit-pr]: https://github.com/microsoft/vcpkg/pulls
[contributing:coc]: https://opensource.microsoft.com/codeofconduct/
[contributing:coc-faq]: https://opensource.microsoft.com/codeofconduct/

## Licencia

El código en este repositorio se encuentra licenciado mediante la [Licencia MIT](LICENSE.txt).
Las bibliotecas proveídas por los `ports` están licenciadas mediante los terminos de los autores originales.
Donde estén disponibles, vcpkg almacena las licencias asociadas en la siguiente ubicación `installed/<triplet>/share/<port>/copyright`.

# Seguridad

La mayoría de los `ports` en vcpkg construyen las bibliotecas usando su sistema de compilación preferido
por los autores originales de las bibliotecas, y descargan el código fuente asi como las herramientas de compilación
de sus ubicaciones de distribucion oficiales. Para aquellos que usan un firewall, el acceso dependerá de cuales `ports`
están siendo instalados. Si tiene que instalarlos en un entorno aislado, puede instalarlos previamente en un entorno
no aislado, generando un [caché del paquete](https://learn.microsoft.com/vcpkg/users/assetcaching) compartido con el entorno aislado.

## Telemetría

vcpkg recolecta datos de uso para mejorar su experiencia.
La información obtenida por Microsoft es anónima.
puede ser dado de baja de la telemetría realizando lo siguiente:

- ejecutar el script `bootstrap-vcpkg` con el parametro `-disableMetrics`
- agregar el parametro `--disable-metrics` a vcpkg en la línea de comandos
- agregar la variable de entorno `VCPKG_DISABLE_METRICS`

Se puede leer más sobre la telemetría de vcpkg en [https://learn.microsoft.com/vcpkg/about/privacy](https://learn.microsoft.com/vcpkg/about/privacy).

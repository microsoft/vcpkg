# Vcpkg

Vcpkg ayuda a manejar librerías de C y C++ en Windows, Linux y MacOS.
Esta herramienta y ecosistema se encuentran en constante evolución ¡Siempre apreciamos contribuciones nuevas!

Si nunca ha usado Vcpkg antes,
o si está intentando aprender a usar vcpkg, consulte nuestra sección
[Primeros pasos](#primeros-pasos) para iniciar a usar Vcpkg.

Para una descripción corta de los comandos disponibles,
una vez instalado Vcpkg puede ejecutar `vcpkg help`, o
`vcpkg help [comando]` para obtener ayuda específica de un comando.

* Github: [https://github.com/microsoft/vcpkg](https://github.com/microsoft/vcpkg)
* Slack: [https://cppalliance.org/slack/](https://cppalliance.org/slack/), en el canal #vcpkg
* Discord: [\#include \<C++\>](https://www.includecpp.org), en el canal #🌏vcpkg
* Docs: [Documentación](docs/index.md)

[![Estado de compilación](https://dev.azure.com/vcpkg/public/_apis/build/status/microsoft.vcpkg.ci?branchName=master)](https://dev.azure.com/vcpkg/public/_build/latest?definitionId=29&branchName=master)

## Tabla de contenido

* [Vcpkg: General](#vcpkg-general)
* [Tabla de contenidos](#tabla-de-contenidos)
* ["Primeros pasos"](#primeros-pasos)
  + [Inicio rápido: Windows](#inicio-rápido-windows)
  + [Inicio rápido: Unix](#inicio-rápido-unix)
  + [Instalando herramientas de desarrollo en Linux](#instalando-herramientas-de-desarrollo-en-Linux)
  + [Instalando herramientas de desarrollo en macOS](#instalando-herramientas-de-desarrollo-en-macos)
    - [Instalando GCC en MacOS previo a 10.15](#instalando-gcc-en-macos-previo-a-10.15)
  + [Usando Vcpkg con CMake](#usando-vcpkg-con-cmake)
    - [Visual Studio Code con CMake Tools](#visual-studio-code-con-cmake-tools)
    - [Vcpkg con proyectos de Visual Studio (CMake)](#vcpkg-con-proyectos-de-visual-studio\(CMake\))
    - [Vcpkg con CLion](#vcpkg-con-clion)
    - [Vcpkg como submódulo](#vcpkg-como-submódulo)
  + [Inicio rápido: archivos de Manifiesto](#inicio-rápido-manifiestos)
* [Tab-Completado/Autocompletado](#Completado-TabAutocompletado)
* [Ejemplos](#ejemplos)
* [Contribuyendo](#contribuyendo)
* [Licencia](#licencia)
* [telemetría](#telemetría)

## Primeros pasos

Antes de iniciar, siga la guía ya sea para [Windows](#inicio-rápido-windows),
o [macOS y Linux](#inicio-rápido-unix) dependiendo del SO que use.

Para más información, ver [Instalando y Usando Paquetes][getting-started:using-a-package].
Si una librería que necesita no está presente en el catálogo de vcpkg,
puede [abrir una incidencia en el repositorio de GitHub][contributing:submit-issue] 
donde el equipo de vcpkg y la comunidad pueden verlo, y potencialmente hacer un port a vcpkg.

Después de tener Vcpkg instalado y funcionando,
puede que desee añadir [completado con tab](#Completado-TabAuto-Completado) en su terminal.

Finalmente, si está interesado en el futuro de Vcpkg,
puede ver la guía de [archivos de manifiesto][getting-started:manifest-spec]!
esta es una característica experimental y es probable que tenga errores,
así que se recomienda revisar y [crear incidencias][contributing:submit-issue]!

### Inicio Rápido: Windows

Prerrequisitos:

- Windows 7 o superior
- [Git][getting-started:git]
- [Visual Studio][getting-started:visual-studio] 2015 Update 3 o superior con el paquete Inglés de Visual Studio.

Primero, descargue y compile vcpkg; puede ser instalado en cualquier lugar,
pero generalmente recomendamos usar vcpkg como submódulo para proyectos de CMake,
e instalándolo globalmente para Proyectos de Visual Studio.
recomendamos un lugar como `C:\src\vcpkg` o `C:\dev\vcpkg`,
ya que de otra forma puede encontrarse problemas de ruta para algunos sistemas de port.

```cmd
> git clone https://github.com/microsoft/vcpkg
> .\vcpkg\bootstrap-vcpkg.bat
```

Para instalar las librerías para su proyecto, ejecute:

```cmd
> .\vcpkg\vcpkg install [paquetes a instalar]
```

también puede buscar librerías que necesite usar el comando `search`:

```cmd
> .\vcpkg\vcpkg search [término de búsqueda]
```

Para poder utilizar vcpkg con Visual Studio,
ejecute el siguiente comando (puede requerir privilegios de administrador):

```cmd
> .\vcpkg\vcpkg integrate install
```

Después de esto, puede crear un nuevo proyecto que no sea de CMake(MSBuild) o abrir uno existente.
Todas las librerías estarán listas para ser incluidas y
usadas en su proyecto sin configuración adicional.

Si está usando CMake con Visual Studio,
continúe [aquí](#vcpkg-con-proyectos-de-visual-studio\(CMake\)).

Para utilizar Vcpkg con CMake sin un IDE,
puede utilizar el archivo de herramientas incluido:

```cmd
> cmake -B [directorio de compilación] -S . -DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake
> cmake --build [directorio de compilación]
```

Con CMake, todavía necesitara `find_package` y las configuraciones adicionales de la librería.
Revise la [Sección de Cmake](#usando-vcpkg-con-cmake) para más información,
incluyendo el uso de CMake con un IDE.

Para cualquier otra herramienta, incluyendo Visual Studio Code,
reviste la [guía de integración][getting-started:integration].

### Inicio rápido: Unix

Prerrequisitos para Linux:

- [Git][getting-started:git]
- [G++/GCC][getting-started:linux-gcc] >= 6

Prerrequisitos para macOS:

- [Herramientas de desarrollo de Apple][getting-started:macos-dev-tools]
- En macOS 10.14 o inferior, también necesita:
  - [Homebrew][getting-started:macos-brew]
  - [g++][getting-started:macos-gcc] >= 6 de Homebrew

Primero, descargue y compile vcpkg, puede ser instalado donde sea,
pero recomendamos usar vcpkg como submodulo para proyectos de CMake.

```sh
$ git clone https://github.com/microsoft/vcpkg
$ ./vcpkg/bootstrap-vcpkg.sh
```

Para instalar las librerías para su proyecto, ejecute:

```sh
$ ./vcpkg/vcpkg install [paquetes a instalar]
```

También puede buscar las librerías que necesita con el subcomando `search`:

```sh
$ ./vcpkg/vcpkg search [término de búsqueda]
```

Para usar vcpkg con CMake, tiene que usar el siguiente archivo toolchain:

```sh
$ cmake -B [directorio de compilación] -S . -DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake
$ cmake --build [directorio de compilación]
```

Con CMake, todavía necesitara `find_package` y las configuraciones adicionales de la librería.
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

En macOS 10.14 y previos, también requiere instalar g++ de homebrew;
siguiendo los pasos en la sección siguiente.

#### Instalando GCC en macOS previo a 10.15

Este paso _solo_  es requerido si está usando una versión de macOS previa a 10.15.
Instalar homebrew debería ser sencillo; visite <brew.sh> para mas información,
pero de manera simple, ejecute el siguiente comando:

```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

luego, para obtener una versión actualizada de gcc, ejecute el comando:

```sh
$ brew install gcc
```

Posteriormente podrá compilar vcpkg junto con la [guía de inicio rápido](#inicio-rápido-unix)

### Usando Vcpkg con CMake

¡Si está usando Vcpkg con CMake, lo siguiente puede ayudar!

#### Visual Studio Code con CMake Tools

Agregando lo siguiente al espacio de trabajo `settings.json` permitirá que
CMake Tools use automáticamente Vcpkg para las librerías:

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
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake
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

Las librerías serán instaladas en el directorio `vcpkg_installed`,
en el mismo directorio que su `vcpkg.json`.
Si puede usar el regular conjunto de herramientas de CMake,
o mediante la integración de Visual Studio/MSBuild,
este instalará las dependencias automáticamente,
pero necesitará ajustar `VcpkgManifestEnabled` en `On` para MSBuild.
Si desea instalar sus dependencias sin usar CMake o MSBuild,
puede usar un simple `vcpkg install --feature-flags=manifests`

Para más información, revise la especificación de [manifiesto][getting-started:manifest-spec]

[getting-started:using-a-package]: docs/examples/installing-and-using-packages.md
[getting-started:integration]: docs/users/integration.md
[getting-started:git]: https://git-scm.com/downloads
[getting-started:cmake-tools]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools
[getting-started:linux-gcc]: #installing-linux-developer-tools
[getting-started:macos-dev-tools]: #installing-macos-developer-tools
[getting-started:macos-brew]: #installing-gcc-on-macos
[getting-started:macos-gcc]: #installing-gcc-on-macos
[getting-started:visual-studio]: https://visualstudio.microsoft.com/
[getting-started:manifest-spec]: docs/specifications/manifests.md

## Completado-Tab/Autocompletado

`vcpkg` soporta autocompletado para los comandos, nombres de paquetes,
y opciones, tanto en PowerShell como en bash.
para activar el autocompletado en la terminal de elección ejecute:

```pwsh
> .\vcpkg integrate powershell
```

o

```sh
$ ./vcpkg integrate bash
```

según la terminal que use, luego reinicie la consola.

## Ejemplos

ver la [documentación](docs/index.md) para tutoriales específicos, incluyendo
[instalando y usando un paquete](docs/examples/installing-and-using-packages.md),
[agregando un nuevo paquete desde un archivo comprimido](docs/examples/packaging-zipfiles.md),
[agregando un nuevo paquete desde un repositorio en GitHub](docs/examples/packaging-github-repos.md).

Nuestra documentación se encuentra online en ReadTheDocs: <https://vcpkg.readthedocs.io/>!

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

## Telemetría

vcpkg recolecta datos de uso para mejorar su experiencia.
La información obtenida por Microsoft es anónima.
puede ser dado de baja de la telemetría ejecutando de nuevo el script `bootstrap-vcpkg` con `-disableMetrics`,
pasando `--disable-metrics` a vcpkg en la línea de comandos,
o creando la variable de entorno `VCPKG_DISABLE_METRICS`.

Se puede leer más sobre la telemetría de vcpkg en docs/about/privacy.md

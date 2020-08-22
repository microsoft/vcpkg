# Vcpkg

Vcpkg ayuda a manejar librerías de C y C++ en Windows, Linux y MacOS.
Esta herramienta y ecosistema se encuentran en constante evolución ¡Siempre apreciamos contribuciones nuevas!

Si nunca ha usado vcpkg antes,
o si está intentando aprender a usar vcpkg, consulte nuestra sección
[Primeros pasos](#primeros-pasos) para iniciar a usar vcpkg.

Para una descripción corta de los comandos disponibles,
una vez instalado vcpkg puede ejecutar `vcpkg help`, o
`vcpkg help [comando]` para obtener ayuda específica de un comando.

* Github: [https://github.com/microsoft/vcpkg](https://github.com/microsoft/vcpkg)
* Slack: [https://cppalliance.org/slack/](https://cppalliance.org/slack/), en el canal #vcpkg
* Discord: [\#include \<C++\>](https://www.includecpp.org), en el canal #🌏vcpkg
* Docs: [Documentacion](docs/index.md)

[![Estado de compilacion](https://dev.azure.com/vcpkg/public/_apis/build/status/microsoft.vcpkg.ci?branchName=master)](https://dev.azure.com/vcpkg/public/_build/latest?definitionId=29&branchName=master)

## Tabla de contenidos

* [Vcpkg: General](#vcpkg-general)
* [Table de contenidos](#tabla-de-contenidos)
* [Primeros pasos](#primeros-pasos)
  + [Inicio rápido: Windows](#inicio-rapido-windows)
  + [Inicio rápido: Unix](#inicio-rapido-unix)
  + [Instalando herramientas de desarrollo en Linux](#instalando-herramientas-de-desarrollo-en-Linux)
  + [Instalando herramientas de desarrollo en macOS](#instalando-herramientas-de-desarrollo-en-macos)
    - [Instalando GCC en MacOS previo a 10.15](#instalando-gcc-en-macos-previo-a-10.15)
  + [Usando vcpkg con CMake](#usando-vcpkg-con-cmake)
    - [Visual Studio Code con CMake Tools](#visual-studio-code-con-cmake-tools)
    - [Vcpkg con proyectos de Visual Studio (CMake)](#vcpkg-con-proyectos-de-visual-studio\(CMake\))
    - [Vcpkg con CLion](#vcpkg-con-clion)
    - [Vcpkg como submódulo](#vcpkg-como-submodulo)
  + [Inicio rápido: archivos de Manifiesto](#inicio-rapido-manifiestos)
* [Tab-Completado/Autocompletado](#Completado-TabAutocompletado)
* [Ejemplos](#ejemplos)
* [Contribuyendo](#contribuyendo)
* [Licencia](#licencia)
* [Telemetria](#telemetría)

## Primeros pasos

Antes de iniciar, siga la guía ya sea para [Windows](#inicio-rapido-windows),
o [macOS y Linux](#inicio-rapido-unix) dependiendo del SO que use.

Para mas informacion, ver [Instalando y Usando Paquetes][getting-started:using-a-package].
Si una libreria que nescesita no esta presente en el catalogo de vcpkg,
puede [abrir un issue en el repo de GitHub][contributing:submit-issue] 
donde el equipo de vpkg y la comunidad pueden verlo, y potencialmente hacer un port a vcpkg.

Despues de tener vcpkg instalado y funcionando,
puede que desee añadir [completado con tab](#Completado-TabAuto-Completado) en su terminal.

finalmente si esta interesado en el futuro de vcpkg,
puede ver la guía de [archivos de manifiesto](#inicio-rapido-manifiesto)!
esta es una caracteristica experimental y es probable que tenga errores,
asi que pruebe y [abra todos los issues][contributing:submit-issue]!

### Inicio Rapido: Windows

Pre-requisitos:

- Windows 7 o superior
- [Git][getting-started:git]
- [Visual Studio][getting-started:visual-studio] 2015 Update 3 o superior con el paquete Ingles de Visual Studio.

Primero, descargue y compile vcpkg; puede ser instalado en cualquier lugar,
pero generamente recomendamos usar vcpkg como submodulo para proyectos de CMake,
y instalandolo globalmente para Proyectos de Visual Studio.
recomendamos un lugar como `C:\src\vcpkg` o `C:\dev\vcpkg`,
ya que de otra forma puede encontrarse problemas de ruta para algunos sistemas de port.

```cmd
> git clone https://github.com/microsoft/vcpkg
> .\vcpkg\bootstrap-vcpkg.bat
```

Para instalar las librerias para su proyecto, ejecute:

```cmd
> .\vcpkg\vcpkg install [paquetes a instalar]
```

tambien puede buscar librerias que nescesite usar el comando `search`:

```cmd
> .\vcpkg\vcpkg search [termino de busqueda]
```

Para poder utilizar vcpkg con Visual Studio,
ejecute el siguiente comando (puede requerir privilegios de administrador):

```cmd
> .\vcpkg\vcpkg integrate install
```

Despues de esto, puede crear un nuevo proyecto que no sea de CMake(MSBuild) o abrir uno existente.
Todas las librerias estaran listas para ser incluidas y
usadas en su proyecto sin configuracion adicional.

Si esta usando CMake con Visual Studio,
continue [aquí](#vcpkg-con-proyectos-de-visual-studio\(CMake\)).

Para utilizar vcpkg con CMake sin un IDE,
puede utilizar el archivo toolchain:

```cmd
> cmake -B [build directory] -S . -DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake
> cmake --build [build directory]
```

Con CMake, todavia necesitara `find_package` y la configuraciones adicionales de la libreria.
Revise la [Seccion de Cmake](#usando-vcpkg-con-cmake) para mas informacion,
incluyendo el uso de CMake con un IDE.

Para cualquier otra herramienta, incluyendo Visual Studio Code,
reviste la [guía de integracion][getting-started:integration].

### Inicio Rapido: Unix

Pre-requisitos for Linux:

- [Git][getting-started:git]
- [g++][getting-started:linux-gcc] >= 6

Pre-requisitos para macOS:

- [Herramientas de desarrollo de Apple][getting-started:macos-dev-tools]
- En macOS 10.14 o inferior, tambien necesita:
  - [Homebrew][getting-started:macos-brew]
  - [g++][getting-started:macos-gcc] >= 6 de Homebrew

Primero, descargue y compile vcpkg, puede ser instalado donde sea,
pero recomendamos usar vcpkg como submodulo para proyectos de CMake.

```sh
$ git clone https://github.com/microsoft/vcpkg
$ ./vcpkg/bootstrap-vcpkg.sh
```

Para instalar las librerias para su proyecto, ejecute:

```sh
$ ./vcpkg/vcpkg install [paquetes a instalar]
```

Tambien puede buscar las librerias que necesita con el subcomando `search`:

```sh
$ ./vcpkg/vcpkg search [search term]
```

Para usar vcpkg con CMake, tiene que usar el siguiente archivo toolchain:

```sh
$ cmake -B [build directory] -S . -DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake
$ cmake --build [build directory]
```

Con CMake, todavia necesitara `find_package` y la configuraciones adicionales de la libreria.
Revise la [Seccion de Cmake](#usando-vcpkg-con-cmake)
para mas informacion en como aprovechar mejor vcpkg con CMake,
y CMake tools para VSCode.

Para cualquier otra herramienta, visite la [guía de integracion][getting-started:integration].

### Instalando Herramientas de desarrollo en Linux

Segun las distribuciones de Linux, hay diferentes paquetes
que necesitara instalar:

- Debian, Ubuntu, popOS, y otra distribucion basada en Debian:

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

Para cualquier otra distribucion, asegurese que dispone de g++ 6 o superior.
Si desea añadir instrucion para una distro especifica,
[cree un pull request][contributing:submit-pr]!

### Instalando Herramientas de desarrollo en macOS

En macOS 10.15, solo tiene que ejecutar el siguiente comando en la terminal:

```sh
$ xcode-select --install
```

Luego seguir los pasos que apareceran en las ventanas que se muestren.

En macOS 10.14 y previos, tambien requiere instalar g++ de homebrew;
siguiendo los pasos en la seccion siguiente.

#### Instalando GCC en macOS previo a 10.15

Este paso _solo_ es requerido si esta usando una version de macOS previa a 10.15.
Instalar homebrew deberia ser sencillo; visite <brew.sh> para mas informacion,
pero de manera simple, ejecute el siguiente comando:

```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

luego, para obtener una version actualizada de gcc, ejecute el comando:

```sh
$ brew install gcc
```

Posteriormente podra compilar vcpkg junto con la [guia de inicio rapido](#inicio-rapido-unix)

### Usando vcpkg con CMake

Si esta usando vcpkg con CMake, lo siguiente puede ayudar!

#### Visual Studio Code con CMake Tools

Agregando lo siguiente al espacio de trabajo `settings.json` permitira que
CMake Tools use automaticamente vcpkg para las librerias:

```json
{
  "cmake.configureSettings": {
    "CMAKE_TOOLCHAIN_FILE": "[raiz de vcpkg]/scripts/buildsystems/vcpkg.cmake"
  }
}
```

#### Vcpkg con proyectos de Visual Studio(CMake)

Abra el editor de Ajustes de CMake, bajo la seccion `CMake toolchain file`,
posteriormente agregue al path el archivo toolchain de vcpkg:

```sh
[raiz de vcpkg]/scripts/buildsystems/vcpkg.cmake
```

#### Vcpkg con CLion

Abra los ajustes de Toolchains
(File > Settings en Windows y Linux, Clion > Preferences en macOS),
y entre en la seccion de ajustes de CMake (Build, Execution, Deployment > CMake).
Finalmente, en `CMake options`, agregue la linea siguiente:

```sh
-DCMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

Desafortunadamente, tendra que hacerlo para cada perfil.

#### Vcpkg como Submodulo

Cuando este usando vcpkg como un submodulo para su proyecto,
puede agregar lo siguiente as su CMakeLists,txt antes de la primera llamada a `project()`,
en vez de pasar `CMAKE_TOOLCHAIN_FILE` a la invocacion de CMake.

```cmake
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake
  CACHE STRING "Vcpkg toolchain file")
```

Esto permitira a las personas no usar vcpkg,
indicando el `CMAKE_TOOLCHAIN_FILE` directamente,
sin embargo hara el proceso de configuracion y compilacion mas sencillo.

### Inicio rapido: Manifiestos

Asi, que desea ver como sera el futuro de vcpkg!
realmente lo apreciamos. Sin embargo, primero una advertencia:
el soporte de archivos de manifiesto aun esta en beta,
aún asi la mayoria deberia funcionar,
pero no hay garantia de esto y es muy probable que encuentre uno o mas bugs
mientras use vcpkg en este modo.
Adicionalmente, es probablemente que se rompan comportamientos antes de estabilizarlo,
asi que esta advertido.
Por favor [Abra un Problema][contributing:submit-issue] si encuentra algun error

Primero, instale vcpkg normalmente para [Windows](#inicio-rapido-windows) o
[Unix](#inicio-rapido-unix).
Puede que desee instalar vcpkg en un lugar centralizado,
ya que el directorio existe localmente,
y esta bien ejecutar multiples comandos desde el mismo directorio de vcpkg al mismo tiempo.

Luego, se requiere activar la bandera de caracteristica `manifests` en vcpkg agregando
`manifests` a los valores separados por coma en la opcion `--feature-flags`,
o agregandolo en los valores separados por coma en la variable de entorno `VCPKG_FEATURE_FLAGS`

tambien puede que desee agregar vcpkg al `PATH`.

Luego, todo lo que hay que hacer es crear un manifiesto;
cree un archivo llamado `vcpkg.json`, y escriba lo siguiente:

```json
{
  "name": "<nombre de su proyecto>",
  "version-string": "<version de su proyecto>",
  "dependencies": [
    "abseil",
    "boost"
  ]
}
```

Las librerias seran instaladas en el directorio `vcpkg_installed`,
en el mismo directorio que su `vcpkg.json`.
Si puede usar el regular conjunto de herramientas de CMake,
o mediante la integracion de Visual Studio/MSBuild,
este instalara las dependencias automaticamente,
pero necesitara ajustar `VcpkgManifestEnabled` en `On` para MSBuild.
Si desea instalar sus dependencias sin usar CMake o MSBuild,
puede usar un simple `vcpkg install --feature-flags=manifests`

Para mas informacion, revise la especificacion de [manifiesto][getting-started:manifest-spec]

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

## Completado-Tab/Auto-Completado

`vcpkg` soporta auto-completado para los comandos, nombres de paquetes,
y opciones, tanto en powershell como en bash.
para activar el autocompletado en la terminal de eleccion ejecute:

```pwsh
> .\vcpkg integrate powershell
```

o

```sh
$ ./vcpkg integrate bash
```

segun su terminal que use, luego reinicie la consola.

## Ejemplos

ver la [documentacion](docs/index.md) para tutoriales especificos, incluyendo
[instalando y usinando un paquete](docs/examples/installing-and-using-packages.md),
[agregando un nuevo paquete desde un archivo comprimido](docs/examples/packaging-zipfiles.md),
[agregando un nuevo paquete desde un repositorio en GitHub](docs/examples/packaging-github-repos.md).

Nuestra documentacion se encuentra online en ReadTheDocs: <https://vcpkg.readthedocs.io/>!

Ver un [video de demostracion](https://www.youtube.com/watch?v=y41WFKbQFTw) de 4 minutos.

## Contribuyendo

Vcpkg es un proyecto de codigo abierto, y esta construido con sus contribuciones.
Aqui hay unas de las maneras en las que puede contribuir:

* [Creando Issues][contributing:submit-issue] en vcpkg o paquetes existentes
* [Creando Correcciones y Nuevos Paquetes][contributing:submit-pr]

Por favor visite nuestra [Guía de Contribucion](CONTRIBUTING.md) para mas detalles.

Este proyecto ha adoptado el [Codigo de Conducta de Microsoft de Codigo Abierto][contributing:coc].
Para mas informacion ver [Preguntas frecuentes del Codigo de Conducta][contributing:coc-faq]
o envie un correo a [opencode@microsoft.com](mailto:opencode@microsoft.com)
con cualquier pregunta adicional o comentarios.

[contributing:submit-issue]: https://github.com/microsoft/vcpkg/issues/new/choose
[contributing:submit-pr]: https://github.com/microsoft/vcpkg/pulls
[contributing:coc]: https://opensource.microsoft.com/codeofconduct/
[contributing:coc-faq]: https://opensource.microsoft.com/codeofconduct/

## Licencia

El codigo en este repositorio se encuentra licenciado mediante la [Licencia MIT](LICENSE.txt).

## Telemetria

vcpkg recolecta datos de uso para mejorar su experiencia.
La informacion obtenida por Microsoft es anonima.
puede ser dado de baja de la telemetria ejecutando de nuevo el script `bootstrap-vcpkg` con `-disableMetrics`,
pasando `--disable-metrics` a vcpkg en la linea de comandos,
o creando la variable de entorno `VCPKG_DISABLE_METRICS`.

Se puede leer mas sobre la telemetria de vcpkg en docs/about/privacy.md

# vcpkg_qmake_configure

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-qmake/vcpkg_qmake_configure.md).

Configure a qmake-based project.

###User setable triplet variables:
VCPKG_OSX_DEPLOYMENT_TARGET: Determines QMAKE_MACOSX_DEPLOYMENT_TARGET
VCPKG_QMAKE_COMMAND: Path to qmake. (default: "${CURRENT_HOST_INSTALLED_DIR}/tools/Qt6/bin/qmake${VCPKG_HOST_EXECUTABLE_SUFFIX}")
VCPKG_QT_CONF_(RELEASE|DEBUG): Path to qt.config being used for RELEASE/DEBUG. (default: "${CURRENT_INSTALLED_DIR}/tools/Qt6/qt_(release|debug).conf")
VCPKG_QMAKE_OPTIONS(_RELEASE|_DEBUG)?: Extra options to pass to QMake

```cmake
vcpkg_qmake_configure(
    SOURCE_PATH <pro_file_path>
    [QMAKE_OPTIONS arg1 [arg2 ...]]
    [QMAKE_OPTIONS_RELEASE arg1 [arg2 ...]]
    [QMAKE_OPTIONS_DEBUG arg1 [arg2 ...]]
    [OPTIONS arg1 [arg2 ...]]
    [OPTIONS_RELEASE arg1 [arg2 ...]]
    [OPTIONS_DEBUG arg1 [arg2 ...]]
)
```

### SOURCE_PATH
The path to the *.pro qmake project file.

### QMAKE_OPTIONS, QMAKE_OPTIONS\_RELEASE, QMAKE_OPTIONS\_DEBUG
options directly passed to qmake with the form QMAKE_X=something or CONFIG=something 

### OPTIONS, OPTIONS\_RELEASE, OPTIONS\_DEBUG
The options passed after -- to qmake.


## Source
[ports/vcpkg-qmake/vcpkg\_qmake\_configure.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-qmake/vcpkg_qmake_configure.cmake)

set(QT_VERSION 6.2.4)

if(PORT MATCHES "qtquickcontrols2")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    message(STATUS "qtquickcontrols2 is integrated in qtdeclarative since Qt 6.2. Please remove your dependency on it!")
    return()
endif()

### Setting up the git tag.
set(QT_FETCH_REF "")
set(QT_GIT_TAG "v${QT_VERSION}")
if(PORT MATCHES "qtdeviceutilities|qtlocation|qtinterfaceframework|qtapplicationmanager")
    # So much for consistency ....
    set(QT_FETCH_REF FETCH_REF "${QT_VERSION}")
    set(QT_GIT_TAG "${QT_VERSION}")
endif()

#set(QT_UPDATE_VERSION TRUE)
if(QT_UPDATE_VERSION)
    function(vcpkg_extract_source_archive)
    endfunction()
endif()

set(QT_PORTS qt
             qtbase 
             qttools 
             qtdeclarative
             qtsvg
             qt5compat
             qtshadertools
             qtquicktimeline
             qtquick3d
             qttranslations
             qtwayland
             qtdoc
             qtcoap
             qtopcua
             qtimageformats
             qtmqtt
             qtnetworkauth
             # qtquickcontrols2 -> moved into qtdeclarative
             ## New in 6.1
             qtactiveqt
             qtdatavis3d
             qtdeviceutilities
             qtlottie
             qtscxml
             qtvirtualkeyboard
             qtcharts
             ## New in 6.2
             qtconnectivity
             qtpositioning
             qtlocation
             qtmultimedia
             qtremoteobjects
             qtsensors
             qtserialbus
             qtserialport
             qtwebchannel
             qtwebengine
             qtwebsockets
             qtwebview
             ## New in 6.2.2
             qtinterfaceframework
             qtapplicationmanager
    )

foreach(_port IN LISTS QT_PORTS)
    set(${_port}_TAG ${QT_GIT_TAG})
endforeach()
set(qtbase_REF                  597359f7d0736917123842dee63a7ae45522eb8e )
set(qtshadertools_REF           d954aeb073375ee1edda4d6b2956c3c79b26b386 )
set(qtdeclarative_REF           614d85d460fa46e947eeb4281609ce5453a29e5c )
set(qt5compat_REF               c5dab10ba77dd2701dbd2d7b69998fbee90557f2 )
set(qttools_REF                 a60e0e5dfb2af83ffb1adda28028b24e21fe9131 ) # Additional refs below
set(qtcoap_REF                  29df645fc165087e74b603e7ad20033381006fb5 )
set(qtdoc_REF                   5c70158a15f23224a76b6919ab06eefee6ed187e )
set(qtimageformats_REF          356fb7846b5bc002b2d34e23253fda1dffed7932 )
set(qtmqtt_REF                  9ad6c48474c2b94c62a518dc3dc7e65d30a6309e )
set(qtnetworkauth_REF           d5ffb7549dd1e6139b746021c4d40053d0f15950 )
set(qtopcua_REF                 4a0dd4334d98bea48acda1e203ab2c31f207bad3 )
set(qtquicktimeline_REF         6a06bdbaa55d1c165e992732f2e3dc923846b921 )
set(qtquick3d_REF               d126dea81f48386ef24e8b30e1328c40e72c4861 )
set(qtsvg_REF                   77ea18adfb91c591f249f442e0ffc0079023e431 )
set(qttranslations_REF          87f95df09b1fc388ea15ce208a349d6b1deac2a4 )
set(qtwayland_REF               6bdaed8301336750dda95823ed0dfac4828ebab6 )
### New in 6.1
set(qtactiveqt_REF              5dd7acd1395627e6bd0d87beb148957059c1a3c6 )
set(qtcharts_REF                7184ea521d04ec13587562c3275ae698fa9a722e )
set(qtdatavis3d_REF             74c469d4926f59264c5cbc47fe301fe4713aa358 )
set(qtdeviceutilities_REF       f7333510b4dcfe32eb9065a63c434704750d4fb6 )
set(qtlottie_REF                fd61d8e92cfacbd3d10f31b176a7cde911525632 )
set(qtscxml_REF                 63455c888e012fdc682c32fd3d0de96127721bd4 )
set(qtvirtualkeyboard_REF       ffe9bba23ae45662d25ac3d90167d794e0d6c828 )
### New in 6.2
set(qtconnectivity_REF          f0ac95d1685f4f0f2e72fb42800b17d7738ccefb )
set(qtmultimedia_REF            3423c7172f948f27ff0512d1d2db4ea97fc0e9c0 )
set(qtremoteobjects_REF         2d0f27e736211e2a6b9d08345f65c736a17a67eb )
set(qtserialport_REF            c7dc6737a2e98af81900f55f814cf79a6d579779 )
set(qtsensors_REF               32dda47f507e74ef7ed33290545b762a0c20e532 )
set(qtserialbus_REF             1ebbf87cbc90c22817785bffc563d4bb86525abc )
set(qtlocation_REF              0 ) # Currently empty port
set(qtwebchannel_REF            e1014dcf9a924d3b8fd3450a3360381a0a8fc6ab )
set(qtwebengine_REF             cc7181c12d1d1605ecab6c448df4a684278d01d8 ) # Additional refs below
set(qtwebsockets_REF            fd509016da201ed63122c5ec79355930f2489ee8 )
set(qtwebview_REF               aade84c30fbbc85fe5a8c5e49172a02a7522623d )
set(qtpositioning_REF           3a68165bc88f9ddd165567d30887147d2d71915b )
### New in Qt 6.2.2
set(qtapplicationmanager_REF    2626ae6e9ce84aebd88a163153719c07d7f65b7d )
set(qtinterfaceframework_REF    71512be8758c75b4b6b0130d6b623f564c6bf227 )

#Submodule stuff:
set(qttools_qlitehtml_REF       4931b7aa30f256c20573d283561aa432fecf8f38)
set(qttools_litehtml_REF        6236113734bb0a28467e5999e86fdd2834be8e01)
set(qttools_litehtml_HASH       38effe92aaebd7113ad3bf3b70c1b3564d6226a766aa968c80ab35fa90ae78d601486226f97d16fa5bd3abf314db19f9f0c90e31de91e87bda82cde27f0a57dc)
set(qtwebengine_chromium_REF    b33b4266df8c333d3d273ae4665d6b322eee33c6)

if(QT_UPDATE_VERSION)
    message(STATUS "Running Qt in automatic version port update mode!")
    set(_VCPKG_INTERNAL_NO_HASH_CHECK 1)
    if("${PORT}" MATCHES "qtbase")
        file(REMOVE "${CMAKE_CURRENT_LIST_DIR}/cmake/qt_new_refs.cmake")
        foreach(_current_qt_port IN LISTS QT_PORTS)
            set(_current_control "${VCPKG_ROOT_DIR}/ports/${_current_qt_port}/vcpkg.json")
            file(READ "${_current_control}" _control_contents)
            string(REGEX REPLACE "\"version(-(string|semver))?\": [^\n]+\n" "\"version\": \"${QT_VERSION}\",\n" _control_contents "${_control_contents}")
            string(REGEX REPLACE "\"port-version\": [^\n]+\n" "" _control_contents "${_control_contents}")
            file(WRITE "${_current_control}" "${_control_contents}")
            #need to run a vcpkg format-manifest --all after update once 
        endforeach()
    endif()
endif()

set(QT_VERSION 6.3.0)

if(PORT MATCHES "qtquickcontrols2")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    message(STATUS "qtquickcontrols2 is integrated in qtdeclarative since Qt 6.2. Please remove your dependency on it!")
    return()
endif()

### Setting up the git tag.
set(QT_FETCH_REF "")
set(QT_GIT_TAG "v${QT_VERSION}-beta1")
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
set(qtbase_REF                  5cfb44d9a8a96ce09b1ea20503f065ca5adc587b)
set(qtshadertools_REF           8f0a3439c411fb1c480222cf6b0739fcdf90eb0e)
set(qtdeclarative_REF           af493d1cf67a5a3873054e011fed39d2457014af)
set(qt5compat_REF               b76f38cbd24285ceeaea170191fe3afd2cdc19ff)
set(qttools_REF                 df3382b03e8427b693f54a3d44b925f1ed9cdb91) # Additional refs ibelow
set(qtcoap_REF                  4d4889d64ffcb39c39318ddbc91c0600c3dedf5f)
set(qtdoc_REF                   121e10f2a686e78262cd913bdd0703acda34c8e9)
set(qtimageformats_REF          d92f4274e3e431156f8b0a82fa16435dd7b02d2c)
set(qtmqtt_REF                  1a63222c03570cdc51324c9cc4f96442a5f9b9fb)
set(qtnetworkauth_REF           f439c695d060c1ef730a7931b3007005768093aa)
set(qtopcua_REF                 a77fe680216895626baaf5bab93ed4a034b4844f)
set(qtquicktimeline_REF         bde5bbd38cf7615522c4897e2a2b23e0725e3498)
set(qtquick3d_REF               38ec66089fb984fc8329112dc57b32903da0a740)
set(qtsvg_REF                   4aa06477ba3e19ea900c46612300fc84c296aac2)
set(qttranslations_REF          df50141ff9a97f6425968318fe43d815478bfdf3)
set(qtwayland_REF               0916f27a379f3fa42effd0418b43d677f948fb5c)
### New in 6.1
set(qtactiveqt_REF              b68f00c55fdf138432a06b9bb3c9c9e3ad386c8b)
set(qtcharts_REF                6b617775c2d4fcdfcf265d2d437247868ed52838)
set(qtdatavis3d_REF             9529580f7d8e008682c4f95a9364820478c84c4d)
set(qtdeviceutilities_REF       5967c11f31883ebddb95621a1173354990a4c07b) #
set(qtlottie_REF                3e7349e31803fa582e0cd64ee71b9a022b9b21d3)
set(qtscxml_REF                 350c8aa3fd4c7bd68f088c92525122acdfadfd06)
set(qtvirtualkeyboard_REF       5acb09923ac3ca46a6dbcd8bfcd37176a1701aec)
### New in 6.2
set(qtconnectivity_REF          39c5992c2776f89050a03f035f61ac200ac830d7)
set(qtmultimedia_REF            e701da4c9b007833eec4e5da0cf3f024b214268f)
set(qtremoteobjects_REF         a90eef1aebaf182a6ee3e44677471c995eee209a)
set(qtserialport_REF            43c206060752bfce16cd94f44a93a0470675c443)
set(qtsensors_REF               12875e2cce679a0bfc966bb2fa4e90b7a5d7393d)
set(qtserialbus_REF             0558c4364763dd6fecda516445dd4bf37b6b84eb)
set(qtlocation_REF              0) # Currently empty port
set(qtwebchannel_REF            ffafaf545cc3488e92001fa98cd0c82c938336bd)
set(qtwebengine_REF             79f27216155e3fb5ea08595821ca7de16e440fbb) # Additional refs below
set(qtwebsockets_REF            3d9cc0b76b705fdb3d6f2e528a507a8f851b3a68)
set(qtwebview_REF               cb4602fe6297f86d8463188fda6b6608ef744f67)
set(qtpositioning_REF           e435f0cb76aeb870899e97cd6458e6212b7d84b3)
### New in Qt 6.2.2
set(qtapplicationmanager_REF    82dad807d7fec38fd046488528d2a4c674005102) #
set(qtinterfaceframework_REF    2e89b77a8c5d0e0887055f7ee76c270048f195f5) #

#Submodule stuff:
set(qttools_qlitehtml_REF       4931b7aa30f256c20573d283561aa432fecf8f38)
set(qttools_litehtml_REF        6236113734bb0a28467e5999e86fdd2834be8e01)
set(qttools_litehtml_HASH       38effe92aaebd7113ad3bf3b70c1b3564d6226a766aa968c80ab35fa90ae78d601486226f97d16fa5bd3abf314db19f9f0c90e31de91e87bda82cde27f0a57dc)
set(qtwebengine_chromium_REF    206bed415635ff7bd6d4486df225cc549e86d35a)

if(QT_UPDATE_VERSION)
    message(STATUS "Running Qt in automatic version port update mode!")
    set(_VCPKG_INTERNAL_NO_HASH_CHECK 1)
    if("${PORT}" MATCHES "qtbase")
        file(REMOVE "${CMAKE_CURRENT_LIST_DIR}/cmake/qt_new_refs.cmake")
        foreach(_current_qt_port IN LISTS QT_PORTS)
            set(_current_control "${VCPKG_ROOT_DIR}/ports/${_current_qt_port}/vcpkg.json")
            file(READ "${_current_control}" _control_contents)
            string(REGEX REPLACE "\"version-(string|semver)\": [^\n]+\n" "\"version-semver\": \"${QT_VERSION}\",\n" _control_contents "${_control_contents}")
            string(REGEX REPLACE "\"port-version\": [^\n]+\n" "" _control_contents "${_control_contents}")
            file(WRITE "${_current_control}" "${_control_contents}")
            #need to run a vcpkg format-manifest --all after update once 
        endforeach()
    endif()
endif()

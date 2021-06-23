set(QT_VERSION v6.2.0-alpha1)
set(QT_GIT_TAG v${QT_VERSION})
set(QT_UPDATE_VERSION TRUE)
set(QT_IS_LATEST 1)
# List of added an removed modules https://doc-snapshots.qt.io/qt6-dev/whatsnew60.html#changes-to-supported-modules
#https://wiki.qt.io/Get_the_Source
#TODO:qtknx?

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
             qtquickcontrols2
             ## New in 6.1
             qtactiveqt
             qtdatavis3d
             #qtdeviceutils
             qtlottie
             qtscxml
             qtvirtualkeyboard
             qtcharts
             ## New in 6.2
             qtconnectivity
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
    )

foreach(_port IN LISTS QT_PORTS)
    set(${_port}_TAG ${QT_GIT_TAG})
endforeach()

set(qtbase_REF             0)
set(qttools_REF            0)
set(qtdeclarative_REF      0)
set(qtsvg_REF              0)
set(qt5compat_REF          0)
set(qtshadertools_REF      0)
set(qtquicktimeline_REF    0)
set(qtquick3d_REF          0)
set(qttranslations_REF     0)
set(qtwayland_REF          0)
set(qtdoc_REF              0)
set(qtimageformats_REF     0)
set(qtmqtt_REF             0)
set(qtquickcontrols2_REF   0)
set(qtnetworkauth_REF      0)
set(qtcoap_REF             0)
set(qtopcua_REF            0)
### New in 6.1
set(qtactiveqt_REF         0)
set(qtdatavis3d_REF        0)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF           0)
set(qtscxml_REF            0)
set(qtvirtualkeyboard_REF  0)
set(qtcharts_REF           0)
### New in 6.2
set(qtconnectivity_REF     0)
set(qtlocation_REF         0)
set(qtmultimedia_REF       0)
set(qtremoteobjects_REF    0)
set(qtsensors_REF          0)
set(qtserialbus_REF        0)
set(qtserialport_REF       0)
set(qtwebchannel_REF       0)
set(qtwebengine_REF        0)
set(qtwebsockets_REF       0)
set(qtwebview_REF          0)


if(QT_UPDATE_VERSION)
    message(STATUS "Running Qt in automatic version port update mode!")
    set(_VCPKG_INTERNAL_NO_HASH_CHECK 1)
    if("${PORT}" MATCHES "qtbase")
        file(REMOVE "${CMAKE_CURRENT_LIST_DIR}/cmake/qt_new_refs.cmake")
        foreach(_current_qt_port IN LISTS QT_PORTS)
            set(_current_control "${VCPKG_ROOT_DIR}/ports/${_current_qt_port}/vcpkg.json")
            file(READ "${_current_control}" _control_contents)
            string(REGEX REPLACE "\"version-(string|semver)\": [^\n]+\n" "\"version-semver\": \"${QT_VERSION}\",\n" _control_contents "${_control_contents}")
            file(WRITE "${_current_control}" "${_control_contents}")
            #need to run a vcpkg format-manifest --all after update once 
        endforeach()
    endif()
endif()

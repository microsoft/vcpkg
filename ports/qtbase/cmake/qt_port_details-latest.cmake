set(QT_VERSION 6.2.0-rc2)

if(PORT MATCHES "qtquickcontrols2")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    message(STATUS "qtquickcontrols2 is integrated in qtdeclarative since Qt 6.2. Please remove your dependency on it!")
    return()
endif()
set(QT_GIT_TAG v${QT_VERSION})

#set(QT_UPDATE_VERSION TRUE)
if(QT_UPDATE_VERSION)
    function(vcpkg_extract_source_archive)
    endfunction()
endif()
set(QT_IS_LATEST 1)

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

set(qtbase_REF             35c7f49e31d8c7ed54348d90dc7fdce8739ee1bf)
set(qtshadertools_REF      cbb485940f3f712d8ac55de0ba7a22e811d75587)
set(qtdeclarative_REF      1aa9d42b39721988d80f94289d3547dbdb616629)
set(qt5compat_REF          f6d731aa49141d962ba3db807e2de6059d20aec1)
set(qttools_REF            37b2ab5d60122f727767519f016e62bfbd4f3c63) # Additional refs in portfile due to submodule
set(qtcoap_REF             636dbea8d9eea8187d14b441c0fa6d42b70472f1)
set(qtdoc_REF              a88c29534185b477e189ac98cbbc7a44eadecac6)
set(qtimageformats_REF     e624c970c92148b472a5dc49fc03eeb698c0ed52)
set(qtmqtt_REF             e396a8ed9c307e73e150abf8c57d9d58a52f25e1)
set(qtnetworkauth_REF      911308010b34ccfbfceb40fbd1df285a7a996ce4)
set(qtopcua_REF            b1cd3c3a98dfa72ae853bb2b366320e15051c8fb)
set(qtquicktimeline_REF    213fb1b11fb6170424dfa83a52b334a7e9755797)
set(qtquick3d_REF          bbbd4c6819577579d578e54efe58f0491076a1da)
set(qtsvg_REF              e1ae6b6f2d1038697b80e81c216547e411921e8f)
set(qttranslations_REF     e111f448425499d71de7ab4357c815d01df0e7b9)
set(qtwayland_REF          6bf7a343d97283994b8c1fdfa71ebea7ac0acff7)
# set(qtquickcontrols2_REF   0) # Moved into qtdeclarative since Qt 6.2
### New in 6.1
set(qtactiveqt_REF         e734aecf0048ae7b13d3d1a00e599bde7cbfddc7)
set(qtcharts_REF           35a594dd0e655c7cc55db5b3c54d16755589f525)
set(qtdatavis3d_REF        ad299e89d9fdb651810b86e85f0c2996d314f737)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF           b062a9d30f497d6a21f43babf51fa2793e30dbe2)
set(qtscxml_REF            6a313a67a73af0d438e3af133fe6e3a779160688)
set(qtvirtualkeyboard_REF  ea5f1c56dc23c965c47ed5aca035acb3b49a0baa)
### New in 6.2
set(qtconnectivity_REF     deab208ca74f6b3700ced1bd53692e08d32b355d)
set(qtlocation_REF         d1278fed203bef17d5572865354029c98bd1461c)
set(qtmultimedia_REF       fc27b1e93ab6121c9c48441a2422e80590e344fd)
set(qtremoteobjects_REF    fab80405616c3c9d62ef3c8636f2202eb8a8fbbe)
set(qtsensors_REF          000f469124cf37c70ba1dc5e66d3c80ee316487b)
set(qtserialbus_REF        f51a4e7d2b03434235d2c6be2f2f79cb2f7ed9d8)
set(qtserialport_REF       3f757ad63981fea23edf3537f9da63a7f0848970)
set(qtwebchannel_REF       87dfae5be09d0491a95b68678461f86ba169a100)
set(qtwebengine_REF        781e9060f38d91041e1408fdebd407b3a9b9ee1b) # Additional refs in portfile due to submodule
set(qtwebsockets_REF       3e460b7ecb8e28fbe499486e7a5471b1719f4b69)
set(qtwebview_REF          1da82e4d39356ae9365cabdb6098429ef1afb294)

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

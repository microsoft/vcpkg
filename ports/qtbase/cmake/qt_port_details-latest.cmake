set(QT_VERSION 6.2.0-beta4)

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

set(qtbase_REF             4b25d23b1ed9e5cbb6a5ee921280a6f1fac72c96)
set(qtshadertools_REF      d3f9dc3b3f805ace0c9384676120d0fb87d1a164)
set(qtdeclarative_REF      95f90346ff374bd88f913baa73f2854a1054b7ff)
set(qt5compat_REF          a43bb50a4155e651e31888e84063dd280fb83976)
set(qttools_REF            d589b7a7c9a907e37516b7694ef5f716dbaf287b) # Additional refs in portfile due to submodule
set(qtsvg_REF              554292199c2fd327af5e21038589262518b94ec7)
set(qtquicktimeline_REF    9ad86f82d5ac872b0faa0e0a29c55ba1b8f40237)
set(qtquick3d_REF          0d953fba1a7f7a5176c3fc7ee46525333e860870)
set(qttranslations_REF     8857ab35c102944b9d37ae2a5463e50bc148639d)
set(qtwayland_REF          527874ea095a2c5a2d4aa207b2860d116009ff75)
set(qtdoc_REF              0baf066a924142cf944bb116ef3b9acbdaa7c19c)
set(qtimageformats_REF     483584123f1ee04b9df64de9877923444f7f4b31)
set(qtmqtt_REF             f5d9a96b37ce0998ef5897606c28cc0ce706d896)
# set(qtquickcontrols2_REF   0) # Moved into qtdeclarative since Qt 6.2
set(qtnetworkauth_REF      71dc1ba6d4ac1424ec43465ce8f4e0fa2f83305d)
set(qtcoap_REF             00b300434e91af445961b619d587709ebbbda5ea)
set(qtopcua_REF            6925bf5e7faefba261164c07094ec4a8f4680c9a)
### New in 6.1
set(qtactiveqt_REF         6b7daa59f951343c88daa1f923d60e26006467c7)
set(qtdatavis3d_REF        a400e5232e9b03a90949c2ce14c2446fd5d86512)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF           505bbdb2909e5c96688b88169f3cbb4b2aae9854)
set(qtscxml_REF            5ee3a92ddfeb49f92f38f1d21457ce1929a65f2b)
set(qtvirtualkeyboard_REF  a96a8eec64ade5609365337935a7e2e1a94e7670)
set(qtcharts_REF           5b1b4f1692ace73c86ca1e7532446fa423525f8b)
### New in 6.2
set(qtconnectivity_REF     e40adbaac03e19a6e82c6c7a3184710d8171ea8d)
set(qtlocation_REF         4e19386e7e2e43a6314af1c371df548dc061a7b1)
set(qtmultimedia_REF       8a111c2c2e67c76e9861815d514045e4177d55a9)
set(qtremoteobjects_REF    d17423968363d08681c741181bafb7f16163add1)
set(qtsensors_REF          61921f06bd99f2c1184ba0d8f13518b07d8b7b7b)
set(qtserialbus_REF        672e3bac1b87b77bd896f55c7ce238ac34ae5ac6)
set(qtserialport_REF       31de97226c90f2365f3632a49c332580f8c08647)
set(qtwebchannel_REF       7534991cf0cfd51c70d00e5d110c80415c2e9291)
set(qtwebengine_REF        8f6afad6309af431f609892fc0d9252429288bcf) # Additional refs in portfile due to submodule
set(qtwebsockets_REF       930d41b8ae4235dc658997667edabbfc0ddfe04b)
set(qtwebview_REF          10be72b20f78181bd227bc420a562cbdaa2e606b)


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

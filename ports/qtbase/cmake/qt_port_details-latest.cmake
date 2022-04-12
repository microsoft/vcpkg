set(QT_VERSION 6.3.0)

if(PORT MATCHES "qtquickcontrols2")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    message(STATUS "qtquickcontrols2 is integrated in qtdeclarative since Qt 6.2. Please remove your dependency on it!")
    return()
endif()

### Setting up the git tag.
set(QT_FETCH_REF "")
set(QT_GIT_TAG "v${QT_VERSION}")
if(PORT MATCHES "qtdeviceutilities")
    set(QT_FETCH_REF FETCH_REF "6.3.0")
    set(QT_GIT_TAG "6.3.0")
endif()
if(PORT MATCHES "qtlocation")
    set(QT_FETCH_REF FETCH_REF "${QT_VERSION}")
    set(QT_GIT_TAG "${QT_VERSION}")
endif()

set(QT_IS_LATEST TRUE)
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
set(qtbase_REF                  0668a36d2804b300010d874f5ff4073c25c2784c)
set(qtshadertools_REF           e526e8ca88197d82996818db1f00e8a3e07bf584)
set(qtdeclarative_REF           cbe89ee41aa219ce7e90143e3cf54283e580f7c1)
set(qt5compat_REF               32db676ab6854633512181b2c40950c98525c5ba)
set(qttools_REF                 a0a9cf1d1338b3e7f868bc0840e1e9a096c86dfa) # Additional refs below
set(qtcoap_REF                  4453575b94836cf1cd52642eceb1d6f5d16b26a9)
set(qtdoc_REF                   d0da4d47f152dc50fb672bc5011b61a5bbb36f43)
set(qtimageformats_REF          45cfb044698df541ced53e3523799232599712a6)
set(qtmqtt_REF                  3174dc30d2b37c74ea685d27ab0030c7392032c0)
set(qtnetworkauth_REF           507214965cbcebbbd563904d615cf7ebc464cc48)
set(qtopcua_REF                 2c7051d85f640e9afe6c3f8f718bb2152305467c)
set(qtquicktimeline_REF         16bc2eb9f5e84923dc04c3941f5347cbc1b0e5b0)
set(qtquick3d_REF               bf912a678898dcde61f139f63b49e1e42717fa8d)
set(qtsvg_REF                   cf900932886ebdd3de6c3a4a7e63cf363663eb87)
set(qttranslations_REF          19701f38b9dc10d925c6974833d693b5038e1589)
set(qtwayland_REF               840673bf1849595869873bad15c52a312e849ffb)
### New in 6.1
set(qtactiveqt_REF              747fdd27c413ea42fb730230331984f388d3826b)
set(qtcharts_REF                03929b43d8e2a5c9b1487fdc6b8a2b067ada16f8)
set(qtdatavis3d_REF             137ebda0932e6faf0fbd61b0beb3cfb4dac8efbd)
set(qtdeviceutilities_REF       0520d7fd121f7773d04a7d3318553ff7fed1b3a9) #
set(qtlottie_REF                e68bf89fefd941a930c83e2c29b629fcfea03eb3)
set(qtscxml_REF                 4f52a1b6e4f25f3473f42ce249c4c183c5910183)
set(qtvirtualkeyboard_REF       92aee38dab196e8b5ca436f9f20c0fc66d8155d5)
### New in 6.2
set(qtconnectivity_REF          f62954bad729f7853c9fbe2ea0b3235cfae2701a)
set(qtmultimedia_REF            3d2dafab1eb60c17a30cf03213cd2f6f71185137)
set(qtremoteobjects_REF         2c53bf0e9262a24f8fc8553e5004e7d00bc7e556)
set(qtserialport_REF            7e44935b14b783add342a25f426fcdf299279024)
set(qtsensors_REF               3222894c246076c6e7bd151e638ce3eb4ce5c16b)
set(qtserialbus_REF             3ee1694d2a8fb0b755adce4b59001b784e9c301e)
set(qtlocation_REF              0) # Currently empty port
set(qtwebchannel_REF            a85e05069a2b17ceb5b6332671a2eef261ec783f)
set(qtwebengine_REF             9158e7652f24800b2b7dbe59b7834687bc1baf13) # Additional refs below
set(qtwebsockets_REF            487116c9a85d8f5a920f47045dfce0b0defd5139)
set(qtwebview_REF               d7498a108c67b21c39d8ba775330cc122ce21c1a)
set(qtpositioning_REF           f61d2f336892b85cdcd5d508bb4a0db7f768d439)
### New in Qt 6.2.2
set(qtapplicationmanager_REF    68464eb2b3fa89c69cfc5fc4f19450af61116dd2) #
set(qtinterfaceframework_REF    7ddeb99d6215a4b63102d6a5bc73e50d77ddb3d7) #

#Submodule stuff:
set(qttools_qlitehtml_REF       4931b7aa30f256c20573d283561aa432fecf8f38)
set(qttools_litehtml_REF        6236113734bb0a28467e5999e86fdd2834be8e01)
set(qttools_litehtml_HASH       38effe92aaebd7113ad3bf3b70c1b3564d6226a766aa968c80ab35fa90ae78d601486226f97d16fa5bd3abf314db19f9f0c90e31de91e87bda82cde27f0a57dc)
set(qtwebengine_chromium_REF    2c9916de251f15369fa0f0c6bd3f45f5cf1a6f06)

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

set(QT_VERSION 6.2.2)

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
set(qtbase_REF                  61fbf7596beda0178e213a7ba945bc0314153366)
set(qtshadertools_REF           3ce1b25b413aef98a68c0b05305a6849bb558889)
set(qtdeclarative_REF           f4cbbe999d912b2c66fffc8b7bf11b59fd92a178)
set(qt5compat_REF               e38a2b4653780317feed0d0f7c0adb2964ed674c)
set(qttools_REF                 f779b0439e3984f592320c0e5b3ba52f3627c07b) # Additional refs in portfile due to submodule
set(qtcoap_REF                  fe7ea10937ece3b19fc7d909790e1bfec23c363f)
set(qtdoc_REF                   aeb34a71d6f93b3ddb438e52c3f4d963e8c51ab9)
set(qtimageformats_REF          02a3365745ceb3cdcc27b2dd6f80300f5c03f6f4)
set(qtmqtt_REF                  deff6a3853c9a09e18fa05ae9aa6c5868ba2d1b7)
set(qtnetworkauth_REF           470a295fcb61e37640e00c75be1870a3b1cb227e)
set(qtopcua_REF                 b8e9b695c71d73e21ac489136fca1c2991ebea78)
set(qtquicktimeline_REF         7c74c9025c8c5f390f5a19ec9bd1d0d4fc36cee2)
set(qtquick3d_REF               8a06b1c9e69c2b83fff313bab4cdc463b6c55b8c)
set(qtsvg_REF                   414fe3bc0f77704c9184ee1039ffea82de8b6c0b)
set(qttranslations_REF          a8b48341570242a700fd61abf16ef106b4b4d8b2)
set(qtwayland_REF               b6d7b9d5dea396b1454b4e204f37a66e3da39150)
### New in 6.1
set(qtactiveqt_REF              9d373846d2f0073f530b1e714afeb76cf039df94)
set(qtcharts_REF                b74fa4205af2f6be69ec1a233aaee28f1eb6b838)
set(qtdatavis3d_REF             e5ee7c79d3e6845267691c0074ae3aa286cbe904)
set(qtdeviceutilities_REF       df77ef89d3b1cbeda9996702e0a26a9a58c9f467) #missing tag
set(qtlottie_REF                6c16cfae5f39bf1047f73ae99bbe7d99c79f5179)
set(qtscxml_REF                 6dd18cdf4d24d159f7114b8b31a81d95a24f3ca2)
set(qtvirtualkeyboard_REF       7473762116f3c0bdfc5d8e4d55137013ea082eaf)
### New in 6.2
set(qtconnectivity_REF          a723287f639e81a3253f6c0923475da5294a3342)
set(qtserialport_REF            6a92ae54a27d6fc40e5f44332a7d7d49999a8643)
set(qtmultimedia_REF            6a55ffc411f6ea73d45a7109d54c5cca1a482930)
set(qtremoteobjects_REF         cc1fd1722180b8a46994c7c751ea4b3b7ab30c58)
set(qtsensors_REF               ba5da0a367fa2f11b577ba226bea488eda7dd499)
set(qtserialbus_REF             125631af95d958d55b7b0789dfe64e0d1f7d0122)
set(qtlocation_REF              6db775f6d9d72cf8ee9d66333b8424e74be1e352)
set(qtwebchannel_REF            e55fa2e085466238e24d53abf4fc9ede7a7590e4)
set(qtwebengine_REF             ad19d22d3aa5d692b4988f2ffb88868232e6fc0c) # Additional refs in portfile due to submodule
set(qtwebsockets_REF            18c452968b3c3ad6c1e1b6512ebd96e9f895c571)
set(qtwebview_REF               eb5a94f20e77a9639b07ae3d59c9d67529ffed66)
set(qtpositioning_REF           1294c29be50fa5cdf2d78afffac0451f7b4bc16a)
### New in Qt 6.2.2
set(qtapplicationmanager_REF    1009f73d1f5c07947cdc2318150279ad43fc4b04)
set(qtinterfaceframework_REF    118fa138186144cf2d802405255f08662ed76d43)


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

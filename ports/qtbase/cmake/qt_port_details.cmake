set(QT_VERSION 6.2.3)

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
set(qtbase_REF                  0145fe008894c3b280649b02725e6ec5a5605006)
set(qtshadertools_REF           a82d73829028a31640e317a2c8ce365ef74281a1)
set(qtdeclarative_REF           809f24b274ebfeb537c44f38445a4327d43da5e0)
set(qt5compat_REF               ca0c27fb51622058e50150ab906260fb7ed11ae3)
set(qttools_REF                 fb3a3731946c70d573daaab232e13ed8f283fcef) # Additional refs ibelow
set(qtcoap_REF                  7b4a337efc71426c84abab3b1d4bdad659ae1c63)
set(qtdoc_REF                   1d8092320fedfa368e486eeeea43efec45460672)
set(qtimageformats_REF          1a8e25eb8a63968e09b944cebee5882c137b0c32)
set(qtmqtt_REF                  b1cfdd8b121c3d0554814c271096e3448da032bb)
set(qtnetworkauth_REF           8451dff3c65712b037ef0606c1f25d70152623f0)
set(qtopcua_REF                 42a61efa01a255ab94eddd06321f1afd88653d26)
set(qtquicktimeline_REF         964efe364a37ef20da42d0a207022fe4b9414fe1)
set(qtquick3d_REF               8f4a5d3bedb548def24f2192d23a724dd05ed5a6)
set(qtsvg_REF                   6c682d8f996ef5d6c8241f8550cab03cac49f440)
set(qttranslations_REF          4a1ae5b85d64411217438705da21462c5c7f9034)
set(qtwayland_REF               2bc79b7e60af737ceb3329cae076804ab84ea4d4)
### New in 6.1
set(qtactiveqt_REF              8900aaf9bd44c265544b6346ab951ac8b4fa2cb3)
set(qtcharts_REF                690c97c1c0628985014c49ed69f5e9b05da3d775)
set(qtdatavis3d_REF             6e8983a92203194f5047002340ecf522e83187d1)
set(qtdeviceutilities_REF       643e82571dad2c96616d851508393a27b7ca788b)
set(qtlottie_REF                1509364fe51f432a5367d19a1a3f13566fa5e70f)
set(qtscxml_REF                 98f98f87437369f6a3ed4f9f8668d0a29964372a)
set(qtvirtualkeyboard_REF       06ea4e113221c26ee5ed2edad6cffa63cde30978)
### New in 6.2
set(qtconnectivity_REF          ddfa5de7af5d674ac1d0e9d18e37f70ae1ccd453)
set(qtmultimedia_REF            03c6a61266543c7634915de65cdb7752a25df6f4)
set(qtremoteobjects_REF         715bc1f6bc551aedbaddca3f44f3a5cee8710936)
set(qtserialport_REF            b7f42ccd13cf0e736b65eebb7537e31584af6930)
set(qtsensors_REF               e53e83d9beffc6a3ef465e91033f2b62fc8102fa)
set(qtserialbus_REF             edefe743658051c6c406d3d7645031f2ac281fc0)
set(qtlocation_REF              0) # Currently empty port
set(qtwebchannel_REF            adbb4c38c5af970f46000f61501ceee714364a46)
set(qtwebengine_REF             855304132f321f285986c7f1710a45bae72aec12) # Additional refs below
set(qtwebsockets_REF            84e8557281b242d3023b2cff86366343ac440fee)
set(qtwebview_REF               4c27976cd3817914a927f66153b123fd593a9fcf)
set(qtpositioning_REF           2702073aec1d87bb150bf27e8b28f0351710aaa6)
### New in Qt 6.2.2
set(qtapplicationmanager_REF    bcdd87312d8f959a8b928d9e1bc5f614fea9e4b3)
set(qtinterfaceframework_REF    e0ebb6fd68e5c585ad55da8c4ca768ade6b82617)

#Submodule stuff:
set(qttools_qlitehtml_REF       4931b7aa30f256c20573d283561aa432fecf8f38)
set(qttools_litehtml_REF        6236113734bb0a28467e5999e86fdd2834be8e01)
set(qttools_litehtml_HASH       38effe92aaebd7113ad3bf3b70c1b3564d6226a766aa968c80ab35fa90ae78d601486226f97d16fa5bd3abf314db19f9f0c90e31de91e87bda82cde27f0a57dc)
set(qtwebengine_chromium_REF    30c22c6ed9833c7e6e14a345752c6f13cfbaec51)

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

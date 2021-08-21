set(QT_VERSION 6.2.0-beta3)
if(PORT MATCHES "qtquickcontrols2")
    set(QT_VERSION 6.2.0-beta2)
endif()
set(QT_GIT_TAG v${QT_VERSION})

#set(QT_UPDATE_VERSION TRUE)
if(QT_UPDATE_VERSION)
    function(vcpkg_extract_source_archive)
    endfunction()
endif()
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

set(qtbase_REF             a3d8d79fbdb776f8848cba2d721ee89c28cf2e50)
set(qttools_REF            6ec6f55bba2f3b86e71a0b63113ba4c036539eee)
set(qtdeclarative_REF      9c856186498a0e34f0179bd03b7972e57a76775d)
set(qtsvg_REF              5a93bf0d0781eeb04fec1635ed5051fcf750214b)
set(qt5compat_REF          920ae1ef2ffbbedb19e3e419056ac3a461f0a632)
set(qtshadertools_REF      49ccc41b8a55de07ba5fe033e19a706274f10fff)
set(qtquicktimeline_REF    62e4533c91a9e829af63913d11c08fae7b974b36)
set(qtquick3d_REF          2301f81eedd7a9156f4e48f993a62eaed77eae9b)
set(qttranslations_REF     15fc73facf33171a143441612906514e437fd52f)
set(qtwayland_REF          e5a80e612960eb221b95bf69d2c79355a3e62389)
set(qtdoc_REF              71642a96f5dc93c423471480adbdbfc672752017)
set(qtimageformats_REF     e1e54e9432bc8cee544323b843f2693298532e6d)
set(qtmqtt_REF             e4ad030f694892130b1b44ca86b97f3be139a176)
set(qtquickcontrols2_REF   a71fa9356119b0d56db3ae61ee52772f6f6016f0)
set(qtnetworkauth_REF      7f77f8a28de9bd45854b2e49b8438579ec489da0)
set(qtcoap_REF             3ec6ce75d29964a74606813f2b9a5be22c2877be)
set(qtopcua_REF            b440ac640b698b84b232e4e2f7c7722561342797)
### New in 6.1
set(qtactiveqt_REF         850ef726ddff3b344409a032cac605d1b3a02837)
set(qtdatavis3d_REF        3e628a64ec2e8de7979a2a0265b4792fdc97a5d0)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF           fafcc1bbcf624a89f15537930af3dd2c8ac1fa5e)
set(qtscxml_REF            d8afa42031e678119b5731c9c8c5906452de22df)
set(qtvirtualkeyboard_REF  a863b7e1ff1a6dd6fd6f55a53b80f0f83c593ccd)
set(qtcharts_REF           da2bae114d7cac011965523767d9916749b03f25)
### New in 6.2
set(qtconnectivity_REF     65efa5cc25bf2b295e24b9a3dc88cb10bf0ea06c)
set(qtlocation_REF         43de24f22407e1d224de400dbd92d387b907a4c1)
set(qtmultimedia_REF       f32a7fe94a589f993b7ab8a90234e7dcf719fc8c)
set(qtremoteobjects_REF    beb76d94b5c3f943fdb62fb2cf8e975f3facad5d)
set(qtsensors_REF          2e48ce07157a834f1b533b0a60366f67e5a8dcac)
set(qtserialbus_REF        3f90fafb7808a8b55283ce3fe26b3fdb26d6b45e)
set(qtserialport_REF       d036b5c27d8515bd1972658482371396935c1a01)
set(qtwebchannel_REF       2136d70c3b451c8f105a41d0679b1fd7e3bf1632)
set(qtwebengine_REF        99f769f85aa6dc1197e28ee7b95c86182819241f)
set(qtwebsockets_REF       a4d5deb0935c7a97e4156d84b08f65793f3ddc75)
set(qtwebview_REF          693b6dda0b858bff1f2aa7ae2cf37c4511207a75)


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

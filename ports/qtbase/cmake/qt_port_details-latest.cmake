set(QT_VERSION 6.2.0-alpha1)
set(QT_GIT_TAG v${QT_VERSION})
#set(QT_UPDATE_VERSION TRUE)
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

set(qtbase_REF             f08faf62f891b51c520d98bd0dfa510042b87137)
set(qttools_REF            5efaa3d0d506f071e5d7c9ece8f8aa1cdb500f66)
set(qtdeclarative_REF      f2ac0ab20aef497769c8ec3f332d72fc4dfcf78a)
set(qtsvg_REF              09ac29abd4047ac85a4706eb5c859f4684444bfa)
set(qt5compat_REF          1cc6c77a0229c393e7f528d833d78023c366908a)
set(qtshadertools_REF      fa05da15b373318b5f125338c0730ec1340871b3)
set(qtquicktimeline_REF    af7533f6f70dbfb0c69e9ae56586b43976741bc4)
set(qtquick3d_REF          f217178f3185d62494ca339f8b1aa49c474e5c8d)
set(qttranslations_REF     84457dcee1c8b38a0228cf7c3bd0b40d843fa6fa)
set(qtwayland_REF          8aafadac1da898a319b84c512f3237847ba344b3)
set(qtdoc_REF              239a83e500a03501e8f385032a32e3aee7e208c4)
set(qtimageformats_REF     0e7367598315b0e4f1b82f0cd6bfe88f4af772b6)
set(qtmqtt_REF             59c3eaf808411081b0d1f3639805589416b54c89)
set(qtquickcontrols2_REF   4f637be85dc32837911f92d762d268a9f59554e2)
set(qtnetworkauth_REF      d1e611d11730c0f782c6885ace9ebf7be344a6c5)
set(qtcoap_REF             07d346b51745895b6a4b978cf4fad946c2477c63)
set(qtopcua_REF            3f013ccb1a0d2f513ec3c585c9f7accc78c10a30)
### New in 6.1
set(qtactiveqt_REF         037e2225909cae2141e94347ae07c92a4b6393b6)
set(qtdatavis3d_REF        a085d2b28101f29d3de33ebdedfc5ead5ad94517)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF           689f655517458cd3a3dfd697be7aa1811cfab3ab)
set(qtscxml_REF            da238a5a44d1b2fb07de076bbcc62e4d2cc2019e)
set(qtvirtualkeyboard_REF  36337543155bae38873ea078d9589a86d83a71e4)
set(qtcharts_REF           0cce15676e89dd8d926dc42c7c6ca0b6eace4a4f)
### New in 6.2
set(qtconnectivity_REF     959e117d6b4cd5dd4c738b1167827fa5fdc478fc)
set(qtlocation_REF         5b720d39e8fe935267b5467444cb146419f7fe90)
set(qtmultimedia_REF       111e65bb6dd733b32edabca6a021e14e19e61b35)
set(qtremoteobjects_REF    2432814f96ab366b5821e44b6fb263116482c3c1)
set(qtsensors_REF          ff3646d5447b1dd53567f0ffa505bbe611296e7b)
set(qtserialbus_REF        46735dada76c0013fd289538213685e801f188b9)
set(qtserialport_REF       1d85b184163dd111eaf30e39bf089d234b37d055)
set(qtwebchannel_REF       67539fb60d2ac3d1508ef4589409e93f6d64d579)
set(qtwebengine_REF        664b7c6a729390944d82cad5ca38a87a9db587d8)
set(qtwebsockets_REF       4236ff199423a8b79bab5af38eb388f8ebede9d1)
set(qtwebview_REF          1d7974649e7e4c45a086503ca6a611e4c543c844)


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

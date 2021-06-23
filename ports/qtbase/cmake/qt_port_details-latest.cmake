set(QT_VERSION 6.2.0-beta1)
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

set(qtbase_REF             db6601ecee32393f043d4a7ac8df510b89a92fdc)
set(qttools_REF            4ed479fea90c4a3386b3288db2c94479897a3417)
set(qtdeclarative_REF      4201519440cfcf59ed97cf4acf55b15f9aa12bc9)
set(qtsvg_REF              b727a95e118aa3a24f71aa069c346096e77de2d2)
set(qt5compat_REF          611f1a0ed54c3a1a02a59b703e17e57e6ff2eee6)
set(qtshadertools_REF      974c9d49be3e7264685187c88ba79b2c7796aac6)
set(qtquicktimeline_REF    9ee8244364fcdf977ba8fe9eb10b5d447f19498d)
set(qtquick3d_REF          caf9bb977273b574cbd731a5f6721b835a4e6838)
set(qttranslations_REF     efd0999ef29a809b27c781f5667660eacfd1e82c)
set(qtwayland_REF          b6006c5125c48be1b4e0fdc389b38625a531a250)
set(qtdoc_REF              2fad4d1940d2ca436c351e54ab80107207500b58)
set(qtimageformats_REF     4777a3fff4a28b8975d4875c9698fb4102839942)
set(qtmqtt_REF             16ad9203c8f9499926b683ef7aa29020dc441ec9)
set(qtquickcontrols2_REF   3c7d611cdcd3cacae402289668c52701bb6bce1f)
set(qtnetworkauth_REF      087a1aa286603acc4835591c8f9c1c81ce1f54ce)
set(qtcoap_REF             0366aaa1df8f2640ec5c56255468a48aefc2e4df)
set(qtopcua_REF            f6262aa31fe9f96fe7a5d017ebc74789b0b33f51)
### New in 6.1
set(qtactiveqt_REF         626fc3ae33786c28f0f2e345b0255d20dc5098d8)
set(qtdatavis3d_REF        2b97ad4a2fd0eaafec0996bb9f2f908253b0c810)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF           64098c343774e46b38c2378cc6911786e5c59f58)
set(qtscxml_REF            a9453716d09e5639ad89d58dc178ee95ea89d9ca)
set(qtvirtualkeyboard_REF  346c983867e31062d2ea83e722b68bb5da729591)
set(qtcharts_REF           12a7de0e83349ffad48bad0eb80911f6654f5624)
### New in 6.2
set(qtconnectivity_REF     e94e967d655b2b04c9b4537e0c846864bda75af6)
set(qtlocation_REF         b7af61badbc22ee33e25030555da785eb99698ce)
set(qtmultimedia_REF       e5534ef1ce3cc88f9e226097315e170827eecc8a)
set(qtremoteobjects_REF    bb2e6ad477cb0af9416f2bf75a14928b183df061)
set(qtsensors_REF          7ac62a70edb085e52f5288ee7d69ca4e03fc2db7)
set(qtserialbus_REF        b5eefabf1c1321eec7709eaf754291aa512a712a)
set(qtserialport_REF       b486aabb43068c40772f42d725c3d46c2212286d)
set(qtwebchannel_REF       8cb9861fea426925a115854e0e41e25ba9401fd6)
set(qtwebengine_REF        ad087b74bc7daaa56ec781f0eee82de9899ebd16)
set(qtwebsockets_REF       831964b54572cc21b167934887ceac57d9e3cc7c)
set(qtwebview_REF          bc4c1875cfa50f77e1a3b1057457f04ddc654796)


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

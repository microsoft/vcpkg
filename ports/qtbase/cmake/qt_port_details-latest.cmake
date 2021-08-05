set(QT_VERSION 6.1.0-beta3)
set(QT_GIT_TAG v${QT_VERSION})
#set(QT_UPDATE_VERSION TRUE)
set(QT_IS_LATEST 1)
# List of added an removed modules https://doc-snapshots.qt.io/qt6-dev/whatsnew60.html#changes-to-supported-modules
#https://wiki.qt.io/Get_the_Source
#TODO:qtknx?

set(QT_PORTS qtbase 
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
             ###
             qtactiveqt
             qtdatavis3d
             #qtdeviceutils
             qtlottie
             qtscxml
             qtvirtualkeyboard
             qtcharts
    )
# New: qtactiveqt qtdatavis3d qtlottie qtscxml qtvirtualkeyboard qtcharts

foreach(_port IN LISTS QT_PORTS)
    set(${_port}_TAG ${QT_GIT_TAG})
endforeach()

set(qtbase_REF             089b73de033190e511c0bd11cba22160024ef9a4)
set(qttools_REF            a810532b7f68348281bac13fc03395bf08827c28)
set(qtdeclarative_REF      1e4730ae0f44ece8ff8a27d4de127d8da9ed8a13)
set(qtsvg_REF              1adf841f16cab093f7db6a1fbffd088b138afed3)
set(qt5compat_REF          6ab304e8d2fe7f58cf608f8a30abbf769680f027)
set(qtshadertools_REF      c26caefc6f67f01ae52372a70d3887077477388d)
set(qtquicktimeline_REF    a91e82010047c9422d573b4c8648c175b470839e)
set(qtquick3d_REF          f6614a31bd8a092d2081092dc7043ead9e7475ea)
set(qttranslations_REF     8a39fca4b56817fa2f7393fd5c5850bb167ac8f3)
set(qtwayland_REF          8237b7384537e3bc1687c1e05a20d450a6ed38f3)
set(qtdoc_REF              9259552281e4322a63f2cd0edce7904af1147bca)
set(qtimageformats_REF     acd9ad1f69606553bc975fb33ae4efd52b2fbe9f)
set(qtmqtt_REF             3bdd419302de7e1e8a819509d115c32d2fbf4d49)
set(qtquickcontrols2_REF   a74819563efc3495a86a696e678bec11bab33ec6)
set(qtnetworkauth_REF      92a1ff5b63f56e77030cdfbe9c456a31d3a2d5e2)
set(qtcoap_REF             bc8f5ff0e678aa4b4c9081e543fd7c119754a3a1)
set(qtopcua_REF            0cd72d5e9cfaaf96b6d9a2d4ce4a6c46ffbbcdd4)
###
set(qtactiveqt_REF         94a100baa75248ba49c01680ca3632cd7180a8e8)
set(qtdatavis3d_REF        c1e7a47f47cc289652f2004403cb1e587308c290)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF           ddda33a7294512487035de6338a91657501c9fd2)
set(qtscxml_REF            8e2ad5c798110337b90c582c68e903465e19e3fe)
set(qtvirtualkeyboard_REF  266626a0414aef2fcc65d412f02c993c87a1cae6)
set(qtcharts_REF           962a05cea44108d13f081a12bd53232ef856427c)

if(QT_UPDATE_VERSION)
    message(STATUS "Running Qt in automatic version port update mode!")
    set(_VCPKG_INTERNAL_NO_HASH_CHECK 1)
    if("${PORT}" MATCHES "qtbase")
        file(REMOVE "${CMAKE_CURRENT_LIST_DIR}/cmake/qt_new_refs.cmake")
        foreach(_current_qt_port IN LISTS QT_PORTS)
            set(_current_control "${VCPKG_ROOT_DIR}/ports/${_current_qt_port}/vcpkg.json")
            file(READ "${_current_control}" _control_contents)
            string(REGEX REPLACE "\"version-string\": [^\n]+\n" "\"version-string\": \"${QT_VERSION}\",\n" _control_contents "${_control_contents}")
            file(WRITE "${_current_control}" "${_control_contents}")
            #need to run a vcpkg format-manifest --all after update once 
        endforeach()
    endif()
endif()

set(QT_VERSION 6.1.2)
set(QT_GIT_TAG v${QT_VERSION})
#set(QT_UPDATE_VERSION TRUE)

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
             qtactiveqt
             qtdatavis3d
             #qtdeviceutils
             qtlottie
             qtscxml
             qtvirtualkeyboard
             qtcharts
             qt
    )

foreach(_port IN LISTS QT_PORTS)
    set(${_port}_TAG ${QT_GIT_TAG})
endforeach()

set(qtbase_REF             c7c05ab0610ca521a7fcbfdd8d063358d62531b0)
set(qttools_REF            304bae0d5acdee4313405c25dcd259db92dff23d)
set(qtdeclarative_REF      bfe2822fb615fb9264c19cebc07994c7a719d159)
set(qtsvg_REF              e4950cbb5810fb9e0fd1c42ba888e6d77c21d4b6)
set(qt5compat_REF          ff070674ce05e580f023634d5c0fb33c27bb95fd)
set(qtshadertools_REF      2e4aae72dad87eb6d32aa505d6fdcc51b7be057a)
set(qtquicktimeline_REF    72f2f03964068d7a66f878949e739fa933d12246)
set(qtquick3d_REF          261ad084def2fb0147a9def96a55d9ca2c469268)
set(qttranslations_REF     caa1100446f659ab992585aecd647612df1d0755)
set(qtwayland_REF          549e6892a0932b76ff7f4004057644980445df36)
set(qtdoc_REF              5a1cc893a66e84155924a94d538ab9401aa02976)
set(qtimageformats_REF     99a0ff33dc46582235363f5ca64a01ce3c1b9fe3)
set(qtmqtt_REF             cef4c58c9b60248ab4fb0ae60815efb906a20f2a)
set(qtquickcontrols2_REF   2d2e99d44337867585fa0dba8de5bd7ecd7ad6e7)
set(qtnetworkauth_REF      b3e45d0dad36a0ec402bb6e3e85459546378ed22)
set(qtcoap_REF             aa40b3cd7d699c926c8527fe7708436cc47eeced)
set(qtopcua_REF            615ea73989fa5b2a7f560a292d3054af5d0663ed)
set(qtactiveqt_REF         020d8da4e22be449846eefcfaa805cd8309cac20)
set(qtdatavis3d_REF        a4ea8afeba164d2dc8229e693c541d364e99f3de)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF           35e46e52d8849caf84269f92701a5b342824582c)
set(qtscxml_REF            d92013adb0a4ad0a80e94a265ec13b5c1730ee05)
set(qtvirtualkeyboard_REF  4e71c9ae1ef8bfe1d9193cd14d11a4e1cf9ea7bc)
set(qtcharts_REF           68a5725a5c97adad88a9d7a6318b06547f7bf1a3)

if(QT_UPDATE_VERSION)
    message(STATUS "Running Qt in automatic version port update mode!")
    set(_VCPKG_INTERNAL_NO_HASH_CHECK 1)
    if("${PORT}" MATCHES "qtbase")
        foreach(_current_qt_port IN LISTS QT_PORTS)
            set(_current_control "${VCPKG_ROOT_DIR}/ports/${_current_qt_port}/vcpkg.json")
            file(READ "${_current_control}" _control_contents)
            string(REGEX REPLACE "\"version-(string|semver)\": [^\n]+\n" "\"version-semver\": \"${QT_VERSION}\",\n" _control_contents "${_control_contents}")
            file(WRITE "${_current_control}" "${_control_contents}")
            #need to run a vcpkg format-manifest --all after update once 
        endforeach()
    endif()
endif()

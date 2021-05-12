set(QT_VERSION 6.1.0)
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
    )

foreach(_port IN LISTS QT_PORTS)
    set(${_port}_TAG ${QT_GIT_TAG})
endforeach()

set(qtbase_REF             80a246a982e1c332f074f35a365d453c932ccd4e)
set(qttools_REF            59ba188f13fa01e8590899ecbda47d2680929856)
set(qtdeclarative_REF      cb6675c5d314c05fb16fe2b9c555cc6a2c488bed)
set(qtsvg_REF              5bf7d6f7b91a2cb79910cb42afcffddff1ed838b)
set(qt5compat_REF          752f10fa6f84b8b2b738e46efacbce32125efbb6)
set(qtshadertools_REF      bcf88361f7a96f02f6c8f77a7fdf8abefae21df4)
set(qtquicktimeline_REF    d13e054604a24cd88edb92d3e85529f8c8ea631f)
set(qtquick3d_REF          b3fd7feee9a6350580203935dea7b221de67e4b2)
set(qttranslations_REF     e69b51751a9ec8c5d45661b83981297c432d0d57)
set(qtwayland_REF          e22789176e48314be1cbea5d12366eb77a220425)
set(qtdoc_REF              a8448c0b87376598a64333266f5acccd05e7a1e9)
set(qtimageformats_REF     2a6985b6e73be2b9f371938ca826430be13f55fd)
set(qtmqtt_REF             40502be35ca30025b45570574d4ee0f0b6bada2d)
set(qtquickcontrols2_REF   104555a8682d4095841feb9b02c9fd223c707b8e)
set(qtnetworkauth_REF      0e055a0ace5705d7a162236bf375b057e9ca124e)
set(qtcoap_REF             f09ed2ed8078dee75b5e7682b5832b2cee80c3b0)
set(qtopcua_REF            592ef6d24e8ebee0a35b0e46653f3e5b4f4f2d13)
set(qtactiveqt_REF         64e781f88e6758826be73751fe547b7e03c82edd)
set(qtdatavis3d_REF        6c79c3c0cd01ec29ce410e557aef293295349a22)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF           a8c5919df0c6fb9904920d20c4bb0ea18bcaba94)
set(qtscxml_REF            fb5dedff2f1ddbeeba680c4cf297525c0fd85652)
set(qtvirtualkeyboard_REF  66a0ecd2db90097fe961437e539182ee5ef17b33)
set(qtcharts_REF           0e713697ab2454b1c870cb750510b280f8059b0e)

if(QT_UPDATE_VERSION)
    message(STATUS "Running Qt in automatic version port update mode!")
    set(_VCPKG_INTERNAL_NO_HASH_CHECK 1)
    if("${PORT}" MATCHES "qtbase")
        foreach(_current_qt_port IN LISTS QT_PORTS)
            set(_current_control "${VCPKG_ROOT_DIR}/ports/${_current_qt_port}/vcpkg.json")
            file(READ "${_current_control}" _control_contents)
            string(REGEX REPLACE "\"version-string\": [^\n]+\n" "\"version-string\": \"${QT_VERSION}\",\n" _control_contents "${_control_contents}")
            file(WRITE "${_current_control}" "${_control_contents}")
            #need to run a vcpkg format-manifest --all after update once 
        endforeach()
    endif()
endif()

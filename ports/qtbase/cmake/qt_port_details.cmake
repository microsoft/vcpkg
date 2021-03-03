set(QT_VERSION 6.0.2)
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
    )

foreach(_port IN LISTS QT_PORTS)
    set(${_port}_TAG ${QT_GIT_TAG})
endforeach()

set(qtbase_REF             b98bd9786723af80e0b842fe4be20eb438d9beb4)
set(qttools_REF            d289a21a32d45b9cfde68147fa87541ade6e261c)
set(qtdeclarative_REF      8b63a045f315d700791d97eaf01a933353578d48)
set(qtsvg_REF              4dd1fcc2c4c3a05a1e7fe9ca89ed6058662d5ba6)
set(qt5compat_REF          2401d3cb0fb9a22bcf8fa38bac2b2d4eda42052a)
set(qtshadertools_REF      568e879cdbe57f31ac5d71cf54ec555ac460a75f)
set(qtquicktimeline_REF    d2ff70f20f24b468b41c018e702173176797e286)
set(qtquick3d_REF          36adebe34bfa1ee96144f9cbe33a8b3d0e4c8d83)
set(qttranslations_REF     68d61b111d5691787a01a8bfbbe5544feff4caca)
set(qtwayland_REF          baf596b3f5b20bab236415cf40eb22cc1f1c9989)
set(qtdoc_REF              3c9c31d855d9cf6c3e4d6c230507e728f2439dfe)
set(qtimageformats_REF     e3e85ef34135ed71f76ec7b75666fc5e6892dff7)
set(qtmqtt_REF             7ebe8993a3183fb6172fa77374e80064abf9e7ef)
set(qtquickcontrols2_REF   1a0048556707e4a58e30024c4b615f7aefe858e4)
set(qtnetworkauth_REF      c3962cd3fede093ce1d4a1b2c529b45656c8d9de)
set(qtcoap_REF             93d031efcd85c1cb3d7a967e743ee0023e078757)
set(qtopcua_REF            4f9908ae54a1b45c7d5465e537c9d7aa7b82cb12)

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
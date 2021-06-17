set(QT_VERSION 6.1.1)
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

set(qtbase_REF             9461362fb0aa5ec91bcfafe1169bd32cf9cfc828)
set(qttools_REF            3fa59b12c7e23e0eb3fbb0f3a9d3f7fee2669f72)
set(qtdeclarative_REF      34d723b38ef9b2ef851f589dfd0523420f4c5acc)
set(qtsvg_REF              242d6a797b6051baccd101978f3e138293701159)
set(qt5compat_REF          57202ccee96b7297202ba11c867178cff32b6eef)
set(qtshadertools_REF      954b90fa332b37ba1b60a2fcd92c06a0de6a6322)
set(qtquicktimeline_REF    2cb89aa7b120ec0ac84426d9f50bf8c613bbcd1e)
set(qtquick3d_REF          6c5ec5b14829f4181d035ad357f594e32e0e4119)
set(qttranslations_REF     47deef3a86795ef97708ec1da403a06cf696ec1c)
set(qtwayland_REF          f2c5c1304fc1a5123243a3a83ac8d8f3f67138ca)
set(qtdoc_REF              097bdcbf52a3cd798b66318f2b453cd01640e06b)
set(qtimageformats_REF     6cd036f63ff4b939f2ceb02fda98303a89a1b4b1)
set(qtmqtt_REF             d5c00c7245916a919b408578a6dd17bfac0e064d)
set(qtquickcontrols2_REF   1d84dc70059a6e324faab3535cb3958c6fa52fab)
set(qtnetworkauth_REF      a903abe7e43123ecd727ca2e29d552c5ed639552)
set(qtcoap_REF             160c3fb6850be44c09142150aef165a09946a608)
set(qtopcua_REF            c025fe5182a369723a67be06d64cbfbf2760ba0e)
set(qtactiveqt_REF         b9cf1840e44d5283f2212a73ba7b74ec18564d5a)
set(qtdatavis3d_REF        1629d860192ffc644a5c0c7d63e18a6ee6d5e295)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF           f6a4557b1484b9ad7db4bae8c5b6b264618876e5)
set(qtscxml_REF            666adc604fec06fa5b38be4d4f1b0e9b56f16c2b)
set(qtvirtualkeyboard_REF  5c7df0c55a96e9855bd27c23a18d6f2d91305d31)
set(qtcharts_REF           251d18d960a6f6ee04f07ba338beb317c425e0a2)

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

set(QT_VERSION 6.2.0-rc1)

if(PORT MATCHES "qtquickcontrols2")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    message(STATUS "qtquickcontrols2 is integrated in qtdeclarative since Qt 6.2. Please remove your dependency on it!")
    return()
endif()
set(QT_GIT_TAG v${QT_VERSION})

#set(QT_UPDATE_VERSION TRUE)
if(QT_UPDATE_VERSION)
    function(vcpkg_extract_source_archive)
    endfunction()
endif()
set(QT_IS_LATEST 1)

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

set(qtbase_REF             049660f99573b70386ee3efff05c26e73575d77a)
set(qtshadertools_REF      087d15f4067f85152dd6d467b61895ce1b6119a5)
set(qtdeclarative_REF      3f4ec271712224f516eab4b6c678e3f6183afb74)
set(qt5compat_REF          0795a11d153ed4750e0e4cdfa7cbc3ade6e31e7b)
set(qttools_REF            726730449552500753162bcd37448d283953c25a) # Additional refs in portfile due to submodule
set(qtcoap_REF             a7dbff50e7b0c082b32ca3a0be1dc967ddde3dc4)
set(qtdoc_REF              801c7330f2c26dbdff4c2ab9d4388debaaefaef3)
set(qtimageformats_REF     bcef3485ef0ebb125381ac4676733a77752c0416)
set(qtmqtt_REF             1d9b8f2dc0d19f02359a86bfc78f4f8ccbebe102)
set(qtnetworkauth_REF      0e05b4328efd1cac87a04bdca1854fefe5210dd2)
set(qtopcua_REF            f88495648704d3c41a57c673402b211b397efc47)
set(qtquicktimeline_REF    c1884afcf61519b3516ccc21ae0f40fef7547335)
set(qtquick3d_REF          8cb1641b0af6ae1e802ea91f7e58d23f2497a7f9)
set(qtsvg_REF              69298104b9ab64e4a09e9fed859b060407fe7ca5)
set(qttranslations_REF     a1cf589112b0f70b46592618e0056694236601f5)
set(qtwayland_REF          d2ee6d3958b8ec97f1767e520a607183564acbab)
# set(qtquickcontrols2_REF   0) # Moved into qtdeclarative since Qt 6.2
### New in 6.1
set(qtactiveqt_REF         e2ce49285a5e33bd4cd1ac60a56c64578d0eaaf1)
set(qtcharts_REF           dcca3c9b6a9be2223929b839309eee8d8c34ebe7)
set(qtdatavis3d_REF        6fef9db498d65edd4e3861a052d36b39f5bc5b6a)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF           3018915ac94b931edc109b0072e07206007d97b9)
set(qtscxml_REF            1693143f8a64d433c01487bd6bae13a4ecf8bc8f)
set(qtvirtualkeyboard_REF  86786825692dc59d54ae272d7dcc4aa807578982)
### New in 6.2
set(qtconnectivity_REF     75b00b2e68a95a5717325d6e4fc8d63f19c3471f)
set(qtlocation_REF         5755935a2ece01362d9143aebd9fb8147e87fe43)
set(qtmultimedia_REF       394e00eebae2724c1af14abd08808d2b43ebb973)
set(qtremoteobjects_REF    48b42107d890bbf1e2f3684a7f24052a81a82208)
set(qtsensors_REF          bf845f4f02a4e259671ea58f5f6f5d3e29f373bd)
set(qtserialbus_REF        d88e6e32e30e90cf193fa57b7544ab943377f82a)
set(qtserialport_REF       f7f9a2b5e6c3e603ac49aadcf0ae68e25e65fbb0)
set(qtwebchannel_REF       045a3b91cc426a2694ce26f988225c0f7d3814a6)
set(qtwebengine_REF        216bfd10362da2c9bdefebef27e8d1f86be95db5) # Additional refs in portfile due to submodule
set(qtwebsockets_REF       005d3993310ba44f1a81675f42335e398f800cb3)
set(qtwebview_REF          d0b5b5a98f3ac6697f3bd97731c336b9f486aa71)

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

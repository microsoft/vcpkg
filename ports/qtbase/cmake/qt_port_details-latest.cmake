set(QT_VERSION 6.1.0-beta1)
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

set(qtbase_REF             fa3a54d3a6a1862dca4f48f0413d4f472702bd2d)
set(qttools_REF            5128515571468eb4b6d7fc001e1f64ffed0c8761)
set(qtdeclarative_REF      4ba2cdf068973c2fc82f9d5bddb81ea2c2ae6d11)
set(qtsvg_REF              ea8e340dce7f90426a9a87e016ee8d4a392875ce)
set(qt5compat_REF          530c5f94e96d79cacd603a7f76043079164fcea4)
set(qtshadertools_REF      276644b05147f67bf174440750363284e2325f02)
set(qtquicktimeline_REF    f45e559fc4976ced2d0491dea8f843a1a6fed356)
set(qtquick3d_REF          f75954d2bba6122dccad6f39fcb0554ee371632a)
set(qttranslations_REF     d8d78e30106833c92851294a4da82502ec628d4d)
set(qtwayland_REF          779af844b9ff5b5a774c9b964923fa7c81a15a27)
set(qtdoc_REF              a2760f12e6d9a4cfd654ee652edde181615df1fc)
set(qtimageformats_REF     c814eae9e80dd81068f043573273e2e4d95dd8e6)
set(qtmqtt_REF             8d13d9f72dd20bf2258a2457f6bd4c2acd470d2d)
set(qtquickcontrols2_REF   546f9aa12cfb8b84bdb9d308f8ec27c701d0a4c9)
set(qtnetworkauth_REF      1375082bb68397b71d73e31b380f69c4cb0c3140)
set(qtcoap_REF             22f6772dd14ad25525f5375891fd5997cd043949)
set(qtopcua_REF            40f6e8046632e89d6df5edbe797db43bc01433a8)
###
set(qtactiveqt_REF         275ba35a8d34eb0a86e8151a5053e8c92372a60f)
set(qtdatavis3d_REF        06ed4d9ccbd0ba4e0f83ff0eb6054bce91276b6a)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF           93e8189b04baad3d6909df49913b7c9b031551c3)
set(qtscxml_REF            ea66ece49ea10f6e722f9b440d27c92f1d20882c)
set(qtvirtualkeyboard_REF  f5b2adb90ae03c8e552c0a0de74feb363eaee530)
set(qtcharts_REF           d72773ed3dea5bc55ae25a16af50e623cc213572)

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
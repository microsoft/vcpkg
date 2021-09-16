set(QT_VERSION 6.1.3)
set(QT_GIT_TAG v${QT_VERSION})
#set(QT_UPDATE_VERSION TRUE)
if(QT_UPDATE_VERSION)
    function(vcpkg_extract_source_archive)
    endfunction()
endif()
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

set(qtbase_REF             3ff48409ed14c7a63010b14e053a7201a61391c5)
set(qttools_REF            a69e290e25fd145a8b02223130192555f7962ea2)
set(qtdeclarative_REF      38845e18ef11ac2f1a1db82377b30f1649fdc499)
set(qtsvg_REF              24d635154689be46aaaf2ba0e3538d2f8fafeb3d)
set(qt5compat_REF          fcacd7f544b496420db485187aa55d76898ce73d)
set(qtshadertools_REF      06fc3c49b7b8cba80e6b6ff31ac5d703e3a2abcb)
set(qtquicktimeline_REF    be6321dc5164657072ff7069a7132d44222a503c)
set(qtquick3d_REF          ccd45eb39ec1fb88d62438c9dd0007e26c0ccc18)
set(qttranslations_REF     2d30ad16d90abfc0806d28e3504348df84b1e62b)
set(qtwayland_REF          501c287f34a66ec89e3e49da218feb4bc69c9c5e)
set(qtdoc_REF              13fa00e32307bae90884a608880a542f6ed90646)
set(qtimageformats_REF     8d6e8efc1afbd5e9cf793fbf0507e1d332c45d1f)
set(qtmqtt_REF             a6213a104f65dccb13508b58b0f07a249d9922c8)
set(qtquickcontrols2_REF   6d62c0677d60e42a19bb72d641129933770f7723)
set(qtnetworkauth_REF      7ce9e47b469141f9bace9661d07999dcc120e7f6)
set(qtcoap_REF             83b5b7e8e2c6afa9d5ab69123c40993c48b30970)
set(qtopcua_REF            bda48fd7729fb65a7504a1bada496489ee15d245)
set(qtactiveqt_REF         32cad4a02f78205e85490f6b8cbde82ecb1b5f2f)
set(qtdatavis3d_REF        8d6c15fa8daa68a4d48368b8ceb8c517e973eac7)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF           266531117ba6646893d3806566144aff19d5e309)
set(qtscxml_REF            aa27d28e302f3529940172ab2782c2d7e28fb532)
set(qtvirtualkeyboard_REF  eb26e2af30e6cbb2c4b9224d8e9f489f198c82f0)
set(qtcharts_REF           3e0d6ffa572efe8a09774ac6c6263b6df5eaf718)

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

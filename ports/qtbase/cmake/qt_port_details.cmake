set(QT_VERSION 6.0.3)
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

set(qtbase_REF             73af0d1cd12e54d383f8f6d8b1217167a71c012a)
set(qttools_REF            dbae6fc95197bc4981a3c61a90b8a1d0f70577e1)
set(qtdeclarative_REF      8600b07d5bb72b77f06e8d852f814c4e45419f30)
set(qtsvg_REF              f29dd880b26b8e7a11c5d5f73d30c12e609cf4b0)
set(qt5compat_REF          c3b2ac5384a28b3b2c9e122168f6b4fef5d7fa93)
set(qtshadertools_REF      252e7c18510f079153d1c38f3f762fd4cf996796)
set(qtquicktimeline_REF    e9b8c3f563a26b94bf51ff3a08f925faf6c51944)
set(qtquick3d_REF          e005843ef54458fbb8c3cf955338f93080f457ee)
set(qttranslations_REF     a067a1d5b8ccea3032caa3b1174f56d283309874)
set(qtwayland_REF          196b5a24b9672bca4521a7c8527d349b5c7ff1d3)
set(qtdoc_REF              cf52cc2539209045b3b81f2dc79f89f6266b5409)
set(qtimageformats_REF     fb1b7dfd031fee96766303952465aacf126cef4f)
set(qtmqtt_REF             9768532f83a36bb231f92b15d028acb4b7cc0143)
set(qtquickcontrols2_REF   a683588678639324d199985cda9c04373a179e8b)
set(qtnetworkauth_REF      38338f64dbd7e7603423a1d92eb97cf3827cc161)
set(qtcoap_REF             01ebd10abc24bce0c3b91990308b8fa880bf6103)
set(qtopcua_REF            6d2ba99c818df24cb042590a276e981445f500e1)

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
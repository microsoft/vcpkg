set(QT_VERSION 6.0.1)
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

set(qtbase_REF             420aac6214540a00687f202765493cfad707f5e1)
set(qttools_REF            c114af0e9c9158a3012132e10c1c0a44fb209e44)
set(qtdeclarative_REF      f29376ba8d0613097c3d700abeebf1cd8a835ca6)
set(qtsvg_REF              9bcfe50b01481cf598a14fe975c6fd5a71b317b7)
set(qt5compat_REF          f6076935f973148b26bf2fd038534acbfe096c17)
set(qtshadertools_REF      91810d61f8efd2c6f6cfe4d4f040346a12a65589)
set(qtquicktimeline_REF    d82eef579c62da02c711aec506f1a9c9f54b188c)
set(qtquick3d_REF          7ff8cdacab6512b5ac4ab35c7937502b324630af)
set(qttranslations_REF     2d04061fbd86f9c28372b260fdb560cfc14c7ed8)
set(qtwayland_REF          19cd7203fd57928bfb4a2691d36a82c3be81c857)
set(qtdoc_REF              d878f768ddd443212b973fe5628469b8e70a4eb7)
set(qtimageformats_REF     2b3af6c67bb5a053e3c8233d0daefbde27b85dce)
set(qtmqtt_REF             3f4c2fe7d871af74f31bb7102d49ec548b6e520f)
set(qtquickcontrols2_REF   7de2c89c98509b19d93b6ba295206e621c579f3e)
set(qtnetworkauth_REF      c11272a36a97c6b824d0ea73874aab97d5d227c3)
set(qtcoap_REF             1cb263af4ecc11e546f6b4e8ffc5f597c8470fed)
set(qtopcua_REF            42f8437a5fd3fb9fccf456d73d5a6c9a349090f1)


# set(qtbase_HASH             0)
# set(qttools_HASH            0)
# set(qtdeclarative_HASH      0)
# set(qtsvg_HASH              0)
# set(qt5compat_HASH          0)
# set(qtshadertools_HASH      0)
# set(qtquicktimeline_HASH    0)
# set(qtquick3d_HASH          0)
# set(qttranslations_HASH     0)
# set(qtwayland_HASH          0)
# set(qtdoc_HASH              0)



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
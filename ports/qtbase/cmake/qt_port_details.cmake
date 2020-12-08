set(QT_VERSION 6.0.0)
set(QT_GIT_TAG v${QT_VERSION})
# set(QT_UPDATE_VERSION TRUE)

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

set(qtbase_REF             6aafdd2f4cdb482996ceb14a0020f2cb70e40c3f)
set(qttools_REF            d5a7bbe55f1a364e1b0ac41c147b7610e88c4f8b)
set(qtdeclarative_REF      7c468ff76d5421a4a3201983a5b63a0e9ff38c8a)
set(qtsvg_REF              ff1069702fd343b5d1f3e4fe418b01f4327d74ff)
set(qt5compat_REF          a83a51c02b4076ed39ef5fc47af87e391ee01c23)
set(qtshadertools_REF      8a4863bc6ccd625761c004e3cd4147a22e2dd30a)
set(qtquicktimeline_REF    741793e67caccd5229386daafe96953d52d2fd63)
set(qtquick3d_REF          351fd4154e5391d353f7a324f9547ca0dfd42503)
set(qttranslations_REF     cdc41518a3ac6559fa27879529205dc9f464dde7)
set(qtwayland_REF          82d41dc9770de885af67e21f9091917f33094e19)
set(qtdoc_REF              0107165399487b0ccf4a13e35772dfcaab1a5712)
set(qtimageformats_REF     4f2aa66b2166412b75fc7348de3ffb32f6f116c9))
set(qtmqtt_REF             56ebef00b775a5342aa6a11d54fe9039e97585e5)
set(qtquickcontrols2_REF   fcddb4711d72c9be16aae3135520b60fd4c2ea4b)
set(qtnetworkauth_REF      7e2bb8225078a728a49ef66601f3f56b1ab62db7)
set(qtcoap_REF             98b614e7c8de52491929bc24506602dbe95897c3)
set(qtopcua_REF            5fa0b1e3a314238768a4a38634fef170665501ea)


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
set(QT_VERSION 6.2.0)

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
set(qtbase_REF              0c2d00de3488116db9f9d657fe18bcb972a83792)
set(qtshadertools_REF       119cd6e9c9e89f93b74db28f261382a2fcfe504e)
set(qtdeclarative_REF       37da36c97d9d557945abca3cea5c68d9985a06e3)
set(qt5compat_REF           291993c7813ec706e54069c7de339edfdd385c0d)
set(qttools_REF             00efbf90f978afefdcece314d19b79459eee2211) # Additional refs in portfile due to submodule
set(qtcoap_REF              be7822dc920a3e3eb252d5693a7153aa606d3dc1)
set(qtdoc_REF               48a1fbab30a9f57f011fdea8ec2b47048dce4069)
set(qtimageformats_REF      7bb9dc839c0dd0806445fd475b027a82c961f686)
set(qtmqtt_REF              4fd647e23d95c522c45d86be584d18578f894823)
set(qtnetworkauth_REF       aa23db40ca552d60383dea17d703b1cc0cbeace4)
set(qtopcua_REF             cfb3767b2a6785e0437b99c015cb6aef7f40189c)
set(qtquicktimeline_REF     e9578a6949f6192440df1cb261ed9de98a9de7d7)
set(qtquick3d_REF           eaf9c60073b95b03c006279f08d4947699c32a4b)
set(qtsvg_REF               cceecea040ca1247db0212217d07ec2c331004ba)
set(qttranslations_REF      03a146236e69ee41c0405a8b5707104b4ac0c6e8)
set(qtwayland_REF           8c4900dda393752faab14e39e60aec6b545c8a0f)
# set(qtquickcontrols2_REF   0) # Moved into qtdeclarative since Qt 6.2
### New in 6.1
set(qtactiveqt_REF          94c924a8501dba7487bf2648bdf06aefc33e726d)
set(qtcharts_REF            d56b9f3de193cbf561f4b1ec332d8598dbdaaaca)
set(qtdatavis3d_REF         5c90e6642882b3b7440608f71b96ce28908f0ee8)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF            48df4f1067514a3ae8b895b5f78fca09029d9288)
set(qtscxml_REF             68ac6986b9a9b3acfcab1e445edc7c198bbf7344)
set(qtvirtualkeyboard_REF   0e49e057777cd6c3f93d123e59a9399a2cf0040f)
### New in 6.2
set(qtconnectivity_REF      78e7ffbe16469a19fa34cad711e0898d91bd2f30)
set(qtlocation_REF          47a945b0d054539eab3ba1cf3a1d7bf5977051d6)
set(qtmultimedia_REF        d7d0e676abd4b280feb0d5105846378b64782487)
set(qtremoteobjects_REF     58932ba10420faa1cc989ed5bf101ff06475a4fc)
set(qtsensors_REF           192ca0fd252066101eb0456b957fdb51618fa7db)
set(qtserialbus_REF         ce089bef29ca55d7fe46508d92d3e498eb5bb847)
set(qtserialport_REF        14dc155f3640af94c6ecff2de1489e14cd5b0047)
set(qtwebchannel_REF        09315a8d626e106953723ce68e68d6b4b97c2c52)
set(qtwebengine_REF         261d72c8afc72faf23d169a64749db216db68859) # Additional refs in portfile due to submodule
set(qtwebsockets_REF        a01c2d6638fad700db23863258b7fc4a1ecdd542)
set(qtwebview_REF           ca0053b6a5320046508e9ba205df775a62c1a211)

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

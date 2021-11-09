set(QT_VERSION 6.2.1)

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
set(qtbase_REF              fbdf50b6c6f69ab88d7a53dfb3ab35e2b49a9664)
set(qtshadertools_REF       73deb667b27451340cafc20ead3aeb4ea84a5246)
set(qtdeclarative_REF       3419dd06c5928e292e0c25692427632e124eefea)
set(qt5compat_REF           3f69f4b1e7d07756b9de7629ec22e1c68265c88a)
set(qttools_REF             8e1f1f6e906095a8f2d5ebbf85443e2407d4e07c) # Additional refs in portfile due to submodule
set(qtcoap_REF              1c0bb10d86b43c4b3860cd4526087e644d3f4b07)
set(qtdoc_REF               040ef9a76b5f79d3cf5e42849d5f49a51522dc0f)
set(qtimageformats_REF      bd8b167280addfb9b2ee0d493d6cf7b31c03e574)
set(qtmqtt_REF              610543f328127c68ab39960ded51649ad41d3bd4)
set(qtnetworkauth_REF       1987896634a2c4ac23842b366b4704f0b1396de7)
set(qtopcua_REF             ae441a8fff3603e7d21957a09a0b3014669bbb0b)
set(qtquicktimeline_REF     6ba89379c0859622d71f75486b8d872cc4a709ca)
set(qtquick3d_REF           7e30ae5f8b6f3c28a2ee2df3788846fc67ec3c1c)
set(qtsvg_REF               30ad9d119079f486817e60025eceffdc0745ffcf)
set(qttranslations_REF      6d297398a2f9b0f7cf67de63369ca7b75ed60034)
set(qtwayland_REF           bea7e0ee35211873c90987c905e3fd68d41df4da)
# set(qtquickcontrols2_REF   0) # Moved into qtdeclarative since Qt 6.2
### New in 6.1
set(qtactiveqt_REF          1b710fa0b5e054189b62e2e7fe32fcf1bec0b081)
set(qtcharts_REF            78a74a1fcdc4329c054691021a65ff00dcd09ebb)
set(qtdatavis3d_REF         bec62cdb6f800087fd92085984fde389e9091e13)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF            9c72963a986d921e5c1cbdca6638fa17c9f8fa45)
set(qtscxml_REF             069fb385a21e2f844adeb74fbb06849ef5422c7d)
set(qtvirtualkeyboard_REF   b6fe68874ed8ff86202320435a743521a245c515)
### New in 6.2
set(qtconnectivity_REF      e910b93cc161930748260626b414b7f4241e6d58)
set(qtlocation_REF          70c3948264d5e6e3bc9be4f0e5d8fdae8b821a08)
set(qtmultimedia_REF        64bc1b00b2979866d577eb57fd118ae497cf6391)
set(qtremoteobjects_REF     8876b4e07174b7fe3124de74002730684b1d0d82)
set(qtsensors_REF           8a949e9314682e6940f1b38f30f5d5f3fd1d6260)
set(qtserialbus_REF         709110461a843a9a0236f3cde27414157a088235)
set(qtserialport_REF        d8b40852053623d44e8a07f4c208ace27dcde925)
set(qtwebchannel_REF        c93ddec0eb35707fafd209bee8472fd6ee4a3cb6)
set(qtwebengine_REF         b879b3ed6b4bb7d6951cf430d5e9b49898fe6c9a) # Additional refs in portfile due to submodule
set(qtwebsockets_REF        68a4c96964935ada5ae1ca323713b4e3862f010f)
set(qtwebview_REF           7ef6e31dd2ead012f941ddcaf30e5d4c2abf693b)

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

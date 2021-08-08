set(QT_VERSION 6.2.0-beta2)
set(QT_GIT_TAG v${QT_VERSION})
# set(QT_UPDATE_VERSION TRUE)
# if(QT_UPDATE_VERSION)
    # function(vcpkg_extract_source_archive)
    # endfunction()
# endif()
set(QT_IS_LATEST 1)
# List of added an removed modules https://doc-snapshots.qt.io/qt6-dev/whatsnew60.html#changes-to-supported-modules
#https://wiki.qt.io/Get_the_Source
#TODO:qtknx?

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
             qtquickcontrols2
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

set(qtbase_REF             b5c500b34ff9cb0cd84b9c3c9772866bcbafdaac)
set(qttools_REF            e14720c46ce6d9c234143b6aa4a942ae14df45eb)
set(qtdeclarative_REF      f4346d84d9ec34566ad8c771664ee8c4dd3dd011)
set(qtsvg_REF              568d5ae87553514c3772d2420bed29d2a6e69fa1)
set(qt5compat_REF          5093414282c11de3b675361d6bd937f660e4c60c)
set(qtshadertools_REF      93a4609b69f3c04936607e175fa1d2e79df0ab37)
set(qtquicktimeline_REF    3bef59ca05b017de7da507cda52184b88f206091)
set(qtquick3d_REF          a29915978ed25be1316b2a3d4e897ff8cf837e6d)
set(qttranslations_REF     4894c6e1306478cc2b347083e84eda07b1d63b21)
set(qtwayland_REF          0b9fbe6eadd87605a8842687f0aaf5f8ec931232)
set(qtdoc_REF              b79811b2a9bc57c6a9b743b553bf69542d8d7f44)
set(qtimageformats_REF     970e52a00f110d73991727e7b8c5e604a12e151a)
set(qtmqtt_REF             b2e36814edf8d1719da24bf6e9309ef5818f4821)
set(qtquickcontrols2_REF   a71fa9356119b0d56db3ae61ee52772f6f6016f0)
set(qtnetworkauth_REF      e61f8ce032c3d29c2f8d25ae6760b1ab6c0a3113)
set(qtcoap_REF             9761da4fd632b71ec60d202c6c7cf08ffd4aee8b)
set(qtopcua_REF            91018658136e54082fe80470d9b044ef567ec2f5)
### New in 6.1
set(qtactiveqt_REF         b9d73035cb9b5c46db41518b56bbaa60769f6357)
set(qtdatavis3d_REF        36f9feeaddd254b0bcd95fbf39d76b5ea89cef22)
#set(qtdeviceutils_REF      0) #missing tag
set(qtlottie_REF           1ba5cedb5b6b1b9b84def952db5ca461c665954b)
set(qtscxml_REF            f477cfb7a1db04024f2b42bc231d9b2f6c823271)
set(qtvirtualkeyboard_REF  efae4753ef1de3e5e6a413c00ffb22ae3b98fe5c)
set(qtcharts_REF           c60821af85303d92f613e58a1be6c1f1c6611889)
### New in 6.2
set(qtconnectivity_REF     6764c208f578bd3d6267675702126f7e11a59053)
set(qtlocation_REF         c5d2165ec5fed6c5f5541a4d3d9e14e2657cdf20)
set(qtmultimedia_REF       45d885de4fe6401a6847e15dfedd45e768247faf)
set(qtremoteobjects_REF    5a787426647236d212e83721e8098256301e3f05)
set(qtsensors_REF          7dc2c34652fe9e1e5886e70a548a0d71b9842229)
set(qtserialbus_REF        65b68dbae5dea515e9e6000a75e50c06c34b43e5)
set(qtserialport_REF       0d3f2b74a374b8a5c5f798d6107948884c36824e)
set(qtwebchannel_REF       e1191e1ab2b4f7ceeddb554c88115759a0047306)
set(qtwebengine_REF        65bc6bb918188e84feab886c47f9065b0e87c5cc)
set(qtwebsockets_REF       fe0e31129396446226917a1e89de68b71eacfe45)
set(qtwebview_REF          b51ab3f4b39b9defd544b005700e51f632b8d3e5)


if(QT_UPDATE_VERSION)
    message(STATUS "Running Qt in automatic version port update mode!")
    set(_VCPKG_INTERNAL_NO_HASH_CHECK 1)
    if("${PORT}" MATCHES "qtbase")
        file(REMOVE "${CMAKE_CURRENT_LIST_DIR}/cmake/qt_new_refs.cmake")
        foreach(_current_qt_port IN LISTS QT_PORTS)
            set(_current_control "${VCPKG_ROOT_DIR}/ports/${_current_qt_port}/vcpkg.json")
            file(READ "${_current_control}" _control_contents)
            string(REGEX REPLACE "\"version-(string|semver)\": [^\n]+\n" "\"version-semver\": \"${QT_VERSION}\",\n" _control_contents "${_control_contents}")
            file(WRITE "${_current_control}" "${_control_contents}")
            #need to run a vcpkg format-manifest --all after update once 
        endforeach()
    endif()
endif()

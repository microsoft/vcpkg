set(QT_VERSION 6.0.0-beta4)
set(QT_GIT_REF v${QT_VERSION})
set(QT_UPDATE_VERSION FALSE)

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
             qtdoc)

foreach(_port IN LISTS QT_PORTS)
    set(${_port}_REF ${QT_GIT_REF})
endforeach()

set(qtbase_HASH             01e4389ed00f44e8c9bdd61fb004a6c233e3b55fc60b6baa1937d5bf9a939689534a3ab0225c049ddb2c9d3243b501b264dcd4f978396f806164e36e8eac23f2)
set(qttools_HASH            1118c275861106c8a9a93f3c806c94bc43f88974e88a7518efae80e453d1f2778fc571d18ff885f51aa4a05748460bea49ad2eca042b0693adc4eaede5727004)
set(qtdeclarative_HASH      c769699042148b60915edf85ba402e0f942e86c83844a259506c936488e2d48a3e6aa41d25d508b20ecc26c14c40390213b078982b5cc870963b3fccdf5fa320)
set(qtsvg_HASH              268885ca5bf32dba4cd727ec0bd43d463c2f028d10858b96ce18ff8173773009e9ae41bad5643ee0f536731d4663af3c7c94d557fb6acc9fbc6d851fdb724d11)
set(qt5compat_HASH          0bf03271a89349a24889f4db8409de554b1a3748ff5070528f571c20c4469454bfc13a3014669eb3a2cff0ea315597416f3d3a3a0274f1eb6ef0b2c8694b66e1)
set(qtshadertools_HASH      91d4a0f36b541c742a99e26a2ecd9a28a59e3ca0bf6e388e4e3c8b4eda3db452563561b665c0cc90540758cf140ff765e0a6ad087d4f30fced830c4fd65af5eb)
set(qtquicktimeline_HASH    0019991b14c848599d46e84216956143d1735d5b91009793a932c936baadee8202db89f0fe510badc14e3a58218f17ba0b79715edd474e941f7ca5687f01640b)
set(qtquick3d_HASH          c558b09b7742047266d54cac13310f46d37a7d0262731786e402b10aafaa0b2ce8630ea7f1b8258db4e0e00426cb1fc4dddb1b9bdfed44a0238ee739020cbf23)
set(qttranslations_HASH     3fc3cd33e3c94937c582c5a0888c534dfb45ab5962b1e027f80a494726930c846e9749359fdea676bf41b8bfe9d3fef6abd8e95b4cabedeb1b236f511a9c9bcf)
set(qtwayland_HASH          fb938f80ff4487674c944df942e5c2a61960b889a0e241c91053d6a8f110d05bc09271d0618fcac6eb3e2f8ee9e83f15ff66d99de68b95d96938be8a0a84a96e)
set(qtdoc_HASH              124aa3a028ff05b029cc3400c1bdb4154dee4c66b62eed76709269d4ee82a042aaada29f89673cd807a446746091882ab1b5de6c9cfc7681467122377bcd6d27)


#TODO: qtquickcontrols2 
#      (qtimageformats ? no tag yet)
#      (qtgamepad ?)
#      (qtcharts ?)

# List of added an removed modules https://doc-snapshots.qt.io/qt6-dev/whatsnew60.html#changes-to-supported-modules

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
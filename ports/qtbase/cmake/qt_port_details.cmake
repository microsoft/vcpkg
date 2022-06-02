set(QT_VERSION 6.2.4)

if(PORT MATCHES "qtquickcontrols2")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    message(STATUS "qtquickcontrols2 is integrated in qtdeclarative since Qt 6.2. Please remove your dependency on it!")
    return()
endif()

### Setting up the git tag.
set(QT_FETCH_REF "")
set(QT_GIT_TAG "v${QT_VERSION}")
if(PORT MATCHES "qtdeviceutilities|qtlocation|qtinterfaceframework|qtapplicationmanager")
    # So much for consistency ....
    set(QT_FETCH_REF FETCH_REF "${QT_VERSION}")
    set(QT_GIT_TAG "${QT_VERSION}")
endif()

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
             qtdeviceutilities
             qtlottie
             qtscxml
             qtvirtualkeyboard
             qtcharts
             ## New in 6.2
             qtconnectivity
             qtpositioning
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
             ## New in 6.2.2
             qtinterfaceframework
             qtapplicationmanager
    )

foreach(_port IN LISTS QT_PORTS)
    set(${_port}_TAG ${QT_GIT_TAG})
endforeach()
set(qtbase_REF                  597359f7d0736917123842dee63a7ae45522eb8e )
set(qtshadertools_REF           d954aeb073375ee1edda4d6b2956c3c79b26b386 )
set(qtdeclarative_REF           614d85d460fa46e947eeb4281609ce5453a29e5c )
set(qt5compat_REF               c5dab10ba77dd2701dbd2d7b69998fbee90557f2 )
set(qttools_REF                 a60e0e5dfb2af83ffb1adda28028b24e21fe9131 ) # Additional refs below
set(qtcoap_REF                  29df645fc165087e74b603e7ad20033381006fb5 )
set(qtdoc_REF                   5c70158a15f23224a76b6919ab06eefee6ed187e )
set(qtimageformats_REF          356fb7846b5bc002b2d34e23253fda1dffed7932 )
set(qtmqtt_REF                  9ad6c48474c2b94c62a518dc3dc7e65d30a6309e )
set(qtnetworkauth_REF           d5ffb7549dd1e6139b746021c4d40053d0f15950 )
set(qtopcua_REF                 4a0dd4334d98bea48acda1e203ab2c31f207bad3 )
set(qtquicktimeline_REF         6a06bdbaa55d1c165e992732f2e3dc923846b921 )
set(qtquick3d_REF               d126dea81f48386ef24e8b30e1328c40e72c4861 )
set(qtsvg_REF                   77ea18adfb91c591f249f442e0ffc0079023e431 )
set(qttranslations_REF          87f95df09b1fc388ea15ce208a349d6b1deac2a4 )
set(qtwayland_REF               6bdaed8301336750dda95823ed0dfac4828ebab6 )
### New in 6.1
set(qtactiveqt_REF              5dd7acd1395627e6bd0d87beb148957059c1a3c6 )
set(qtcharts_REF                7184ea521d04ec13587562c3275ae698fa9a722e )
set(qtdatavis3d_REF             74c469d4926f59264c5cbc47fe301fe4713aa358 )
set(qtdeviceutilities_REF       f7333510b4dcfe32eb9065a63c434704750d4fb6 )
set(qtlottie_REF                fd61d8e92cfacbd3d10f31b176a7cde911525632 )
set(qtscxml_REF                 63455c888e012fdc682c32fd3d0de96127721bd4 )
set(qtvirtualkeyboard_REF       ffe9bba23ae45662d25ac3d90167d794e0d6c828 )
### New in 6.2
set(qtconnectivity_REF          f0ac95d1685f4f0f2e72fb42800b17d7738ccefb )
set(qtmultimedia_REF            3423c7172f948f27ff0512d1d2db4ea97fc0e9c0 )
set(qtremoteobjects_REF         2d0f27e736211e2a6b9d08345f65c736a17a67eb )
set(qtserialport_REF            c7dc6737a2e98af81900f55f814cf79a6d579779 )
set(qtsensors_REF               32dda47f507e74ef7ed33290545b762a0c20e532 )
set(qtserialbus_REF             1ebbf87cbc90c22817785bffc563d4bb86525abc )
set(qtlocation_REF              0 ) # Currently empty port
set(qtwebchannel_REF            e1014dcf9a924d3b8fd3450a3360381a0a8fc6ab )
set(qtwebengine_REF             cc7181c12d1d1605ecab6c448df4a684278d01d8 ) # Additional refs below
set(qtwebsockets_REF            fd509016da201ed63122c5ec79355930f2489ee8 )
set(qtwebview_REF               aade84c30fbbc85fe5a8c5e49172a02a7522623d )
set(qtpositioning_REF           3a68165bc88f9ddd165567d30887147d2d71915b )
### New in Qt 6.2.2
set(qtapplicationmanager_REF    2626ae6e9ce84aebd88a163153719c07d7f65b7d )
set(qtinterfaceframework_REF    71512be8758c75b4b6b0130d6b623f564c6bf227 )

#Submodule stuff:
set(qttools_qlitehtml_REF       4931b7aa30f256c20573d283561aa432fecf8f38)
set(qttools_litehtml_REF        6236113734bb0a28467e5999e86fdd2834be8e01)
set(qttools_litehtml_HASH       38effe92aaebd7113ad3bf3b70c1b3564d6226a766aa968c80ab35fa90ae78d601486226f97d16fa5bd3abf314db19f9f0c90e31de91e87bda82cde27f0a57dc)
#set(qttools_litehtml_HASH 935b3d516e996f6d25948ba8a54c1b7f70f7f0e3f517e36481fdf0196c2c5cfc2841f86e891f3df9517746b7fb605db47cdded1b8ff78d9482ddaa621db43a34)
set(qtwebengine_chromium_REF    b33b4266df8c333d3d273ae4665d6b322eee33c6)

set(qtbase_HASH 36a1a68afccc877cffea7e2532f6ed25953a31bc2cf7d0a5ab6c8698b3bf27e2ed9c665b778cf852e2e759234e072257d7975a346c22d4da5f92f7bbd31be8e1)
set(qtshadertools_HASH ec07cb11ef6d04486a9c0d4ad5a676d0ea0a1a809f40d51ff4e204566e51c6240d3e5688ae745dc24c48be162ddd58688e7274cb52f6d9541ca4e22a464a627e)
set(qtdeclarative_HASH 3ed22c61176548abf4547413834c65073b7a53b611d9126a2e9e482f65d94edf87c9597b34b9ac8f063b034e4bab256d244de2a5b33d883410759d229118c9e1)
set(qt5compat_HASH 7703253d1bd68aeea35fbc821f06df9e858822421451ff6d48b16206eb5da9877d90b4000ba2a7a7d7f573cd7857325daccffbe3672fd41051b5e7bd769857bf)
set(qttools_HASH 189b54f946b123650a2b6b2d75a34570d8fe90e14f18b7852166a855e254010d0a33efeda4cfb63ed428982e5a1a49f36da2c238c20f171e3f7cc05a4199e0ce)
set(qtcoap_HASH a65964d0523e8d4491204fe095c5aa35f528c6898f4a5ee4057f5c20cd07594e5c5f636011a88d2cf1d4601e0eab66f2886150cde2e10d80f373ec7260683cd8)
set(qtdoc_HASH 90c3c6e8fc72ecdb1c4ce4eb7a56871e42ba136ecf6f387122a9e619b00f892450c1fe37ddfeb0d1d7a2fa3fefb8c0f69948cf8a1d77e758e479dbc7ffd4b888)
set(qtimageformats_HASH 1d57e53ede5805aa646feb5456b1b50e7d314f39a441cbe3c0fac721d77c50dc09edadb9402da6a41cc47ca226329c9bdef5b3c76a1c70777a7263b03383a270)
set(qtmqtt_HASH 710e1bd9d0c7bb6a329f9b4e981efde914b35dbab69039686742de5a0d7ddf6dfc4986c38ce067c01ba4bbfb20293a4eb299c7fe89bfd2b5aeaa658dc7fdb155)
set(qtnetworkauth_HASH a97f76b225f026c85d856684d069043c1fe7cc8994a32e35d18e021236bc77563fe10fcabf7e9e9ac0400b7550cd772827a151a1bbbf378737d6aec21c0354cb)
set(qtopcua_HASH 3cfeb4d52a45ef1f58748973699282d4a406e4f1d9753161aa0409d61124c8739f9a89d143df8fb783557b11d25c1359e0d0acda35f892e59eedb4b78ef8f20e)
set(qtquicktimeline_HASH daa8bdd73909ab35b3717fab5f70271538c6a1735779f1ac54595fe0d40352991eb45678f7f6dc7f8b8897f9f1310d0003065534056acba3e4498a07906420dc)
set(qtquick3d_HASH ae2124e4358ec0d3a106eb1e69594311385fa1a5685388810a9e04d7a2d2054c36374590e74a937eedc1cccef836597d5a5f54a50c9d6394bdd15133c9bcde4c)
set(qtsvg_HASH d66885fcb07f2e3dc1f3c5df8e080c75fc6bf6387c670fdd84763f447b00b299059b1953ecfbd9b72dc8f7a0cac556fbb224c755780a4f480561263aace1415f)
set(qttranslations_HASH f33f0b70e7c95b929eb58b7edddda68c354c13ce199d5c2574d932f15bfa095c5c0e4fe4499fa9658bf0d7a5c9c98b2326894dfbb3f06f83f68a69988c0c8572)
set(qtwayland_HASH a253f43dd150152268e0c22d61a5446fde3248c250f55a6236ea82268c9be66121cd0c912749c88197b4fd5ab852fc4ba6a8c5690f7aa1a79bf69fff33d5bc01)
set(qtactiveqt_HASH 40f2ea754e7f2ecdd83ae97315270d2034a46e5fc5c419bad2d7ffcea6aa23a553c4ceb522027543442d6fbe6c58b98c9f6f6f1447d659a67dc0d9202e110a91)
set(qtcharts_HASH 357cf8ba1c53e48e081f875fe1bffebe807d5067a9bf28595f4bcba65bc79c9270f42a3cd9c5a8f09a58f07644555a035fcf4ae9e6491ea16106b939505bf267)
set(qtdatavis3d_HASH 10b7b51786dc7e89de578dc053c15505146cc3e9f7f167e54bc94bbf8c1a853a53d7fa62ff02dabb7e17096a0c9d08c6c96e7916d33961c02d9493079b1520b6)
set(qtdeviceutilities_HASH d98ffeea1f86dffbe7ed360d62db2d1ab12456a0d3bbcb48997cf982340cfb89941b0d511ffa5cc51a8c716933f82e8380ce99e42f355fab8a38ed2bd9b07d13)
set(qtlottie_HASH 97e5ede0837516ad45991bc329b690ee9c9d263818cef23186c8fc76ce73ce6a0d6e17d0de50d7c25e6e0c9e7d614752b874594b765c1dbdf0f86733ec63850f)
set(qtscxml_HASH d9c6f659470de06685fce51aa1a210210d7b5464a7f5d7384caa91660d504fa3874a495b23db225936a5c2fdf3fe971010d9884c3c24042ce03ab9ffca4cbf23)
set(qtvirtualkeyboard_HASH c9f0918b32677ea116db312245f2ee4348f17dcadb5c94fccf6d94633da325c7bbec2ea7f6c6fb20e3971bb00b9417ad65725c629bbb90f7a10f84f3b6224c22)
set(qtconnectivity_HASH 3f77f88775e04a710a49a01108c5e0deafbb3e8aaacb66c2d7ccb656082c95feecce52f7227358b0759527997ddc107f39dc813b4e265e6de06b27b86232bc21)
set(qtmultimedia_HASH 8612bbf2cd16ed6c3719cc0b57acc91f2121d1d5a89110eeaed42f57ea153bf151f4d31e442c47d57acb08a93046b98f281515c0618ad7316a8564b2b7b9cb8f)
set(qtremoteobjects_HASH a0aaf99a662be97d067082346ea91f187facc97d9eb49cd98e86815eccdccb1de39c05aadcf5048f3c163108a1063c4303cddae8b0e6c3f95cd135abb6937f32)
set(qtserialport_HASH 2256a8a770b6d46a1d35a28be7595239b6b9ac7c82844387c67537ec8848d5269209a5f9af10d52615684534879e74e94f6a0115c91f51a9458e926dc988086d)
set(qtsensors_HASH ea2a1575f38d3a2b2e0430d40bfc965fc614846ae9c368a2e31e97bcb468e468dd25c7c230445e0879f6785e491f4536183c5acd30a121063cabfac674a1d15e)
set(qtserialbus_HASH 945237a5017332fc591e8d716109f6797b57eed1b79546cbf4273ef0c34d2b9664aa97ef6eceb1c32d3d3fa4d1716ccd31a2993cc530767c435665411d741f6a)
set(qtwebchannel_HASH 23b7d782b5a6ee224f464b54d9f79228705de388ded106b5e631e6f18ad8999abcfb178cb29aee7c123c50ee64aa04eb1eb16c317d15f762faf09e6b0b5b77ce)
set(qtwebengine_HASH 12498d9e1ddf1d75b66881077a416dec2d4d53d6e73e283f4352f68226ee471186d5566d9d2fe8e4f82d0dd774e7527c783271fb5baf8b93ea3455e0152e0782)
set(qtwebsockets_HASH 7a63145a198387366546130acd736d15d9b9a2dc68500ea5ededd0ff5339fac98c97ba7e4e836ba58f4d1daba0ad0eb098078d8960ca5d802a48b1c2906693a8)
set(qtwebview_HASH 966d0e22b2df4180b970f734a2bd78c4f48095aa52f7b22f12729ace2f80f8cd1f17c59bbf41fcc19159533de3fb6bee24a4df3226c2ea46ae3eda373e01a273)
set(qtpositioning_HASH 4aaa2e48d7715a0f19e41e7bbd495e54b434a7f479acf090198e2381a051030756eed31b4d9a687cdb2ec774b01985901373836f94af0d71b614d346c3c94271)
set(qtapplicationmanager_HASH 1904fd16f7b2963a5d4a7500049bb9f37a1ba3f17530ddb9d397301d7f6e4dcad8ce5e1b9ea678a671ce8b2f9d3615f4ef514728d97c631e55f4d541be8691af)
set(qtinterfaceframework_HASH 935b3d516e996f6d25948ba8a54c1b7f70f7f0e3f517e36481fdf0196c2c5cfc2841f86e891f3df9517746b7fb605db47cdded1b8ff78d9482ddaa621db43a34)
set(qttools_qlitehtml_HASH 935b3d516e996f6d25948ba8a54c1b7f70f7f0e3f517e36481fdf0196c2c5cfc2841f86e891f3df9517746b7fb605db47cdded1b8ff78d9482ddaa621db43a34)
set(qtwebengine_chromium_HASH 935b3d516e996f6d25948ba8a54c1b7f70f7f0e3f517e36481fdf0196c2c5cfc2841f86e891f3df9517746b7fb605db47cdded1b8ff78d9482ddaa621db43a34)

if(QT_UPDATE_VERSION)
    message(STATUS "Running Qt in automatic version port update mode!")
    set(_VCPKG_INTERNAL_NO_HASH_CHECK 1)
    if("${PORT}" MATCHES "qtbase")
        file(REMOVE "${CMAKE_CURRENT_LIST_DIR}/cmake/qt_new_refs.cmake")
        foreach(_current_qt_port IN LISTS QT_PORTS)
            set(_current_control "${VCPKG_ROOT_DIR}/ports/${_current_qt_port}/vcpkg.json")
            file(READ "${_current_control}" _control_contents)
            string(REGEX REPLACE "\"version(-(string|semver))?\": [^\n]+\n" "\"version\": \"${QT_VERSION}\",\n" _control_contents "${_control_contents}")
            string(REGEX REPLACE "\"port-version\": [^\n]+\n" "" _control_contents "${_control_contents}")
            file(WRITE "${_current_control}" "${_control_contents}")
            #need to run a vcpkg format-manifest --all after update once 
        endforeach()
    endif()
endif()

set(QT_VERSION 6.3.0)

if(PORT MATCHES "qtquickcontrols2")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    message(STATUS "qtquickcontrols2 is integrated in qtdeclarative since Qt 6.2. Please remove your dependency on it!")
    return()
endif()

### Setting up the git tag.
set(QT_FETCH_REF "")
set(QT_GIT_TAG "v${QT_VERSION}")
if(PORT MATCHES "qtdeviceutilities")
    set(QT_FETCH_REF FETCH_REF "6.3.0")
    set(QT_GIT_TAG "6.3.0")
endif()
if(PORT MATCHES "qtlocation")
    set(QT_FETCH_REF FETCH_REF "${QT_VERSION}")
    set(QT_GIT_TAG "${QT_VERSION}")
endif()

set(QT_IS_LATEST TRUE)
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
set(qtbase_REF                  0668a36d2804b300010d874f5ff4073c25c2784c)
set(qtshadertools_REF           e526e8ca88197d82996818db1f00e8a3e07bf584)
set(qtdeclarative_REF           cbe89ee41aa219ce7e90143e3cf54283e580f7c1)
set(qt5compat_REF               32db676ab6854633512181b2c40950c98525c5ba)
set(qttools_REF                 a0a9cf1d1338b3e7f868bc0840e1e9a096c86dfa) # Additional refs below
set(qtcoap_REF                  4453575b94836cf1cd52642eceb1d6f5d16b26a9)
set(qtdoc_REF                   d0da4d47f152dc50fb672bc5011b61a5bbb36f43)
set(qtimageformats_REF          45cfb044698df541ced53e3523799232599712a6)
set(qtmqtt_REF                  3174dc30d2b37c74ea685d27ab0030c7392032c0)
set(qtnetworkauth_REF           507214965cbcebbbd563904d615cf7ebc464cc48)
set(qtopcua_REF                 2c7051d85f640e9afe6c3f8f718bb2152305467c)
set(qtquicktimeline_REF         16bc2eb9f5e84923dc04c3941f5347cbc1b0e5b0)
set(qtquick3d_REF               bf912a678898dcde61f139f63b49e1e42717fa8d)
set(qtsvg_REF                   cf900932886ebdd3de6c3a4a7e63cf363663eb87)
set(qttranslations_REF          19701f38b9dc10d925c6974833d693b5038e1589)
set(qtwayland_REF               840673bf1849595869873bad15c52a312e849ffb)
### New in 6.1
set(qtactiveqt_REF              747fdd27c413ea42fb730230331984f388d3826b)
set(qtcharts_REF                03929b43d8e2a5c9b1487fdc6b8a2b067ada16f8)
set(qtdatavis3d_REF             137ebda0932e6faf0fbd61b0beb3cfb4dac8efbd)
set(qtdeviceutilities_REF       0520d7fd121f7773d04a7d3318553ff7fed1b3a9) #
set(qtlottie_REF                e68bf89fefd941a930c83e2c29b629fcfea03eb3)
set(qtscxml_REF                 4f52a1b6e4f25f3473f42ce249c4c183c5910183)
set(qtvirtualkeyboard_REF       92aee38dab196e8b5ca436f9f20c0fc66d8155d5)
### New in 6.2
set(qtconnectivity_REF          f62954bad729f7853c9fbe2ea0b3235cfae2701a)
set(qtmultimedia_REF            3d2dafab1eb60c17a30cf03213cd2f6f71185137)
set(qtremoteobjects_REF         2c53bf0e9262a24f8fc8553e5004e7d00bc7e556)
set(qtserialport_REF            7e44935b14b783add342a25f426fcdf299279024)
set(qtsensors_REF               3222894c246076c6e7bd151e638ce3eb4ce5c16b)
set(qtserialbus_REF             3ee1694d2a8fb0b755adce4b59001b784e9c301e)
set(qtlocation_REF              0) # Currently empty port
set(qtwebchannel_REF            a85e05069a2b17ceb5b6332671a2eef261ec783f)
set(qtwebengine_REF             9158e7652f24800b2b7dbe59b7834687bc1baf13) # Additional refs below
set(qtwebsockets_REF            487116c9a85d8f5a920f47045dfce0b0defd5139)
set(qtwebview_REF               d7498a108c67b21c39d8ba775330cc122ce21c1a)
set(qtpositioning_REF           f61d2f336892b85cdcd5d508bb4a0db7f768d439)
### New in Qt 6.2.2
set(qtapplicationmanager_REF    68464eb2b3fa89c69cfc5fc4f19450af61116dd2) #
set(qtinterfaceframework_REF    7ddeb99d6215a4b63102d6a5bc73e50d77ddb3d7) #
# not available via GitHub
#set(qtinterfaceframework_HASH 935b3d516e996f6d25948ba8a54c1b7f70f7f0e3f517e36481fdf0196c2c5cfc2841f86e891f3df9517746b7fb605db47cdded1b8ff78d9482ddaa621db43a34)

#Submodule stuff:
set(qttools_qlitehtml_REF       4931b7aa30f256c20573d283561aa432fecf8f38)
set(qttools_litehtml_REF        6236113734bb0a28467e5999e86fdd2834be8e01)
set(qttools_litehtml_HASH       38effe92aaebd7113ad3bf3b70c1b3564d6226a766aa968c80ab35fa90ae78d601486226f97d16fa5bd3abf314db19f9f0c90e31de91e87bda82cde27f0a57dc)
#set(qttools_litehtml_HASH 935b3d516e996f6d25948ba8a54c1b7f70f7f0e3f517e36481fdf0196c2c5cfc2841f86e891f3df9517746b7fb605db47cdded1b8ff78d9482ddaa621db43a34)
set(qtwebengine_chromium_REF    2c9916de251f15369fa0f0c6bd3f45f5cf1a6f06)
set(qtbase_HASH a460c61f11560acd95fc24633644f7f4b688fa9b978d7e2552bb09382f32f1801cdc16cc69e85ba555e84e9647ad3e634956936ed6e2606fb2d75c6501cf2ae4)
set(qtshadertools_HASH 6b07f03f9a6e3b755c27155ae8ac6c33aa5ae04085a256b46ba872d4cd46e78ebe128d40bad1a713f5d5c1622bc3a267d8ce89247187a93f361fd00933f52875)
set(qtdeclarative_HASH 4bf010b74bdd40512fae6de4c7a63d43e90584bee792840bea55aa5de64d307e03c61adb5d1c3d767f787842bfe97e269b5153b5862b2808b4ae9005d707bcde)
set(qt5compat_HASH 8328f9b6d8c3e342e23e69da65fcade8196ef196cf4f8abcf2e045d64479a04c3630c687fb0b52d6a36c234d041791915322685f582329b9441887193507279d)
set(qttools_HASH 9c80472a9962f4c5dc1b882d496cd854541c309f828cead1a5c22d7b225c63a666a1dbab84007494a902a1877819be63145fcca9a1dd1847a8b168ec273668a4)
set(qtcoap_HASH 5e1528003434ad2fba42a06ad7f1fd623c78e6b81ae21fb0ca9668c96c2a09d23c3a38630180851b874ae33b667b7083eb996e3abbe92c970cca02fa332162e7)
set(qtdoc_HASH d4680aa24768bbcefd96874b83a0e0579cb67b488784656d8f6d42d9a428afa0b38b05dbdd10a5dd63f97743dd2dac02b0e34557a14a300765341ffba8dfc2a0)
set(qtimageformats_HASH 6ea6a096a43a21c5003a56887d60ccd0215442f7dca986e136ec9c9ce9a5740cffd99691325679e6ac1ed637e13d9a9620028512e87afbb32619d7518b8ec84e)
set(qtmqtt_HASH 3642c481b4d53d8140ae247578da536df84c6fe911a5e1ed9d2a68dd449658bdd4df04724ca2bc6e7cc17d3cde82bd4acea64f01b73244f335cff7926a59e587)
set(qtnetworkauth_HASH 7c4b1aff11e255d2900590e422a9856dee819751b63ac31520528faea2197050834e5311e2243d2d59ce0dd5d7c4362e4231aaf15c76ba1453091e83e5e5d208)
set(qtopcua_HASH 7f4a1ea071731ec586c65ad8cac11d11857bafee540bca76ee6ed6f3a9618f90c0252cca30e7a3feaa924e86a7961ec9bc672d15ee4f2584220ef5766868fcae)
set(qtquicktimeline_HASH f6f2c1c6540fc8635b3b0d441be375ed3541e13792abdafd461fdf41a173014016a80893f90dc1aa0437182c3b8d2fc94ac544736c9220b460b29c721babd4e8)
set(qtquick3d_HASH 90653371ff0fc9ebe298b873ba4daccb22f2cb742382f494a070c0f04fbe67f22da9fb88fbb1cdd02eac5bbec82dc3f45175f6bfee31b4c0cecdc779fe64a9c3)
set(qtsvg_HASH 5876c8024171a7a204507f8c5796a2feb41fcbf3c32093389a2fe224d7be38c55ed77a81c07b99eb3a098b10369dfad9a912176dcfd454d3f35bf5bd2bda7276)
set(qttranslations_HASH 62f3ef4b21ae1a99751b4b2868473428751997fd6e38289ab1e29c8f4f3fbb21c9633fdb74f1cd0c44acf6beac2e7720163bf870d8b91773a3b4d87044c904de)
set(qtwayland_HASH 30b20995dbdae5ef9d4a17d564554bc3b80db0e936629d9f78451f7e1a9d1c4bd1c26ffb6379b5d995afc372b5b31ef7f9bf176af7b0dcdee00fe9989140ca23)
set(qtactiveqt_HASH 259f0888745e49030f18432c3e8e3bd3cb054b532d481806cd361a200add94d4f22c69b868f6a5f3728c596a2cb1f30e5af5a176aa75922aef9072405fb26c3f)
set(qtcharts_HASH 55858e87f72d2af03510d41bbe739944d606e32c2c4903c07926bc3d8fe6f42cd91c62b9d24e54fb9b5f983d891441561809e6d19c7088f09e709e7e76ad42fc)
set(qtdatavis3d_HASH 25663df8e32e370a99d55e766c56de57f88adf7f23c4f070ef9198ca9abcef5ce2b8ee7928c3b60160458b3a57e5aa1fd078cc08a5b64cb622cb88352378ea92)
set(qtdeviceutilities_HASH 9e00f20d7569967f14808d91cac1a71fe2e1199866f23fc6cd7e2cd700c39b6a814b88664a8cca92703139517b95e334b41562152d860c224cc2b64ef10663fd)
set(qtlottie_HASH feb04bb237d54cb8ab2c3649693ac68006930d1d3bfd8bb27c79072dfce71c55eb1cf0955a3fe6051ffee5edfd3b51c6aaca48b089c4639ef98fa44c70b73cf8)
set(qtscxml_HASH c98b976f1e8e6d87a5cbfb501f3a2a0624f60183b8ae317a8da670cadf0e44f257b535509e9ee26ac916e3b9a689a50a4c7a1ad01e4a9ad28d4edea573611966)
set(qtvirtualkeyboard_HASH 3bb12a72e081b1d6fdd35ea63241c250ee8087dd2a7fdd8ae405678745f20e92ee3d885674fd037821423e93af2e0902c9bb060e415d1c70a77822867b9f12c9)
set(qtconnectivity_HASH 48a233dfbafac8afb084f46b914c1c7b2935eb846dd0988bf0aae0965a60806acb96911d9f61eb50c3f7a81720ed6b9ce83398199371555bdb7e8e23057eeba2)
set(qtmultimedia_HASH b618af4ca8df9524da3c088354b68afd58391a8c49ff4effaf7c293fd4a970ab49f6112f51feb5aff140adb55260043f223e755e02ef7a861e6f9c8b5a0d8467)
set(qtremoteobjects_HASH 32885aaa6de9e68d2c2829ed364a47e922c69971fb7e620a912223bb8c82c0f9a3d4715b24874bbceb5e195948efed9762bdd8c722d1798e7bb23dc0f56b0cc7)
set(qtserialport_HASH b57951bdf1e90e07a8950a0e94561ed79422a6cbe8b666600d8c4adeeaf26e6a9bd48ddd48d4a487fff539f9634ab9baa130490b662b4cf956538498ce827671)
set(qtsensors_HASH 389804b34837df815105432eb22b959ce5652d25d2d42ac78e1a5d073c2595d1d02f5eba6495418b63d5ab920a855d5404b357199c3eff64a0252a8d30deb3b0)
set(qtserialbus_HASH 1b802910f31abf08959d04a651d606ed11e6be365db65acdc99a8292a65f9e4eeb5d61c628a8317687be7d3c0a7d6bfdd531f004305513880d9de44ce12f4aa5)
set(qtwebchannel_HASH a856897626e86eb6ef47e883782688a93b639b258fb662d907c8bf748e792d4913e4792e8db31209ffe49695575caa048d57cf6d2b6e0510d06f786e6c070a26)
set(qtwebengine_HASH 5124085c817a6ea4873972fedda3fda7d822364cceab3562526200b195fd975a876d6d816d08a7db8e3fa9467cbf282e1e11cf0118cfc4f9700603198c0b4fb9)
set(qtwebsockets_HASH f0004e302c849dc033f9c40dd24efe3709aea0484f25a8d07b4c4a7d60ab93bc9b8da96082afe0db5bdc7b4814689b45ccff92603c5ebb0f6c98cb8c44b5a4d4)
set(qtwebview_HASH c40d88f77845f37820abe88efb77f6bc70355a0bb144a23c2598b8f6ded65ab6a9123b74f7eb9b6c87609801606b65d9c7c49f3fd0b8d678b51b6c73b4d6e724)
set(qtpositioning_HASH 51e6d65c7520a2c29a1ae5aed5e278eaf13a41709af96c2d2f96d19fdba6c1cd200d3772a7a832156f3c0e985799500c2140ee763cd90219712c04acc3c0fafa)
set(qtapplicationmanager_HASH 57aac3e72ad5b725f9a1c409850cfdae37810784c9f22650b73435eba938b4df05b32f5f3107419d3ae20beea0da15aa6ebd1d809ceaa52ee229f2ffc0e918ef)
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
            string(REGEX REPLACE "\"version-(string|semver)\": [^\n]+\n" "\"version-semver\": \"${QT_VERSION}\",\n" _control_contents "${_control_contents}")
            string(REGEX REPLACE "\"port-version\": [^\n]+\n" "" _control_contents "${_control_contents}")
            file(WRITE "${_current_control}" "${_control_contents}")
            #need to run a vcpkg format-manifest --all after update once 
        endforeach()
    endif()
endif()

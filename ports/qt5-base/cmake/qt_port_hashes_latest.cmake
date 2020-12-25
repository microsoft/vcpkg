#Every update requires an update of these hashes and the version within the control file of each of the 32 ports. 
#So it is probably better to have a central location for these hashes and let the ports update via a script
set(QT_MAJOR_MINOR_VER 5.15)
set(QT_PATCH_VER 1)
set(QT_UPDATE_VERSION 0) # Switch to update qt and not build qt. Creates a file cmake/qt_new_hashes.cmake in qt5-base with the new hashes.

set(QT_PORT_LIST base 3d activeqt charts connectivity datavis3d declarative gamepad graphicaleffects imageformats location macextras mqtt multimedia networkauth
                 purchasing quickcontrols quickcontrols2 remoteobjects script scxml sensors serialport speech svg tools virtualkeyboard webchannel websockets
                 webview winextras xmlpatterns doc x11extras androidextras translations serialbus webengine webglplugin wayland)

set(QT_HASH_qt5-base                40b687c046b25a6717834ffe2616ee4f373d75214ec1c7e3a26502cd0cde9f0a872eaee99f06c54c7a3625ae85df5cdd3a3b54a160e8e37c7cfeb5800d026fe4)
set(QT_HASH_qt5-3d                  5d35f39bd3cb65a4b7490fd3d57a4f62b3ccaad25c7963613d67641927bdc9d895fb436d049de5485a9e8e067c716951e376349cbfc3996af6765adda73d51d5)
set(QT_HASH_qt5-activeqt            d272a6b9748ce25635c1631290670c6372f803c05ead4a8607b00e5ca777eee355b579d4040a1ab619c3f72879518e9557ea91af1cd02ce5d49f2bcb7fd1c305)
set(QT_HASH_qt5-charts              7e644d4a674f175745646f8b541c8cfd972853fdf3a3ee5d0f7c23f035ae81cef0671292535fe65b1c276e4c54c7a48db1a1d2f9be97834513d154eea1666f3c)
set(QT_HASH_qt5-connectivity        ad7bad604c466461bcc7bfd889ecbb36e010c89ea1ecf7736f8b0ad49e682a1800cd2507b8d8c0b582c424b176f8179aeec85a6b0fc4ed933f8b6032e935d39a)
set(QT_HASH_qt5-datavis3d           3f11cddebd29aa90ce62fa19f9ab33026393bf95525bea7c4514e04acef23db9dbfdf000aa885aa2f823b1cd6ca99ac2a1f8afaabe67ee13785d5e4650aa4c97)
set(QT_HASH_qt5-declarative         193ec706b764330a2ae00614b13482b7586642f9cfd32458e8c975daa07ba25f0f9887de0918c4034f52f613b860677c09c46a3b7d07d4229446cfc0805bcccd)
set(QT_HASH_qt5-gamepad             f74933f9e28d0db03d30743e7d75c7a1ba28fa03d97aa894b5cbc306a2d501c27ec40eb84c6b999a6e5ed01b3126bfa992a3a3ca28246310edfe1f2fc12c1d88)
set(QT_HASH_qt5-graphicaleffects    651f8d96199b6324726fcf97eebf16a3ee40e5a9523a3c03255ca4201228b8d02314d5dd9722f59d44f09b4ff8dd722fb276b9af7f65728693a2c4ee62f781c1)
set(QT_HASH_qt5-imageformats        90da1c76b16dc5ea4ba99372208e3b10619efc4d131686ac6ab4a963ab0177ff9eee9155af564d72052f4ae1c21f06431ab66aa4e55b3c864f015b63ad75c107)
set(QT_HASH_qt5-location            b79383b60107bc4d8fcc9b4a087db57597d0b928248806fef9dfeaa8ce3347ce96b388cbce1a7bcaf3287d380f7c269c44e8ec25966112c041aa298313854106)
set(QT_HASH_qt5-macextras           6671d21edba0691833d45eaf7474b20be55088252fff70f8617f953366834bc5915712c00e53288dce1d97ab7f0080f4fb7547594034bd627d010d01906e20e9)
set(QT_HASH_qt5-mqtt                6ea203318d0c4c6441f23a2648e0a3879b72426579ad3d6af7895c50cc80214010b2aba5a2103bb69df8299cb84ae7b1a0fd88d4cfe6d70b1cfc5694332b81d4)
set(QT_HASH_qt5-multimedia          9c063dc481c91a94ba151fa96166d04a83e1cdcdb66c5fa80c038bd973c87b928c3d90d1c8add7c3ec29c4dc7dceff9e8cf288ce980f95d199f37e90593104d9)
set(QT_HASH_qt5-networkauth         2c22acf4842f2e26c514ea48bd4e21f466571c1993b811495c1eb9fe22ea66a687ca882c9ed09b38c00a9a6616b13d44021e0d9a65020f4ab9495d6e8c64d282)
set(QT_HASH_qt5-purchasing          5e112f449d1db2851cfbaf5b84feaba6f1243abb4c4ace3a7e2d23859b410305e0e4799c1d109553266d21a647d85688442f4ee0878434eff0e4c870a90536da)
set(QT_HASH_qt5-quickcontrols       71e6ee040bc76dc1576d31ff2c1d687e115f4c6dc63307e64c8173c2441835923375ee6b7f5473b3ec8c586f34e04b061b9a9e16b7f34b4075cfa0278599d2ce) # deprecated
set(QT_HASH_qt5-quickcontrols2      ecb75619e80b737e3ae214f65a5175d933f8dc7832eb4eccd469fc1cb1eb85ef5c47f81563165da2d75abf15d7c47b868e68ab758d95183371b4ef64e7c52a39)
set(QT_HASH_qt5-remoteobjects       be7d1803957295b4900d96bc1c4bbb50bb54a0ef750a5b713ce318636040954b765c546e4ab9c95880f4c03894e5cd56ab5238504bb5c44fc4a3c277611ab997)
set(QT_HASH_qt5-script              f97bdf0a3a402f2658d23c92d2f0d916bda68b63f1f140f90cb99176e969736758d50cbdc36c5a4b135b08cb74c117dd92c29bcbb41b1a28189af9180604b8ba) # deprecated
set(QT_HASH_qt5-scxml               893c3b247578c330db9b828e28e4df83b0e966bb469f1f453569e0226a8181b642c37f2198ff4194bec7997daee9578bebaaa7166bf1be8b67693edd0fbac082)
set(QT_HASH_qt5-sensors             ef0757125a6c5b89e206661d1d0e0674b673a81e1a0be1de9de2fdcd701fd507b0b47e1b67be013cbebbf846f593e37e4ef2941dcec4b78028019820d1fe7c3b)
set(QT_HASH_qt5-serialport          5d2e9742d1c5f784375b3d0bf05e227abf1f358f4ba60e66044378b60ac256dda2ab5ecced07c68ca8d93fe894617050821654200e1faa12f4cca112a4fbd2a4)
set(QT_HASH_qt5-speech              0e2c82ea72b5bff5b36f3d833d80dec68b39f3b9c3ca4d9c9fa29f0419a45dfb19ac59fb105136c551f6bbe60ad32af0f4aaa6abafb5bc61bc5d85ecb94b326f)
set(QT_HASH_qt5-svg                 c0289bbce4682eef9cd87811ad11a4ce2141cb89bd026f9cc595123e6b4ebbe9e81a91b54bcf25fbf4225bc66e8a5e4f49e4fabde43e9da066583f22aab4f35f)
set(QT_HASH_qt5-tools               8c7851431de8686a01fc5f85de5dcfa61b6878bd65b53ed78a8a23e57de70f2dcc1a72b4eed9a7219cfd443215a32a59a25fb929d343afcfd498517d6bcfb951)
set(QT_HASH_qt5-virtualkeyboard     f369eb0c313aa5a932cacca44f93732f8a7b8de4bf46df294c40b7c7dd436d5da5012680420306b57347aa38a10d78231199093a10e2b8a272429536a327962e)
set(QT_HASH_qt5-webchannel          01f37630ce7aa32726831b4a4d5e52e861269e33efd89246770e8a2a5536be976601d055c95f99d45699ea918ac4ce465b9ffab725f39841ddc5d320817c7523)
set(QT_HASH_qt5-websockets          5929f972b7e8aa40dbbd0a1157065bd11e81621cc880d1dfc55e4228800215d16cd301319a204413e7fee7ec57c4e5a70229ad2d3c1d3ac69f38bd39ce4b3713)
set(QT_HASH_qt5-webview             1da9cca184e66b02eef911e372d0f18466b989cc5c53d0a93e268857e1ca64a2f75bf20dfd1451060e6dbf4c7d248ba376112b7775e45ffa7d556712870478b1)
set(QT_HASH_qt5-winextras           67a7d8e8053516a1ce2e725a591533b9d195ee5868973458e2139dab91131900d921644a3dd1a44d1a5fdcbf474de85728de11f250bb9a5bfb40bf8eb94176b2)
set(QT_HASH_qt5-xmlpatterns         f76b2063f88a14754b1ba7e417b9a4936b1cf371bf35c6382a31f9ec01513894313faacb41a43fe6b97c0b0dbb7d4f578877b159ef1321cd1a2cd9b1d36bcdb3) # deprecated
##TODO
set(QT_HASH_qt5-doc                 2a1cf07ae648bf36f3127f1c4c3f0330a34b5183ec76431dfd20cf41ae3ce06e6cfead25e84f29059acce864d9328f1b8f8725aafcff9b0fe17e8245c1a7c7da)
set(QT_HASH_qt5-x11extras           59155fc97da3f7571da37dd63bed79f61580fa4df7d4886df51520ea6fe8e01e7c09f0aa9caaeaa986c0e5eac11d4479c99c892da4d075c6369b535fd505b084)
set(QT_HASH_qt5-androidextras       2da8a8e46c1d33926c0ee57061b1aef07182cb7c4b1bfed11b8032742a62d09a2a75d69741ba5ac26e11d5d544a415c84fb17255c14f1e1ae68d193f635200ea)
#set(QT_HASH_qt5-canvas3d            0) deprectaed
set(QT_HASH_qt5-translations        8e9fe7614c9aa9c557db1bfd6a0ceae90b45e5d28e0cd715fd4ad962b9fbfa722549d6c2a13d82deebd7d3fab7e68cc7affd207beb75629de0d01a5522035581)
set(QT_HASH_qt5-serialbus           cd7e0d721aa46a59239f44c6b0122509aba2237e0e62ea5399b4d4924601a9def989dd8b5d17fdcc46b41491d582d82b46c7efdfb9277ac1f06da7f1e2a1a859)
set(QT_HASH_qt5-webengine           651520fcf89681b06c57f1992223f06ecbe3750a88ffae7a94a339503957e09d327ee1ae7e4bce88bfb09131b3b9c9abfc44f7bccb9c50d286181eaf306991a4)
set(QT_HASH_qt5-webglplugin         e1feae14ba911f635ee5b45569e7f8dc8db4fdf1ca0d583f84d10de89976b7728285edbf050273293327c0f8afaf0fec8dff8370e1bf6771d47ae611be8a0224)
set(QT_HASH_qt5-wayland             d6619f35b3ab163372a0d49a2221c487d5936b6d9ebeb92a7fd41521c424d550eea7c5c584e07f15bde1ec5ece1bd5774845eb9956ce793e546197ffdb28d594)

if(QT_UPDATE_VERSION)
    message(STATUS "Running Qt in automatic version port update mode!")
    set(_VCPKG_INTERNAL_NO_HASH_CHECK 1)
    if("${PORT}" MATCHES "qt5-base")
        foreach(_current_qt_port ${QT_PORT_LIST})
            set(_current_control "${VCPKG_ROOT_DIR}/ports/qt5-${_current_qt_port}/CONTROL")
            file(READ ${_current_control} _control_contents)
            #message(STATUS "Before: \n${_control_contents}")
            string(REGEX REPLACE "Version:[^0-9]+[0-9]\.[0-9]+\.[0-9]+[^\n]*\n" "Version: ${QT_MAJOR_MINOR_VER}.${QT_PATCH_VER}\n" _control_contents "${_control_contents}")
            #message(STATUS "After: \n${_control_contents}")
            file(WRITE ${_current_control} "${_control_contents}")
        endforeach()
    endif()
endif()
#Every update requires an update of these hashes and the version within the control file of each of the 32 ports. 
#So it is probably better to have a central location for these hashes and let the ports update via a script
set(QT_MAJOR_MINOR_VER 5.15)
set(QT_PATCH_VER 2)
set(QT_UPDATE_VERSION 0) # Switch to update qt and not build qt. Creates a file cmake/qt_new_hashes.cmake in qt5-base with the new hashes.

set(QT_PORT_LIST base 3d activeqt charts connectivity datavis3d declarative gamepad graphicaleffects imageformats location macextras mqtt multimedia networkauth
                 purchasing quickcontrols quickcontrols2 remoteobjects script scxml sensors serialport speech svg tools virtualkeyboard webchannel websockets
                 webview winextras xmlpatterns doc x11extras androidextras translations serialbus webengine webglplugin wayland)

set(QT_HASH_qt5-base                a549bfaf867d746ff744ab224eb65ac1bdcdac7e8457dfa379941b2b225a90442fcfc1e1175b9afb1f169468f8130b7ab917c67be67156520a4bfb5c92d304f9)
set(QT_HASH_qt5-3d                  38da6886b887f6d315dcb17192322efe184950716fdd0030df6c7d7c454ea43dc0250a201285da27683ce29768da6be41d4168e4f63c20adb0b5f26ae0934c1b)
set(QT_HASH_qt5-activeqt            a2286a6736d14cf9b0dbf20af5ee8c23f94f57b6d4c0be41853e67109d87fd78dbf8f14eef2ce4b8d9ff2244af7ef139829ad7674d9ec9669434028961e65ec7)
set(QT_HASH_qt5-charts              d16fc085a7e98078cf616cde07d57c5f04cd41e9687a26d42edf9042b4c95a837371b6b9616e7176c536d742aa9b5fc15bf3393f9f2e814ce942189ac151e65f)
set(QT_HASH_qt5-connectivity        a934dcdd28645ba23dd429215643694d9a14449a4c3e1a6154a9a19cb3210f3d80978b46aefff2b110db533fa1816450f2f73a27d80df5330a92799e4cca1b9c)
set(QT_HASH_qt5-datavis3d           340b5ce1b1c2d8849b665e7bc84430fdf48e443fc149530ee132f325067f57d35594a23e3a8b920e1928ca5c429dcacfa098dadcbde63d4993f748c436af4cc3)
set(QT_HASH_qt5-declarative         a084e4ace0d6868668c95f1b62598a7dd0f455bfb0943ac8956802d7041436686f20c7ccdde7d6fd6c4b8173c936dd8600cf3b87bf8575f55514edfbb51111d3)
set(QT_HASH_qt5-gamepad             67f299d36f70ac3205a136117bec7f983f889b6a1f7d0ff97eb03925f4789d9d90a7197f5e186a6d04aa486880c60f0f623ab56a8bd78e4682e84c7ff6cc9fe1)
set(QT_HASH_qt5-graphicaleffects    1620a4daa6f2afc13b84752fa92f6d603aea1f7c796a239691b271a455d6887bba87a9a07edbfe008045f051c3e71fc6e22fc337d146c1793e923cfeb20e897d)
set(QT_HASH_qt5-imageformats        3c821fac83b8d6177af256dc1d68aca14ae6d5cbdedb8d8665158ebcec0f6e6fb790b5d210a1aa8b0679ecff60fafd4e5d1387c6954498b41409ea44177e0d7e)
set(QT_HASH_qt5-location            6192922506b3ea354e85431df83c19d7cc9aebb17549c6a1de48f625bf8365ff3db3161080dde254a5fb9199d99c3c5dc8e1533429150be55df96ddb7d6ce16f)
set(QT_HASH_qt5-macextras           21e807a587da716615a447207abda2c3eb409111a0eb6f844c8f1281ccc842a7c2e8759c1d7ce62cc3bad3325b4570a0bae1fbe4e5592e905788dde8898c6cb0)
set(QT_HASH_qt5-mqtt                91efd3b1ebef3c95473c018bcacd0772e613b38c) # Git commit ID
set(QT_HASH_qt5-multimedia          be58e6934976b04707399f8525dd5d50f73e0539efd1a76c2f9868e35e6f136e0991652df5d46350a9ac39d24313353e4aa826131f268a95e458e57279f448bd)
set(QT_HASH_qt5-networkauth         94843a74ae188eb0eff9559be6b246f61f87104479f6f52fe943b31a9263461a7051d967072d9061124b2bd056d7265645892104653c93dfcf68b11521f1c33d)
set(QT_HASH_qt5-purchasing          1a40fd3ca149f9c8fc98a45562b37fc97c7addc513d40f50997576648d441d379179370c6491a003982feafe96736047a8faf09caf36eaeea5a97553f75d1255)
set(QT_HASH_qt5-quickcontrols       52839e7442f4b6b5cbbb741d29ce28e9d2d9f5573499363d17252b166c1f318f37a19ecf1bf17f5cf6940bc29cc2987180b740ce036d924ff329dee9c37823a2) # deprecated
set(QT_HASH_qt5-quickcontrols2      5af506fd5842c505ae5fbd04fdd2a467c5b6a9547b4cea80c9cf051e9dea49bbf17843d8bc12e69e95810e70119c2843c24171c84e0f5df62dd2f59a39903c8f)
set(QT_HASH_qt5-remoteobjects       1cce1b6128f283fe8930e1e58b9620459c50b203a39607e9bcde8423930da08e5c70e7effaf64d2690f463cc7b37cfc67fb6c0ac89e27df3a57007aee1d5233d)
set(QT_HASH_qt5-script              71c70b34f7d4a0742df64d20d7e9a685cc640b9cc6a3d22847c04f45a437b3f5537f40225a522ed82787c2744d9a4949dea5b43c2ee81961d5ed175cf10deb32) # deprecated
set(QT_HASH_qt5-scxml               2a4719af94baefe7f0ca5a23239d07a05285a1698b052d17bb87bc221bbbc8bc25a70ff06d70d41ed7ac6a7e6646be9c516d8187c9098da1158c08e27a4b0bb8)
set(QT_HASH_qt5-sensors             d0a34e0718cc727b1256601bc5f9a2975532d728fdf0cb7678824c7d36aa5049d9c2886053821ec93a238120441c980027306ac633677617867c7aee40bb560b)
set(QT_HASH_qt5-serialport          353cc5f708367d646bd312f7d675b417bad4df44356f1dfc8b6ce846a86fd6d5955ec4d26f943e50f4a7b94cc6389fe658959e90bbb5ab3cdaefed0efe6ae72b)
set(QT_HASH_qt5-speech              78a13218a639276c9b253566a1df52e2363847eac76df3962ba2a7178800206beb57859d22c7c99fa1579cb3aa7ab94baed1a6319ba946d4a64cba9e3bf52b05)
set(QT_HASH_qt5-svg                 101e9c8fc05b1bb9c4e869564bff8e5723dd35f0ef557185e56e9dc12fdce74c531522c9642cdff639900eccf7ed0e04bfa48142741259697dded990fb481730)
set(QT_HASH_qt5-tools               3bd32a302af6e81cd5d4eb07d60c5ef233f1ca7af1aae180c933ac28fafffce28c6c868eb032108747937ea951d6d4f0df5516841bc65d22c529207147533a8b)
set(QT_HASH_qt5-virtualkeyboard     3ba04d171756a5434424833c5198a23e0df53eeebe9ea542047e094f83f38492d93f901cac67cf7e55aca6a71289ce3c6f5d8ac10a8d051b291155ebb8432016)
set(QT_HASH_qt5-webchannel          7ac5e372695616863d247c5a61e5763a3934b58165e35c43da5ef1797d80005aa3d6eb258931ae7ee2b1f6a6fa743635ac4678c9cfe375cefa76e74cc81d095b)
set(QT_HASH_qt5-websockets          1b23b79bff4289e785daf51441daaecf6de66ca5a3febfdd8fdb8ce871471bca4faf7663d68b23aaf562b1ebd6e9c8c27b3074f4b93bc9fcd3a0c54f7f79a9c4)
set(QT_HASH_qt5-webview             11502597d5e3a9b8a3a90025b56c086a3412743019384558617c397a8ad4a0f646b406a4fbeb31ca45e6e573d1fb06cd5b22b8c0179695d06cc3d492289a1c85)
set(QT_HASH_qt5-winextras           6555a42d4bbeb46b394f573b6ed7926ec21cf6024de3c5f43000373bf0a2f4544f19866e2c9469da2d60b5dd99fb046765be5d3f8d5025169e319795bbf66d9e)
set(QT_HASH_qt5-xmlpatterns         5cdf51878f8bb42db57110acc0c3985a95af098da44e5dda505e0716fef5afc780419058158f7a8f9a0fe3fed83fd64abd856b4dbcdca20efa5e985fa85cc348) # deprecated
##TODO
set(QT_HASH_qt5-doc                 ce2c003b37829da102f243ca271548cff0597b4b667109ca9533971a490b8b20eb3183af6e0b209ad58964f2be2e757f83933a3f8c484dd0814750e24d1a244e)
set(QT_HASH_qt5-x11extras           beaefc865299f4e7c637baa96eb3a69adbe1a41fc7735b46cfec0768c9243391600e69078630fffb4aceba106b7512fd802e745abc38ddab5253233301c93ed9)
set(QT_HASH_qt5-androidextras       cacd9252f313595d21eb6a94ffabbd5fff476af82aa619b4edfc77a9f405f52bd1b89da97c8f7dadf8c403035a243205a25a2f85250ebc0590bf68f914cdbf3a)
#set(QT_HASH_qt5-canvas3d            0) deprecated
set(QT_HASH_qt5-translations        483b5d919f43c96a032e610cf6316989e7b859ab177cb2f7cb9bb10ebcddf8c9be8e04ff12db38a317c618d13f88455a4d434c7a1133f453882da4e026dd8cbe)
set(QT_HASH_qt5-serialbus           c4793f5425ca0191435d75a8fd95a623cc847d41b8722421c0bf0fdfddda1a158fd2a00f5d997f00de4fcb271a158f3273d636ef2553ccd6b90b4d072b1eb55b)
set(QT_HASH_qt5-webengine           de64c30819f5e2f8620c853ff22b2f9717641477aef4432a552a72d1d67ed62ed61572afee6de3f2c9f32dee28f4f786ffd63fc465aa42c0ae1e87ea28341756)
set(QT_HASH_qt5-webglplugin         14b9a0c08472121165eba82f3c81518be7b19484b7bee7887df9751edc6e2e7e76d06f961b180427014beb71c725d343e9f196f37690e2d207511f7639bd2627)
set(QT_HASH_qt5-wayland             e8657ed676873da7b949e6a1605d025918a03336af9c68f32741945ec3c71a604def55bb00737ba4d97b91c00d0e2df1a83cdcedcf5795c6b2a1ef2caa21c91c)

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
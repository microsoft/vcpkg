vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chalk/ansi-regex
    REF v5.0.1
    SHA512 6ae31e12507c63a93b07b1fb3fd9921a63663691abec7b468c2e3138a022569b85e6685236e356c6ad5422391dc3b293f40528afb2847534d69ff0d6ebdf6240
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "ansi-regex")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chalk/ansi-styles
    REF v4.3.0
    SHA512 dc2bfa2e35437946ddbb326c4d43bdfb7b4e077d6912bc60aa0739bea1e5ad0c87fc28713ad0ff1d50ebf030ed60792262f0bbaaa9ab47f0df72ad8aa8fbc8d9
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "ansi-styles")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iarna/aproba
    REF v2.0.0
    SHA512 a6a73a944828ce6314fd7e51d2c53359daccc50c2162ebc8a7a27204837a3650e6e5073a009a5ea1fb8e0a287f0fd504f2b510624fd061b5f9d3f18efd3354cd
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "aproba")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO npm/are-we-there-yet
    REF v3.0.1
    SHA512 770c716504eed333992c7b27b111d87753123db6d55d10b6e137c94ed0ebeedf50715c28312b761f1861cf518854973c6ba32257a332210a2b974aa7ae0f9f90
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "are-we-there-yet")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alexindigo/asynckit
    REF v0.4.0
    SHA512 03d21407c58b9e1a2e7c76c8edc4bb4843b349fd5551c3823cb2b63488144516fb1b3b78deae10d91def1d6d47233eb9fa9afdd2820a5c4ad4e434e615e6d3b5
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "asynckit")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO axios/axios
    REF v0.27.2
    SHA512 c2050dec961838f27357daf37ac0563be64e70b173053fc4bf64a2a9a14a3e84e9a7705f202c5f1ec4e18eeaae714959f3ee6f73bdba2596d08d90398ffd4666
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "axios")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isaacs/chownr
    REF v2.0.0
    SHA512 bb2fefee0a4481db1084cca4f2fbd4ac1d39fa713b0104e211673bba6cf7793b21c11681901da1d3ea4f17c76db684ea76ce089e9ecaa9ece445eb7140aa8349
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "chownr")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yargs/cliui
    REF v8.0.1
    SHA512 aa8fc0ab362cd2d265185fceca9c2b41b0c1d612d2fd386ef2c3e4ccf51aaf4a7e698a4ea58ecfe71f916f82f3b6a5317096bb7def149e6178eda1efc987db22
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "cliui")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmake-js/cmake-js
    REF v7.0.0
    SHA512 8fc38282e0a5dd6c02441130a16adef267a3f40eb2d70855befaa14f57d0fb1fd56ed5cd3a5057ea3350c0724986837ac7374a7f6786f75c55b638e34e9d48c9
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "cmake-js")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Qix-/color-convert
    REF 2.0.1
    SHA512 e97f2c78384a60bac6c58484bcdb0143318c5479a66c5a1976379a98700d0e7486c0bc102cb7e5700f2a11fc5f07496e129c154aa29174273fd08d8ce398a23f
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "color-convert")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO colorjs/color-name
    REF v1.1.4
    SHA512 269fdeb1e4104781edec3551871d17ec70c6d61d82f70f70e5553be9e471da1bdb7233f03c6bac6eb8556cf0bfa4cddf6a23f2138a5d019f3684c796c6ceb095
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "color-name")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isaacs/color-support
    REF v1.1.3
    SHA512 c3c5d35baa3adb9614d925facf540e42fcc4b1064ce3d78a3eeaef027ff182d8b583b302575c6b335ee091a3f422f7e194dae24595e57f95db3a91e32985ab00
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "color-support")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO felixge/node-combined-stream
    REF v1.0.8
    SHA512 918c9ac9f6c685e91982f571cf01338e6291a6fceba17b32ba641a6fe674aa28ead5a2faf4e73ada0f1fd0c57e321da99f1d89d2e3866e02bcea4fd9c3f96798
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "combined-stream")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iarna/console-control-strings
    REF b678af0f5584fc91d52778b57c985a21c1605b04
    SHA512 26ba18db7558c329ac6951dcb97b44a92eb6abc81d7974dcf14b2a1f4a924c7bcb6a160d25ed31b7897a7828345d4a99a93ffb093f57f8b2d25ff24a272eee1c
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "console-control-strings")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO debug-js/debug
    REF 4.3.4
    SHA512 10599e237b62ca218917a062a7f0e64d7045f1bccfd87eee9042c49e8ae6d0c9960570abc67b37f37a9b4db11eee2fdc76d358835f24cc1116df6becace8339b
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "debug")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unclechu/node-deep-extend
    REF v0.6.0
    SHA512 9ec7019b2da2f2e59564dafbda07fd71aaaa624c66672a65570d0889214b48b1d06548331c4dfdcba398b92481de73a5be013608f7bb2e2a621a990dc06f06a5
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "deep-extend")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO felixge/node-delayed-stream
    REF 1.0.0
    SHA512 a0a15b24c435c3bc126112ffb11d4be303f650c3c63c41f9202188b519d6bb402ed797b6864a52fdc4db576ba3ac55b4fdcd415fc779c6db34663eee5920f424
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "delayed-stream")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO visionmedia/node-delegates
    REF 1.0.0
    SHA512 27f7bcb1dc25331f201b05035045bf70e0baa94651559392a4e15054c5f551a7242766039be5089146061954e1917f1e430977750f91d1d5d85007dc61348ec7
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "delegates")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mathiasbynens/emoji-regex
    REF v8.0.0
    SHA512 acd3b5d278de03aae3eb9a73fa3437152df77ef46befe969ac34cf6a2c51340921c8f4215ba733d4b54bd1dac2b7e0a3fd354d991a5bfd1b0783da864cc01765
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "emoji-regex")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lukeed/escalade
    REF v3.1.1
    SHA512 b17dba20bec8a7335d50be688c13fa5a910979856fe6bb6cca6435b284f693bfedc6f965f18ef7251e40f0fb7f38b2feea731315a1e56ce72768c5405a6a29ee
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "escalade")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO follow-redirects/follow-redirects
    REF v1.15.2
    SHA512 b40e8abffe6864a61d972b46e99e5b6b864a00cac7ad334648bb041b80e17d135314570a94ab6b5b4de4e775a3711c46e048860b806e03eea83d7f89cf1194c0
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "follow-redirects")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO form-data/form-data
    REF v4.0.0
    SHA512 a1ab8214926f1e0e5aeaa7eb253451776b0aad298a5a398ac2ee21e32b6b519256c35755e23b9d66dca3c3989ac4e47d6a9305780f60da402bff21dd0b39afd4
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "form-data")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jprichardson/node-fs-extra
    REF 10.1.0
    SHA512 88eff9198c47801d7e111c194596b2b44e3f42f73d39453f4393ff1d42a02b6f47a5d4c904141ac9efd9c24094ce342e9957b928714de7bfb9186bd1373421d6
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "fs-extra")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO npm/fs-minipass
    REF v2.1.0
    SHA512 a3c18244a6996fc9e9d3fc8a7212babf035795a2b27f1d4428f62b508bfe642e1960baec52566801a6546f139f6d3eab61451eb12076e0aae483df710927d20d
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "fs-minipass")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO npm/gauge
    REF v4.0.4
    SHA512 883c7aab1c1f332149d5a5facf49ccb2ab20fa83abc22011358c5f4de1d33b3bd6eccf3f97e74c2ddf85a3cd63e42f226113bd1a8009fb9ca56254d3f028671f
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "gauge")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stefanpenner/get-caller-file
    REF v2.0.5
    SHA512 40d0fb307cc1e285955dbe41ab8c8a4a2585c10870e12b2f221690a78f6bd54b3374da6048acef0af919734fa26dcf15786e10779496971b0f26f940353769ed
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "get-caller-file")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isaacs/node-graceful-fs
    REF v4.2.10
    SHA512 8e261bee2be4eb9b32cf2e25c8512593e3686696093e9b28e2740d2d9ef97406091d60f9de403d0317d3e914e40041c6265c0ed67ec521e518dccb5e25c161f4
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "graceful-fs")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iarna/has-unicode
    REF v2.0.1
    SHA512 10ca02b64710bda66d852a66d6ad3468b5fb422310c73819fc293d2a56f725c1f0899d55d11ce874929f5a9c8f6b83f767029ca9e086124e40239c67f24fd110
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "has-unicode")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isaacs/inherits
    REF v2.0.4
    SHA512 3c3cd7666f9f60d01c2e07d5ba19852787334126b7bfcd6e9aa6beef52d18e3838fb8423c44599d582eb38d836e427f8ccb2d61a0b8615ae799ffa2ae2ee7c76
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "inherits")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isaacs/ini
    REF v1.3.8
    SHA512 ce29fbce3784de06cdec570d9a98d126da3bb408f2e187582b2dda6a92c1de434934d1272f9d75fa1f360e3be7b9c3a7bb117e20f27a8934fee48e5a9838eb1e
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "ini")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sindresorhus/is-fullwidth-code-point
    REF v3.0.0
    SHA512 46160958ced3c27fa0b96c4dcdaa4cf51116cf8ea618ec8e072f2398a693961b38df796b16cba359119099827226b959135b49ea02d8c2c4cb64d433d942e411
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "is-fullwidth-code-point")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isaacs/isexe
    REF v2.0.0
    SHA512 f158d27b1ad72f4b01fe2b8a22dc4295d0c65303ce2590652e016606dd30b6e0643374afa08372b0e4ff7c22fd33198ede7179e981229bfc3fa0045e99570a15
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "isexe")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jprichardson/node-jsonfile
    REF 6.1.0
    SHA512 5194f180cefa87168418977a8c5faaeb7f84cf8a11dc5321f2158494e4c1fef8bce2655a9bf37492d1a482f165888aa5c04e9e7c98582d4c960a3def7e9cf048
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "jsonfile")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isaacs/node-lru-cache
    REF v6.0.0
    SHA512 9fd0b36058aadec81c84e473edf2238599b882bdab626f5f88ac2497dbc2c4aa0e93600a4b28b1ec8907147dc3d8c717e3fce6970f1fbee217065ef8cc66b959
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "lru-cache")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO doanythingfordethklok/memory-stream
    REF v1.0.0
    SHA512 a158321ddd80c72ec9459f5735ec9c22274d64fd641c25d9717dccbbc8fc8c1bd18c40dd20b4c9722192927a2095dfb1268d7f3fbc16b0ef49832777318fa04c
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "memory-stream")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jshttp/mime-db
    REF v1.52.0
    SHA512 a3832fd5a5c323a55b4ac74ac90b80c571b36c48c912eada89668b53b4e5ea51c9262a34db03c6bf51ed4ef8a2d5744cc3a7d79520a9faf4a8f20e31244070e3
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "mime-db")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jshttp/mime-types
    REF 2.1.35
    SHA512 d0ef98b7b2cbf0dd5fef1c41eff9cb1fdc4421852af3caaa82d0057c30baa9c2e7898ceb6cfd9ec058ff6b881cb4257ae3e6f13c0a94c0bc6d53dfd177a73b14
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "mime-types")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO minimistjs/minimist
    REF v1.2.7
    SHA512 04f11b0d1f45d4556763dea2232fbc24a2bf114d779c64010a9080f7471170643862bbf302f324a5b9b016379caf414406148c2ea1c4fa595956125ce7c43b10
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "minimist")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isaacs/minipass
    REF v3.3.4
    SHA512 01d010ca2374bdfce2e4e8162997d47f72a3f41e17c701e256ece9e8b48685a00431217ee1f49dde8413ab49215f3ead67d256075aff0dd42ab367542b966202
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "minipass")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isaacs/minizlib
    REF v2.1.2
    SHA512 1c4ea90c62fb3b2631c64f56037a84b32a9bb54d52f68dd5110ba56755ac5d129a930b8ec030b89538cd1f4cbc9705d88a66bd1a00086f0c1d6efbfbe55e5d8b
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "minizlib")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isaacs/node-mkdirp
    REF v1.0.4
    SHA512 236203c95283dbe333d74e9522cde5af2c0c49fef207d23a80ef8b83f00c57ecb0a67bcc06c57f164e3d147293d7741df896d41d90f01a88bfb559d3dcbbff4c
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "mkdirp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vercel/ms
    REF 2.1.2
    SHA512 7f11f4655dfa93f11a9d29312539fa8faa0d9fe7dec2a7c69f450bb4fa9f31332dc1db0109b42378b2b790771eb18b08094b8a3118353ec0ff2ccf3305e897bb
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "ms")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nodejs/node-api-headers
    REF v0.0.1
    SHA512 be66eaee77f1c1cc5a0767fa2e91e9c1e4ea7c9a1c956fe8052fbf795fe6a6dfd265452a6e212eefdbcf1dcc20497ebb81bd6de5a236203556e5349938c95df1
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "node-api-headers")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO npm/npmlog
    REF v6.0.2
    SHA512 1d6d4accacc9166a90bd43d8aeabbc37d62981c31cc1838c1d5b039ecfe30e80275e52428e929937d574bb4c3fb2e2622c6a2762c29f708721b4ac7ccb531b49
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "npmlog")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dominictarr/rc
    REF a97f6adcc37ee1cad06ab7dc9b0bd842bbc5c664
    SHA512 85178d56bd0f9632d35f935535ebce7070f49c1c7efb3d0fd69033a3cfd271ab073b15bab9ed5e51fc8582a7986c430b4829d6d162d3febd3212c12e2391d8f8
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "rc")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nodejs/readable-stream
    REF v3.6.0
    SHA512 47bbb90e2afeaed0833f29d4c2e3886463b055601ec46aa1da6038651d566a00ddb0fe171198a71f97c3ea5de1336cc4d8320511c32bb7be6476ead1a4a4f0ae
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "readable-stream")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO troygoode/node-require-directory
    REF d1fd7dc2eaf02832de94dbe1af0c52271697050e
    SHA512 0fffb381b37a22476d23a2f2bd1b54c1d8bd7fb01e6d1aba3aeb5ddf33c0e95f1d01da9f2aecbe71025fec73f967d7a8b6c191208f419ec3050d5d3d2381a9da
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "require-directory")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO feross/safe-buffer
    REF v5.2.1
    SHA512 3e7204ffb782f413991b6f305b71bfe57399c9ed941dd665ced0c6dfd251f96bf996d926676b092ff6d7eb5947b249449f0eaab2adcd43f6625f981c2d4d0a56
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "safe-buffer")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO npm/node-semver
    REF v7.3.8
    SHA512 8c3101f5750755a4d7ff89fcaad5fa9545725e067df7881f708352b5d53eb2823213593ad223b402b5a4747a3bd1064f1b440165a29e71b74db21a34b1113899
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "semver")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yargs/set-blocking
    REF v2.0.0
    SHA512 a6d2bccf649a7a50c758286fc718beeed9b9b930b6bdbd3c35b9a260ffa528197e71f51b0a8be1a52e493e43745c457c221d7a88b807d33f848d8397fd740087
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "set-blocking")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tapjs/signal-exit
    REF v3.0.7
    SHA512 772705b0b9ee2579034981c989169332be4bd5d9cc7f3cbd25ac27a014063b4316b773eae229425d5326e6f319c17121cc4845c80c601fdeaab53ddab918816f
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "signal-exit")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sindresorhus/string-width
    REF v4.2.3
    SHA512 d86ce7e816b726584a90ff0d9cc75fa0b7d9e3df151926d13d4e2a6d664e3d0a6fd7778275960c6bf72efff9aad5bac3bf00bdc5a38a12b89fcfa63ca829a768
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "string-width")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nodejs/string_decoder
    REF v1.3.0
    SHA512 07906e0673dd5e1e2c10bd2f6c0e0eba8d8f774155793fee23af1550a037a6f128a7cb56a8b4d256d6bd678e19964eb108df79751c3366fa453d7f8285053db2
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "string_decoder")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chalk/strip-ansi
    REF v6.0.1
    SHA512 c4fb7143dd3f51e83bfa210d4bff75976ccd640ca38954ed832c85defa98e215e992faf4db25aa4243b3ba227cf4443959c13e9d1b8e6c04d5b815d34f6eb76c
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "strip-ansi")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sindresorhus/strip-json-comments
    REF v2.0.1
    SHA512 9dde39cc0f69cf744c625741cf57e9b4cdd7c925eec16efd8f8709540d7063471ce2166683aa523f2247112326a117c789b10ac23a9f90399023cbb28e5af883
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "strip-json-comments")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO npm/node-tar
    REF v6.1.11
    SHA512 addc05132e913b5777bb9052ee01773f1d1c6eb19f77026c2eeeb881829566e50aae205b1770ff9b88b41863bcb7c866526119ca2ea8640b0d3667e724e34b9a
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "tar")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RyanZim/universalify
    REF 2.0.0
    SHA512 bbc6b9ab89ef4e32e7a8df58c8941328379913fc0ec54413c5a45f0281245e4f6c7db530a8a1a4c90fd171fecbed7d123a6972847cfde290d1b9556f118f0846
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "universalify")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfromaniello/url-join
    REF v4.0.1
    SHA512 d1d9f15e9624362b719980d5997880848649a06ec4cdba36dbd728fd48a64e934a1eb1ac412fef59ebac89732969bbcaca1bfc23b60ff3fd257f7df4cfa1b6ec
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "url-join")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TooTallNate/util-deprecate
    REF 1.0.2
    SHA512 999658328c63a4ae965d3f6f580b2bcca96dc725b1feb70f0e8d4350abf78c9752f55c4b9e24e093ab7533d50bd1541eea52b45a227ec40ed4e70576851ad56d
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "util-deprecate")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isaacs/node-which
    REF v2.0.2
    SHA512 69ea43103fffaf1e732bb8214a9d7d36e32a60b6af4be85e02231350bc028ab3a0a8a410e61b191e98363a8dffc9d1772c605d814bee050659a77b3347659bd6
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "which")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO iarna/wide-align
    REF c1bf09df8a2c549d68a7a0e65315db89d0eff457
    SHA512 c49e0b60500f6898a3847590ad7c9c32f95c0793de9845a12dd1c40b0e7ae23b2380b1f822f63adaf746ee46b05a469d22ec866901ade9772c88a47bfe80493e
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "wide-align")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chalk/wrap-ansi
    REF v7.0.0
    SHA512 3ada9124c8f16ec8a47e82a46b582f23c3a2e0dd0d39174fcb420b441bcf049dd5ff70e9d27cb8fc1f109ede30d0bc90b4b9b3a6e0defab94f2fce3e013338bb
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "wrap-ansi")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yargs/y18n
    REF v5.0.8
    SHA512 0e54537f7ecf74bbf34cd9fc68376bcad4f30e268acde57a499f137fb4532ccbd165b005ea4b0d11e64fdb1959c3e1f0bac76f4aea17cc6807ad3b980508376d
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "y18n")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO isaacs/yallist
    REF v4.0.0
    SHA512 204189d2176cd569d1d7902c8bcfda5f7d5591d658693e0ccd794b05ce82691610f8d32d7a76e0a4148d9ed155cc98b9dddd5ce089b48d9d74799797efb79b0f
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "yallist")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yargs/yargs
    REF v17.6.0
    SHA512 8d32dc77453a9951eeba7142dfa5a569e0d7a03fe9f2dd5853b78feb02a3446182396fb210364afc99efdf14fbaa124365a2ef5f92149329aa6a2e647b805027
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "yargs")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yargs/yargs-parser
    REF yargs-parser-v21.1.1
    SHA512 d187e49dcb781953165232982f4dad4bf6faabd6185c0d2d32fff641cd4e9332a1eefafaa1e9c022e8fb3eb13e9e4222fba5624875b3721c018766982659d925
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "yargs-parser")


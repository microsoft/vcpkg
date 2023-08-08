vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ZLMediaKit/ZLMediaKit
    REF 383da1e09ea78c24f380ffce8b7695ceec315c24
    SHA512 f5ac5bf1e3629c67a9487fe082baaabeeb06532eac9777dcc02c362dc0632d5e2594400f6b9a6dd5cbdace614db5fb39f2cab3d86ce0ea066f0d2e09c56c300d
    HEAD_REF master
    PATCHES fix-dependency.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH TOOL_KIT_SOURCE_PATH
    REPO ZLMediaKit/ZLToolKit
    REF d2016522a0e4b1d8df51a78b7415fe148f7245ca
    SHA512 350730903fb24ce8e22710adea7af67dc1f74d157ae17b9f2e5fabd1c5aced8f45de0abce985130f5013871a3e31f9eaf78b161f734c16a9966da5b876a90e1b
    HEAD_REF master
)

file(REMOVE_RECURSE "${SOURCE_PATH}/3rdpart/ZLToolKit")
file(COPY "${TOOL_KIT_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/3rdpart/ZLToolKit")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" static ZLMEDIAKIT_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" static ZLMEDIAKIT_CRT_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl ENABLE_OPENSSL
        x264    ENABLE_X264
        #mysql   ENABLE_MYSQL
    INVERTED_FEATURES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_API=ON
        -DENABLE_API_STATIC_LIB=${ZLMEDIAKIT_BUILD_STATIC}
        -DENABLE_MSVC_MT=${ZLMEDIAKIT_CRT_STATIC}
        -DENABLE_ASAN=OFF
        -DENABLE_CXX_API=OFF
        -DENABLE_JEMALLOC_STATIC=OFF
        -DENABLE_FAAC=OFF
        -DENABLE_FFMPEG=OFF
        -DENABLE_MYSQL=OFF
        -DENABLE_PLAYER=ON
        -DENABLE_SERVER=ON
        -DENABLE_SERVER_LIB=OFF
        -DENABLE_SRT=ON
        -DENABLE_SCTP=ON
        -DENABLE_WEBRTC=OFF
        -DENABLE_WEPOLL=ON
        # needs dependency libmov
        -DENABLE_MP4=OFF
        -DENABLE_HLS_FMP4=OFF
        # needs dependency libmpeg
        -DENABLE_RTPPROXY=OFF
        -DENABLE_HLS=OFF

        -DDISABLE_REPORT=OFF
        -DUSE_SOLUTION_FOLDERS=ON
        -DENABLE_TESTS=OFF
        ${FEATURE_OPTIONS}
    OPTIONS_RELEASE
        -DENABLE_MEM_DEBUG=OFF
    OPTIONS_DEBUG
        -DENABLE_MEM_DEBUG=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
    
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

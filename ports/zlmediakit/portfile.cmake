vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ZLMediaKit/ZLMediaKit
    REF 2e05119df12ba0721a2b7061dba55187569d891b
    SHA512 8b72af231ff2080b7472284e0c89977c8d6c9c32ec35cbb4fe3700f58543c3b831722b58f39288ef44b274c61f746869f530eaccddfa0e8b242df11f729c3ba1
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

if ("mp4" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH MEDIA_SRV_SOURCE_PATH
        REPO ireader/media-server
        REF cdbb3d6b9ea254f454c6e466c5962af5ace01199
        SHA512 c9b6ed487ec283572022fe6eb8562258063a84b513ccc3f8783e4da9f46b19705ce41baf9603277a7642683e24ac4168a11a0c4e7a18b5f56145bf4986064664
        HEAD_REF master
    )

    file(REMOVE_RECURSE "${SOURCE_PATH}/3rdpart/media-server")
    file(COPY "${MEDIA_SRV_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/3rdpart/media-server")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" static ZLMEDIAKIT_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" static ZLMEDIAKIT_CRT_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl ENABLE_OPENSSL
        mp4     ENABLE_MP4
        mp4     ENABLE_HLS_FMP4
        mp4     ENABLE_RTPPROXY
        mp4     ENABLE_HLS
        sctp    ENABLE_SCTP
        webrtc  ENABLE_WEBRTC
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
        -DENABLE_PLAYER=OFF
        -DENABLE_SERVER=ON
        -DENABLE_SERVER_LIB=OFF
        -DENABLE_SRT=ON
        -DENABLE_MYSQL=OFF
        -DENABLE_X264=OFF
        -DENABLE_WEPOLL=ON
        -DDISABLE_REPORT=OFF
        -DUSE_SOLUTION_FOLDERS=ON
        -DENABLE_TESTS=OFF
        -DENABLE_MEM_DEBUG=OFF # only valid on Linux
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES MediaServer AUTO_CLEAN)
    
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ZLMediaKit/ZLMediaKit
    REF 6b2fcf79435656be7797d396203adcc6c11ecc52
    SHA512 a2efe81f7fe6267418cc1e98f74283a10481b995815131324b7587c82f451d4bd35aa0190ef59efe46a057369208d4bf0658eaba44ae1a8532c6162cfb6e34f5
    HEAD_REF master
    PATCHES 
        fix-dependency.patch
        fix-android.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH TOOL_KIT_SOURCE_PATH
    REPO ZLMediaKit/ZLToolKit
    REF 46231014e2a7ec1903d4a37e96222481ecc779d8
    SHA512 2a0b834f072fbc64edc84f408050e2c992f8d59f2480c67a372cace17d49f21eb2f40587288481acc42118e94a5b7863043982680c3f56bdde3863f97ca69356
    HEAD_REF master
    PATCHES
        add-include-chrono.patch #https://github.com/ZLMediaKit/ZLToolKit/pull/258
)

file(REMOVE_RECURSE "${SOURCE_PATH}/3rdpart/ZLToolKit")
file(COPY "${TOOL_KIT_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/3rdpart/ZLToolKit")

if ("mp4" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH MEDIA_SRV_SOURCE_PATH
        REPO ireader/media-server
        REF 4e1a89c3247db72076893d3fc5ad80f4b3c04ec2
        SHA512 baa7c8b69f86117e0eb8e3bb3769f3aa7fac498a7a59a24382a703a16ec8c5997e858b01a4681795ad0f8eab0408bf69fe1907400fa941dff588b1c739ffa324
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
        openssl CMAKE_REQUIRE_FIND_PACKAGE_OpenSSL
        mp4     ENABLE_MP4
        mp4     ENABLE_RTPPROXY
        mp4     ENABLE_HLS
        sctp    ENABLE_SCTP
        webrtc  ENABLE_WEBRTC
    INVERTED_FEATURES
        openssl CMAKE_DISABLE_FIND_PACKAGE_OpenSSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_POLICY_DEFAULT_CMP0057=NEW
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
        -DCMAKE_DISABLE_FIND_PACKAGE_GIT=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_JEMALLOC=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_SDL2=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES MediaServer AUTO_CLEAN)
    
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

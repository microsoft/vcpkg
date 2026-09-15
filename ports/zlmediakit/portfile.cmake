vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ZLMediaKit/ZLMediaKit
    REF fdaec2604d4091886158cbaca39dca2b5e5d25db
    SHA512 cb25d0775d3b3f8d0f6c998b4a9f301bbc9843f1da9ef0f4ee0fbb718ccb85765b0111effddd3c75d20dec9eeb1940d7ac6be24be19da267e8d901fd8afbac8a
    HEAD_REF master
    PATCHES 
        fix-dependency.patch
        fix-android.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH TOOL_KIT_SOURCE_PATH
    REPO ZLMediaKit/ZLToolKit
    REF b311fdef4c9aabb94d33579e0a3810e6db7810c2
    SHA512 4eda0fbac37224914983d0aa0f02a34e8d8175901631bd7546d75424ebe1bd14e93021fd03235cfe66d6efda8148ecf8a131851bb2c49a8423f9de695a79b313
    HEAD_REF master
)

file(REMOVE_RECURSE "${SOURCE_PATH}/3rdpart/ZLToolKit")
file(COPY "${TOOL_KIT_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/3rdpart/ZLToolKit")

if ("mp4" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH MEDIA_SRV_SOURCE_PATH
        REPO ireader/media-server
        REF 21c4451ff2e4c4bb1c817e606c8b4e5deac1e719
        SHA512 da0e9c7d69814faab0310ca7960e95d28a4f85a2fd787e56dfc474077df9fdd7475e9039c3786179e014e4974f932531c4496817258373c91a3f35952306441b
        HEAD_REF master
    )

    file(REMOVE_RECURSE "${SOURCE_PATH}/3rdpart/media-server")
    file(COPY "${MEDIA_SRV_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/3rdpart/media-server")
endif()

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
        -DENABLE_API_STATIC_LIB=ON
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
    
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

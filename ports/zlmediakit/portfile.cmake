vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ZLMediaKit/ZLMediaKit
    REF af3ef996b0ae265e000344e7faf753577f9abf4e
    SHA512 e45572a579d4644b4e48e70c999796d032947d64f074d7f143bd760238523d46ae061f079d9fe539a21542032f3c94ff7465fe2ba6c9fb39dbeac245dffd188b
    HEAD_REF master
    PATCHES 
        fix-dependency.patch
        fix-android-build.patch
        fix-core.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH TOOL_KIT_SOURCE_PATH
    REPO ZLMediaKit/ZLToolKit
    REF 04d1c47d2568f5ce1ff84260cefaf2754e514a5e
    SHA512 f467168507cb99f70f1c8f3db4742ecee8cfb3d9ac982b8dfee59907a6fbaf5ca6db4e0c60d8c293843f802a0489270d7a35daf17338f30d78c6b0e854b6ac17
    HEAD_REF master
)

file(REMOVE_RECURSE "${SOURCE_PATH}/3rdpart/ZLToolKit")
file(COPY "${TOOL_KIT_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/3rdpart/ZLToolKit")

if ("mp4" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH MEDIA_SRV_SOURCE_PATH
        REPO ireader/media-server
        REF 527c0f5117b489fda78fcd123d446370ddd9ec9a
        SHA512 d90788fea5bff79e951604a6b290042e36dae9295fe967c6bc72ec2b5db8159c4465dd3568fc116b6954f90185f845671a3b3e3c2d3ccca7aaf913391e69630c
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

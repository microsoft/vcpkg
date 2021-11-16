vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/GameNetworkingSockets
    REF 5c793b9f1a507aa9670c8634817bde48b744428b # v1.3.0
    SHA512 6ed8edbfe0b899a1e0aaba4cc7cae2e101fb292b18becb29b0da47c0894d603cad5c4b0983caddbcf269537a2022bd2cc965a19530615a0aa68406278e127525
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "webrtc"    USE_STEAMWEBRTC
)

vcpkg_from_git(
    OUT_SOURCE_PATH WEBRTC_SOURCE_PATH
    URL https://webrtc.googlesource.com/src
    REF 30a3e787948dd6cdd541773101d664b85eb332a6
    HEAD_REF MAIN
)

file(GLOB WEBRTC_SOURCE_FILES ${WEBRTC_SOURCE_PATH}/*)
foreach(SOURCE_FILE ${WEBRTC_SOURCE_FILES})
    file(COPY ${SOURCE_FILE} DESTINATION "${SOURCE_PATH}/src/external/webrtc/")
endforeach()

set(CRYPTO_BACKEND OpenSSL)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" MSVC_CRT_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DUSE_CRYPTO=${CRYPTO_BACKEND}
        -DUSE_CRYPTO25519=${CRYPTO_BACKEND}
        -DBUILD_STATIC_LIB=${BUILD_STATIC_LIB}
        -DBUILD_SHARED_LIB=${BUILD_SHARED_LIB}
        -DMSVC_CRT_STATIC=${MSVC_CRT_STATIC}
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        MSVC_CRT_STATIC
)

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/GameNetworkingSockets" TARGET_PATH "share/GameNetworkingSockets")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO machinezone/IXWebSocket
    REF 2149ac7ed60d7713a86446c4b93c6004f66415ac #v11.2.6
    SHA512 737667f6e89156168db771fd2a6d3686cd51ddc753fa083ae399a84c689770a09fd86643bb2d838e9ae5a729067236f1d9b4ceece912145cfb83b29541a3d2c1
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl   USE_OPEN_SSL
        mbedtls   USE_MBED_TLS
        sectransp USE_SECURE_TRANSPORT
)

if("sectransp" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_OSX)
    message(FATAL_ERROR "sectransp is not supported on non-Apple platforms")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
	${FEATURE_OPTIONS}
	-DUSE_TLS=1
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ixwebsocket)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

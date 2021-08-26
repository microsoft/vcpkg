vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(MESSAGE "${PORT} does not currently support UWP" ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO civetweb/civetweb
    REF 8e243456965c9be5212cb96519da69cd54550e3d # v1.13
    SHA512 6f9daf404975697c6b7a56cc71006aaf14442acf545e483d8a7b845f255d5e5d6e08194fe3350a667e0b737b6924c9d39b025b587af27e7f12cd7b64f314eb70
    HEAD_REF master
    PATCHES "add-option-to-disable-debug-tools.patch"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl CIVETWEB_ENABLE_SSL
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCIVETWEB_BUILD_TESTING=OFF
        -DCIVETWEB_ENABLE_DEBUG_TOOLS=OFF
        -DCIVETWEB_ENABLE_ASAN=OFF
        -DCIVETWEB_ENABLE_CXX=ON
        -DCIVETWEB_ENABLE_IPV6=ON
        -DCIVETWEB_ENABLE_SERVER_EXECUTABLE=OFF
        -DCIVETWEB_ENABLE_SSL_DYNAMIC_LOADING=OFF
        -DCIVETWEB_ENABLE_WEBSOCKETS=ON
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/civetweb)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()

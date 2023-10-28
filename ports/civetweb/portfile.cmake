vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO civetweb/civetweb
    REF "v${VERSION}"
    SHA512 a0b943dfc76d7fd47f5a7d2c834fd38ddd4cf01a11730cf2f7cfaf32fea9698f59672f3a0f86ac80e0abc315d94d2367a500d37013f305c87d45e84cf39ca816
    HEAD_REF master
    PATCHES
        disable_warnings.patch # cl will simply ignore the other invalid options. 
        fix-fseeko.patch
        pkgconfig.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/src/third_party")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl CIVETWEB_ENABLE_SSL
)

# Fixes arm64-windows build. CIVETWEB_ARCHITECTURE is used only for CPack, which is not used by vcpkg
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "determine_target_architecture(CIVETWEB_ARCHITECTURE)" "")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCIVETWEB_BUILD_TESTING=OFF
        -DCIVETWEB_ENABLE_DEBUG_TOOLS=OFF
        -DCIVETWEB_ENABLE_ASAN=OFF
        -DCIVETWEB_ENABLE_CXX=ON
        -DCIVETWEB_ENABLE_IPV6=ON
        -DCIVETWEB_ENABLE_SERVER_EXECUTABLE=OFF
        -DCIVETWEB_ENABLE_SSL_DYNAMIC_LOADING=OFF
        -DCIVETWEB_ENABLE_WEBSOCKETS=ON
        -DCIVETWEB_ALLOW_WARNINGS=ON
        "-DVERSION=${VERSION}"
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/civetweb)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/civetweb.h" "defined(CIVETWEB_DLL_IMPORTS)" 1)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/CivetServer.h" "defined(CIVETWEB_CXX_DLL_IMPORTS)" 1)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/pkgconfig")

file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

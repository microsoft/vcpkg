vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/GameNetworkingSockets
    REF "v${VERSION}"
    SHA512 b044010aad017804e1b16b5664431e56f59feb35284adaedfd35f518251e8d8abeb3a29d3d273dea57bde63af63b4b3dd54d2cb2712d28975373b54b640da611
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ice             ENABLE_ICE
)

# Select static vs dynamic based on the triplet.
if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "dynamic")
    set(BUILD_SHARED_LIB ON)
    set(BUILD_STATIC_LIB OFF)
else()
    set(BUILD_SHARED_LIB OFF)
    set(BUILD_STATIC_LIB ON)
endif()

# Link the MSVC CRT statically when the CRT linkage is static.
# Not used on non-MSVC platforms; listed in MAYBE_UNUSED_VARIABLES accordingly.
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" MSVC_CRT_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_CRYPTO=OpenSSL
        -DBUILD_STATIC_LIB=${BUILD_STATIC_LIB}
        -DBUILD_SHARED_LIB=${BUILD_SHARED_LIB}
        -DMSVC_CRT_STATIC=${MSVC_CRT_STATIC}
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TOOLS=OFF
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        MSVC_CRT_STATIC
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/GameNetworkingSockets")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

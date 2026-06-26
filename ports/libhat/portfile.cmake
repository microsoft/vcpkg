vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BasedInc/libhat
    REF "v${VERSION}"
    SHA512 250381ddedb927ef38fa17a7dadfabe746986e533282f311b6b5846de7ce695066b2ebaf188b3d8e53beb71b72ebfbb5f35087fd10e355afe45a5cb3bfcbebc3
    HEAD_REF master
    PATCHES
        0001-CMakeLists.patch
        0002-fix-gcc.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/libhat-config.cmake.in" DESTINATION "${SOURCE_PATH}")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic"   LIBHAT_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static"    LIBHAT_BUILD_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "hint"  LIBHAT_HINT_X86_64
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBHAT_DISABLE_AVX512=ON # For AVX512, author an overlay-port that removes this line
        -DLIBHAT_SHARED_C_LIB=${LIBHAT_BUILD_SHARED}
        -DLIBHAT_STATIC_C_LIB=${LIBHAT_BUILD_STATIC}
        -DLIBHAT_TESTING=OFF
        -DLIBHAT_TESTING_ASAN=OFF
        -DLIBHAT_TESTING_SDE=OFF
        -DLIBHAT_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

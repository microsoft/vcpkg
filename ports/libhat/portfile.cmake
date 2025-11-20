vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BasedInc/libhat
    REF "v${VERSION}"
    SHA512 68ce4d66f92553eb0f3e0f26c0274bc048d735936a68abf2fcb2ce7766dcdab73fb5dc0d8bbf249e5b36bd7a2eb2db06878eaffcd16d4bcac839953506704c8d
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

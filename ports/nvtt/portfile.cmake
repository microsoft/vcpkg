vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO castano/nvidia-texture-tools
    REF b1a90f36013522b9e5a3a2197859b72188752e3f  # 2.1.2
    SHA512 13cf04a9856f150f7569c8c256c42fc6a5bc40586c9ca2b3ae553edf5bfcbccbba5b8538924079ed35effdd07b9e3ef4bfdb9733a2ec51f5a95f958885cc6cca
    HEAD_REF master
    PATCHES
        001-define-value-for-HAVE_UNISTD_H-in-mac-os.patch
        bc6h.patch
        bc7.patch
        squish.patch
        fix-build-error.patch
        add-compile-options-for-osx.patch
        skip-building-libsquish.patch
        fix-intrinsic-function.patch
        fix-release-flags.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cuda    CMAKE_REQUIRE_FIND_PACKAGE_CUDA
    INVERTED_FEATURES
        cuda    CMAKE_DISABLE_FIND_PACKAGE_CUDA
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNVTT_SHARED=0
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=_d # required by OSG
)

vcpkg_cmake_install()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/doc/nvtt/LICENSE")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BIC-MNI/libminc
    REF e75a936c12a305b596d743c26a5437196ebce2a4
    SHA512 744f879ac8f0594c310d1c1b7fe67543c5feeb3e5a0979035918dbb2bf1d0973fbd389e5357a75631e618cc614b648c21179f7467576bd68e3522e63f21451b0
    HEAD_REF master
    PATCHES
        build.patch
        config.patch
        fix-dependency-hdf5.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "minc1" LIBMINC_MINC1_SUPPORT
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # Symbols are not properly exported
endif()

set(OPTIONS)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS "-DLIBMINC_BUILD_SHARED_LIBS=ON")
else()
    list(APPEND OPTIONS "-DLIBMINC_BUILD_SHARED_LIBS=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        "-DBUILD_TESTING=OFF"
        "-DLIBMINC_USE_SYSTEM_NIFTI=ON"
        ${OPTIONS}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake PACKAGE_NAME libminc)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

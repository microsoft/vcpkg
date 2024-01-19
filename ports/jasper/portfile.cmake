vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jasper-software/jasper
    REF "version-${VERSION}"
    SHA512 940841f4094987526ee23aed84f2b028b0f4d58cd2be91dcf737102018d8da111870959ad64710b14ae1ca4ca8361fc900ff6ecee31f0f23ef435bf7f0935462
    HEAD_REF master
    PATCHES
        no_stdc_check.patch
        fix-library-name.patch
        check-for-atomics-support.patch # https://github.com/jasper-software/jasper/pull/370
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(VCPKG_CXX_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_CXX_FLAGS}")
    set(VCPKG_C_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_C_FLAGS}")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" JAS_ENABLE_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        opengl    JAS_ENABLE_OPENGL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DJAS_ENABLE_LIBHEIF=OFF # found via find_library instead of find_package
        -DJAS_ENABLE_LIBJPEG=ON
        -DJAS_ENABLE_DOC=OFF
        -DJAS_ENABLE_LATEX=OFF
        -DJAS_ENABLE_PROGRAMS=OFF
        -DJAS_ENABLE_SHARED=${JAS_ENABLE_SHARED}
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=d # Due to CMakes FindJasper; Default for multi config generators.
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share")

vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE.txt)

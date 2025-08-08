vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jasper-software/jasper
    REF "version-${VERSION}"
    SHA512 57d33b988f92a0aa2b30af983280c2210f4ed9548dc8a38ed34fce76698489ed37d05b11b1aa92d9c4d0223deb306fbbb11900b696ba080926d4aaf2b62b2740
    HEAD_REF master
    PATCHES
        no_stdc_check.patch
        fix-library-name.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(VCPKG_CXX_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_CXX_FLAGS}")
    set(VCPKG_C_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_C_FLAGS}")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" JAS_ENABLE_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DJAS_ENABLE_LIBHEIF=OFF # found via find_library instead of find_package
        -DJAS_ENABLE_LIBJPEG=ON
        -DJAS_ENABLE_DOC=OFF
        -DJAS_ENABLE_LATEX=OFF
        -DJAS_ENABLE_OPENGL=OFF  # only used by programs, which are turned off
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

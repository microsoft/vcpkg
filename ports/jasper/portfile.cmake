vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jasper-software/jasper
    REF 402d096b39f4f618ad9e6ff2b4fc1b5eb260a2e4 # version-4.0.0
    SHA512 b2c2a2514479ec4a3d634d42d0a614951c06f6177e43a80b9a31797b7d4ad248fcdff632596806fcf811c87779990ba7c19aa2f9b91afafbc172dd85f96bb239
    HEAD_REF master
    PATCHES
        no_stdc_check.patch
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
        -DJAS_ENABLE_LIBJPEG=ON
        -DJAS_ENABLE_OPENGL=${JAS_ENABLE_OPENGL}
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

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

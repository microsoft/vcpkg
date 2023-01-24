set(GIFLIB_VERSION 5.2.1)

set(EXTRA_PATCHES "")
if (VCPKG_TARGET_IS_WINDOWS)
    list(APPEND EXTRA_PATCHES fix-compile-error.patch)
endif()

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "giflib"
    FILENAME "giflib-${GIFLIB_VERSION}.tar.gz"
    SHA512 4550e53c21cb1191a4581e363fc9d0610da53f7898ca8320f0d3ef6711e76bdda2609c2df15dc94c45e28bff8de441f1227ec2da7ea827cb3c0405af4faa4736
    PATCHES
        msvc-guard-unistd-h.patch
        disable-GifDrawBoxedText8x8-win32.patch # MSVC doesn't have strtok_r
        ${EXTRA_PATCHES}
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DGIFLIB_EXPORTS=${CMAKE_CURRENT_LIST_DIR}/exports.def"
    OPTIONS_DEBUG
        -DGIFLIB_SKIP_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/gif")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

set(EXTRA_PATCHES "")
if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    list(APPEND EXTRA_PATCHES msvc.diff)
endif()

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "giflib"
    FILENAME "giflib-${VERSION}.tar.gz"
    SHA512 523cf2a9941c6ddb903bf5ec22ecbf5a283c9470c1c85229360ab4137227a9e4a64b799e3ff0ca1f9f3b9de0fafe197a43fccd3c043239e76561f7b5ede59193
    PATCHES
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

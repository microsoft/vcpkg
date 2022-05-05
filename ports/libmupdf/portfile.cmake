vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArtifexSoftware/mupdf
    REF 61b63d734a7b9df618f6b45dda2466aed442f7f0 # 1.19.0-rc2
    SHA512 16661c012e18ac72b24c46caf5c02515c29a05e0a8dcf95076eff3a1f2e87c225245037480ed37068858fe6e04ff4a404f69877599b208ab9265d054ec117820
    HEAD_REF master
    PATCHES
        dont-generate-extract-3rd-party-things.patch
        use-if-instead-of-ifdef-in-writer.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

file(COPY "${SOURCE_PATH}/include/mupdf" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greenm01/poly2tri
    REF 88de49021b6d9bef6faa1bc94ceb3fbd85c3c204
    SHA512 fa256bcf923ad59f42205edf5a7e07cac6cbd9a37cefb9a0961a2e06aea7fa8ffd09d4e26154c0028601c12804483842cb935d9f602385f5f203c9628382c4fb
    HEAD_REF master
    PATCHES
        fix-sweep-h-codepage.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO maxmind/libmaxminddb
    REF 07797e9dfb6771190f9fa41a33babe19425ef552 #1.4.3
    SHA512 94f7fbd46a7846c804edad9759ceedf2f7c4b2085430322f74bea5c89f6c3fa0824f154f551119a8c69becec5120650efef89c6d7f5a2ef3df476086070c8c7e
    HEAD_REF master
    PATCHES fix-linux-build.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
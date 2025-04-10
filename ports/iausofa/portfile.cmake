vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# https://github.com/${REPO}/archive/${REF}.tar.gz
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO longzhmm/vcpkg_iausofa
    REF 8058fedf19ae2563dc643c04fde1d5f2b1057176
    SHA512 de13bb1786e1c4b7556e8b53ac42c2b6a466c960ee69f85714e6f33aee72cfa9804edf43595f43bb660274c88ad2cd3a88f8675705bfdfb73cd08e3d6d5a93e4  # This is a temporary value. We will modify this value in the next section.
    HEAD_REF main
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "iausofa")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
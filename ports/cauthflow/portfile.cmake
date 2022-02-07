vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/cauthflow
    REF             7ae1918c4a2ece66e5e2221babf89ce7d9b7a6a8
    SHA512          972060b89e281af18e07d0e60dd6f80d41e76652c4a4152850931b14d6596f2df54be69ec12933e438a1edb6b657ea08b3f86547f606a95d796dd236735fa525
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

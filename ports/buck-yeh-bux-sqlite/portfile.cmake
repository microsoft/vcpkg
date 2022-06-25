vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux-sqlite
    REF e8ab90da9586f61024b59aa1a4900efb94f1d3f4 # v1.0.1
    SHA512 27acefdb32dd00dbbef91479b5e682cf6a9281e13a596128d5050fe44ed4b8669d5e7279b4db30efbd4d016d268c6f2ce893f91bbdddff17f2a227ba3a292d01
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

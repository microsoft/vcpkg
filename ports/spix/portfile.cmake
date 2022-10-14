vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO faaxm/spix
    REF v0.4
    SHA512 4686199f851b4f06abf963ea79d3d2094d7bd956f009b3fe244dfbcfa7e0756d9971cb882c9963d479b44194806f3d0eaef68ac90b3468bf4ba9139948a9cd7b

    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSPIX_BUILD_EXAMPLES=OFF
        -DSPIX_BUILD_TESTS=OFF
        -DSPIX_QT_MAJOR=5
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()

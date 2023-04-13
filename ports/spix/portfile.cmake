vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO faaxm/spix
    REF v0.5
    SHA512 fdc35ff4920a83d4b2d0abe84eae7c8f46cb259e525d4445b091eb01990bcdeade7e60a00795f4acccc09f0702fa61d17ba6c7b8bbf19ff218e8bd42e1eb7f7c

    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSPIX_BUILD_EXAMPLES=OFF
        -DSPIX_BUILD_TESTS=OFF
        -DSPIX_QT_MAJOR=6
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()

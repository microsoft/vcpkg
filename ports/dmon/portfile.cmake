vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            septag/dmon
    REF             244105681b1421adbfd108162535ad8097d2895f
    SHA512          6ea483300404b50e2f4d1e05fec187bde827d9bf8ae6716c41e5b75afb96d4c09f155dff08e6b8f9606a4afc78ce7397acbe48233f9d27b0ad4e0a4ffd350294
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTS=OFF"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

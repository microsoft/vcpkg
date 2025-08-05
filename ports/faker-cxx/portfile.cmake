vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cieslarmichal/faker-cxx
    REF "v${VERSION}"
    SHA512 5deffc3f820926719a8398d9ecb6e643d94667c6959b5f9e121d6300239d9537c8a8a39389ce74d5d174df215220d48fd599398063063e5ad778bc00e0d659b1
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME faker-cxx
    CONFIG_PATH "lib/cmake"
)   

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/LICENSES.md")

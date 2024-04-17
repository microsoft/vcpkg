vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hayguen/iowahills_dsp
    REF "v${VERSION}"
    SHA512 095fecb1a4bf074a3e11da7e6edaba4d375c5603bed5f2578b52f900dbd20ac59f2414a8f9432eba1742807fe8553cc1edd63606fc38400cdda77bf32ee49eb1
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

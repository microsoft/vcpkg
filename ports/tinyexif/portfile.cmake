vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/TinyEXIF
    REF ${VERSION}
    SHA512 cb4e1f15758bb65465e2234065e3b46493200278e7c2e12fa7b4e31e7bff52a93158f07252a642829bad1a7da5e47612aca33fb833f3188595c6bc56cc950f63
    HEAD_REF 1.0.4
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" LINK_CRT_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLINK_CRT_STATIC_LIBS=${LINK_CRT_STATIC}
        -DBUILD_DEMO=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/TinyEXIF)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

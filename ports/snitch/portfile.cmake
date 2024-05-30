vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO snitch-org/snitch
    REF v1.2.4
    SHA512 783c4667d5c75d5d719d6c85a47ee795099256bacd01324d9bd5550be5f77be265f3372190b89ac109a11479bbf99f90a9e7afb32e6bdfeaab3a936ad50a219a
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSNITCH_DEFINE_MAIN=0
        -DCMAKE_CXX_STANDARD=20
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/snitch
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

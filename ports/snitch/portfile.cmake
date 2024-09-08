vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO snitch-org/snitch
    REF "v${VERSION}"
    SHA512 bb51c7ec51ab934ccd05b8e653ba3da8f321702307fa28b11b8a7ec31e170e337c2ccbe8f4895a25e4fdec1358f90d11a51c489511af95a65311c57e4a4164ef
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

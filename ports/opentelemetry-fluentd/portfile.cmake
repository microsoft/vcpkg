vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-telemetry/opentelemetry-cpp-contrib
    REF 20721e51235565020fc7fef2ba1aee92fc5744e8  # Maps to 2.0.0
    HEAD_REF main
    SHA512 5761eb75a16f558b6ca1abcbb38a1f2f33c02f045f54972ffdcdeb35ec12b340930b3c119f55602ff80772ca1de1fdfffd4f89d158779e33d0c92e95460c7bb1
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/exporters/fluentd"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

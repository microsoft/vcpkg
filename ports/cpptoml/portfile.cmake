vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skystrife/cpptoml

	REF fededad7169e538ca47e11a9ee9251bc361a9a65
	SHA512 2ec50f4585bca33bb343170470048a7d7e7902f1ffa5709cf84ddf9f53a899ff1cc9ffa49e059f6dad93d13823c4d2661bc8109e4356078cdbdfef1a2be6a622

    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCPPTOML_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rollbear/trompeloeil
    REF ba406bfd71caf63f2180990a390ff5518e570c21    # v43
    SHA512 5a638392ee4078690e94a61fd5838f6b0ffd67784a6cb139c114286c5cb8453c450252c550e9efee575aa38d02d5de1b51ba4df6a1679d02987606559a96520d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/trompeloeil)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/include/trompeloeil.hpp")
    message(FATAL_ERROR "Main includes have moved. Please update the forwarder.")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

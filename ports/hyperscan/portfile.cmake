vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(HYPERSCAN_VERSION 5.1.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/hyperscan
    REF v${HYPERSCAN_VERSION}
    SHA512 5e6d11429e61dc061dd31e6b311a8c1dbfcd03af6e24d97b95eb2cef24dcd33d593064e5faa7c22807d785a8921bc410a69a43c4e5b3d7b4774f37c4a12a025d
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

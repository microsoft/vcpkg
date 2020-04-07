vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(HYPERSCAN_VERSION 5.2.1)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/hyperscan
    REF v${HYPERSCAN_VERSION}
    SHA512 e6ac2aef1f3efa1535c00d73fa590ea62fff4686c4ad3ee023d2e72c51896ca4616ec1b85d7c6f88ac7b42d92c3557b9c4bb3b51cfb796e20a79d53b28e53b6c
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

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TartanLlama/function_ref
    REF v1.0.0
    SHA512 64324049021548361caa667a5ad61a8c0acc787d3966e5b132520da99af709970e37b5a5cb71f69523b6254c9d0d8bab441356e7a25880fe53a6998067c587bd
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DFUNCTION_REF_ENABLE_TESTS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/tl-function-ref RENAME copyright)

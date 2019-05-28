include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO richgel999/miniz
    REF a4264837ae37384b1d7a205a6732db322f0f3769
    SHA512 88f0e03cccfe66c796db7594b93c667bd52cd7f4d13803181e9d86b4aa26f214fd2907a45a752da603d3e87f8d53c40bfc0956b279c0d49016f7b943aeb9cd33
    HEAD_REF master
    PATCHES
    	CMakeLists-targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/miniz RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME miniz)

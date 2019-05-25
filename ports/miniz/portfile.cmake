include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO richgel999/miniz
    REF a4264837ae37384b1d7a205a6732db322f0f3769
    SHA512 e0aba16afdf230d1e54d0a9cedd336b0b158b02744839f0547e14ee47a97fc1a6668f3a181bd46e969b01b158af18dc8ed3c0a4210b3b620242338a2788806b3
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

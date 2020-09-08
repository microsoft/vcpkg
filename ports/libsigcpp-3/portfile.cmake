include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsigcplusplus/libsigcplusplus
    REF v3.0.3
    SHA512 4ba1eeb1296ea8b3e911a7c6ce66c402f877485fd3da1ff1c2e6cfe89a986788cb9bcc9ff8d8ef57dc6dbaa046d7a18d30f6b32a0235fe66fb7afae4ec12e13e
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sigc++-3 TARGET_PATH share/sigc++-3)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libsigcpp-3)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libsigcpp-3/COPYING ${CURRENT_PACKAGES_DIR}/share/libsigcpp-3/copyright)

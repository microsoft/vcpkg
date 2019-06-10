include(vcpkg_common_functions)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL git://developer.intra2net.com/libftdi
    REF v0.20
    SHA512 724d64abd4b47a6d52516f77881620414e53995266512aca67dd3d4c55490c33b4997b64e43349de05c1518b968f65869bd55a4594dd4148a25a1e2fd7e3ea1e
    HEAD_REF master
    PATCHES
        usb-header.patch
        cmake-fix.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake/FindUSB.cmake DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY  ${CMAKE_CURRENT_LIST_DIR}/cmake/LibFTDIConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libftdi-compat)
file(COPY  ${CMAKE_CURRENT_LIST_DIR}/cmake/LibFTDIConfigVersion.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libftdi-compat)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libftdi-compat)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libftdi-compat/LICENSE ${CURRENT_PACKAGES_DIR}/share/libftdi-compat/copyright)

vcpkg_copy_pdbs()

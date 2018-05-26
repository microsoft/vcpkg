include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fukuchi/libqrencode
    REF v4.0.0
    SHA512 0e4855c7983d4c73eb4a7f9cb081679547957c9f4a30cb943f2ae25e3a6496a202d3489f46e248386499d05a68c6a36e24f64af57ef4d6f447ef3a39e08374ee
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/remove-deprecated-attribute.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_TOOLS=NO
        -DWITH_TEST=NO
        -DSKIP_INSTALL_PROGRAMS=ON
        -DSKIP_INSTALL_EXECUTABLES=ON
        -DSKIP_INSTALL_FILES=ON
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/qrencode.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/qrencode.dll ${CURRENT_PACKAGES_DIR}/bin/qrencode.dll)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/qrencoded.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/qrencoded.dll ${CURRENT_PACKAGES_DIR}/debug/bin/qrencoded.dll)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libqrencode)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libqrencode/COPYING ${CURRENT_PACKAGES_DIR}/share/libqrencode/copyright)

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

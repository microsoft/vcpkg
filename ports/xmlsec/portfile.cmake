vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lsh123/xmlsec
    REF xmlsec-1_2_32
    SHA512 45e2efc6bdf6ec09db6ff01b521c3fbcf44aa9804d5692bea5296e80d7fc2f05fac322868f82840a7b67e0abd4233222098aa94a29ec9a6a7d049180cf131c57
    HEAD_REF master
    PATCHES 
        pkgconfig_fixes.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS -DPORT_DIR=${CMAKE_CURRENT_LIST_DIR}
    OPTIONS_DEBUG -DINSTALL_HEADERS_TOOLS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/Copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()

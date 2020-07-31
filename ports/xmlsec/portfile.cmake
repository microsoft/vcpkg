vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lsh123/xmlsec
    REF xmlsec-1_2_30
    SHA512 e631e7b132b39bb53f2713fe34880f8b4e81fd759fd206e8872c066236a8a64713842ba5e0ba9ad2f345f9f6d1da304acbeb61411b52cfa79d2934fc9e260ce9
    HEAD_REF master
    PATCHES 
        0001-uwp-fix.patch
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

file(INSTALL ${SOURCE_PATH}/Copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hunspell/hunspell
    REF v1.6.1
    SHA512 39b096ec1f5226f13eaf241647fc9b49a6dad04945ae0bcdc61ba845d66d67d64a72ba4287b6f376b5ad053b5d0e1d42a42415c30521c50693f0544718029458
    HEAD_REF master
    PATCHES 0001_fix_unistd.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/hunspell)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/hunspell/COPYING ${CURRENT_PACKAGES_DIR}/share/hunspell/copyright)

file(COPY ${SOURCE_PATH}/COPYING.LESSER DESTINATION ${CURRENT_PACKAGES_DIR}/share/hunspell)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/hunspell/COPYING.LESSER ${CURRENT_PACKAGES_DIR}/share/hunspell/copyright-lgpl)

file(COPY ${SOURCE_PATH}/COPYING.MPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/hunspell)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/hunspell/COPYING.MPL ${CURRENT_PACKAGES_DIR}/share/hunspell/copyright-mpl)

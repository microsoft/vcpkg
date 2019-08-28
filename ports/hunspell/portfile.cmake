include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hunspell/hunspell
    REF v1.7.0
    SHA512 8149b2e8b703a0610c9ca5160c2dfad3cf3b85b16b3f0f5cfcb7ebb802473b2d499e8e2d0a637a97a37a24d62424e82d3880809210d3f043fa17a4970d47c903
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

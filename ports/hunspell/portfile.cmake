include(vcpkg_common_functions)
set(HUNSPELL_VERSION 1.6.1)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/hunspell-${HUNSPELL_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/hunspell/hunspell/archive/v${HUNSPELL_VERSION}.zip"
    FILENAME "hunspell-${HUNSPELL_VERSION}.zip"
    SHA512 164eb1ae9ff9f4d8efe8998fa3ad847bf5a0c1a87113acc52dcdb3aaddb4e9179274585623bd7152f9a82b803bd42ce24fe856ac8d49121214bef59ac1c7753c
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001_fix_unistd.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_build_cmake()
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB_RECURSE TOOLS_RELEASE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(GLOB_RECURSE TOOLS_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)

file(COPY ${TOOLS_RELEASE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(REMOVE ${TOOLS_RELEASE} ${TOOLS_DEBUG})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/hunspell)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/hunspell/COPYING ${CURRENT_PACKAGES_DIR}/share/hunspell/copyright)

file(COPY ${SOURCE_PATH}/COPYING.LESSER DESTINATION ${CURRENT_PACKAGES_DIR}/share/hunspell)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/hunspell/COPYING.LESSER ${CURRENT_PACKAGES_DIR}/share/hunspell/copyright-lgpl)

file(COPY ${SOURCE_PATH}/COPYING.MPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/hunspell)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/hunspell/COPYING.MPL ${CURRENT_PACKAGES_DIR}/share/hunspell/copyright-mpl)


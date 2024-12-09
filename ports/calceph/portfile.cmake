set(CALCEPH_HASH 0130bf9f48338146eb32aba4c9ceaa2d2a2ba2dfc4812c4c27cf87da06719172e3273cce4890f76233bbe15fc13952a05c06bce6a216e4ae6ca9613c902dca33)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.imcce.fr/content/medias/recherche/equipes/asd/calceph/calceph-${VERSION}.tar.gz"
    FILENAME "calceph-${VERSION}.tar.gz"
    SHA512 ${CALCEPH_HASH}
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_tools(TOOL_NAMES calceph_inspector calceph_queryposition calceph_queryorientation AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/README.rst" DESTINATION "${CURRENT_PACKAGES_DIR}/share/calceph" RENAME readme.rst)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING_CECILL_B.LIB")

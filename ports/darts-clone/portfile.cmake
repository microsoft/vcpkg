vcpkg_check_linkage(
  ONLY_STATIC_LIBRARY
)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO s-yata/darts-clone
    REF 1767ab87cffe7302856d1bb41e1c21b1df93f19e
    SHA512 63112a4d8d6302d2602a8f161bf5fe5ec1b5b3b3097de9b28331f5261d76c06efb48601c08df26f242ddc881b917928baf54f24ccebac65da29e94380b6db0f5
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE ${CURRENT_PACKAGES_DIR}/include/Makefile.am)

file(INSTALL ${SOURCE_PATH}/COPYING.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/darts-clone RENAME copyright)

vcpkg_download_distfile(ARCHIVE
    URLS https://git.kernel.org/pub/scm/libs/libcap/libcap.git/snapshot/libcap-3c7dda330bd9a154bb5b878d31fd591e4951fe17.tar.gz
    FILENAME libpcap-${VERSION}.tar.gz
    SHA512 0732c9f07be38c2bb06409f1f31d7ed5ad31b38ae380650b334074856f89b885deabb9603e21a989e81b530050c068bbbf60157adbf3ca3893e4bca7d61f63d2
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/configure" DESTINATION "${SOURCE_PATH}")

if(VCPKG_CROSSCOMPILING)
    file(TOUCH "${SOURCE_PATH}/libcap/_makenames")
    file(COPY "${CURRENT_HOST_INSTALLED_DIR}/include/sys/libcap-private/cap_names.list.h" DESTINATION "${SOURCE_PATH}/libcap/")
    file(COPY "${CURRENT_HOST_INSTALLED_DIR}/include/sys/libcap-private/cap_names.h" DESTINATION "${SOURCE_PATH}/libcap/")
    file(TOUCH "${SOURCE_PATH}/libcap/cap_names.h")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
    DETERMINE_BUILD_TRIPLET
)
vcpkg_install_make(
    MAKEFILE "Makefile.vcpkg"
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License")

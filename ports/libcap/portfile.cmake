vcpkg_download_distfile(ARCHIVE
    URLS "https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-${VERSION}.tar.xz"
         "https://www.mirrorservice.org/sites/ftp.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-${VERSION}.tar.xz"
    FILENAME "libcap-${VERSION}.tar.xz"
    SHA512 c783cb43ffb40eb005fb880efe18e72667c743af79d647f67ee3201d5ff1e64446f9c850cced935a04b63a8ee3380bbf28dd91e2dfbcbddb561c8d096da610d0
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

vcpkg_cmake_get_vars(cmake_vars_file)
set(ENV{OBJCOPY} "${VCPKG_DETECTED_CMAKE_OBJCOPY}")

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    COPY_SOURCE
)
vcpkg_make_install(MAKEFILE "Makefile.vcpkg")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License")

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-${VERSION}.tar.xz"
         "https://www.mirrorservice.org/sites/ftp.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-${VERSION}.tar.xz"
    FILENAME "libcap-${VERSION}.tar.xz"
    SHA512 59bb6781d96776595ad3df890f4e5188380634eabbb6128f3a5307946b01cf3bd19dee8a29d3e501de1d9e1c6ed0092c4cd5adc91da227a1260c1f4356cc0bf3
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

block(SCOPE_FOR VARIABLES)
    set(VCPKG_CMAKE_CONFIGURE_OPTIONS "-DVCPKG_VARS_TO_CHECK=CMAKE_OBJCOPY")
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")
    set(ENV{OBJCOPY} "${VCPKG_DETECTED_CMAKE_OBJCOPY}")
endblock()

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

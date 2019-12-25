include(vcpkg_common_functions)

set(LIBOSIP2_VER "5.1.0")

if (VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "libosio2 only support unix currently.")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnu.org/gnu/osip/libosip2-${LIBOSIP2_VER}.tar.gz"
    FILENAME "libosip2-${LIBOSIP2_VER}.tar.gz"
    SHA512 391c9a0ea399f789d7061b0216d327eecba5bbf0429659f4f167604b9e703e1678ba6f58079aa4f84b3636a937064ecfb92e985368164fcb679e95654e43d65b
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    NO_DEBUG
    AUTO_HOST
    AUTO_DST
    PRERUN_SHELL autogen.sh
)

vcpkg_install_make()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(GLOB_RECURSE LIBOSIP2_BINARIES ${CURRENT_PACKAGES_DIR}/lib *.so)
foreach(LIBOSIP2_BINARY LIBOSIP2_BINARIES)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(COPY ${LIBOSIP2_BINARY} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    endif()
    file(REMOVE ${LIBOSIP2_BINARY})
endforeach()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
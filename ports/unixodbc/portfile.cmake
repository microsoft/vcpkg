vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lurcher/unixODBC
    REF "v${VERSION}"
    SHA512 0
    HEAD_REF master
)

set(ENV{CFLAGS} "$ENV{CFLAGS} -Wno-error=implicit-function-declaration")

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_LINUX)
    list(APPEND OPTIONS --with-included-ltdl)
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    COPY_SOURCE
    OPTIONS ${OPTIONS}
)

vcpkg_install_make()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif ()

file(REMOVE_RECURSE
     "${CURRENT_PACKAGES_DIR}/debug/include"
     "${CURRENT_PACKAGES_DIR}/debug/share"
     "${CURRENT_PACKAGES_DIR}/debug/etc"
     "${CURRENT_PACKAGES_DIR}/etc"
     "${CURRENT_PACKAGES_DIR}/share/man"
     "${CURRENT_PACKAGES_DIR}/share/${PORT}/man1"
     "${CURRENT_PACKAGES_DIR}/share/${PORT}/man5"
     "${CURRENT_PACKAGES_DIR}/share/${PORT}/man7"
)

foreach(FILE config.h unixodbc_conf.h)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define BIN_PREFIX \"${CURRENT_INSTALLED_DIR}/tools/unixodbc/bin\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define DEFLIB_PATH \"${CURRENT_INSTALLED_DIR}/lib\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define EXEC_PREFIX \"${CURRENT_INSTALLED_DIR}\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define INCLUDE_PREFIX \"${CURRENT_INSTALLED_DIR}/include\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define LIB_PREFIX \"${CURRENT_INSTALLED_DIR}/lib\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define PREFIX \"${CURRENT_INSTALLED_DIR}\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define SYSTEM_FILE_PATH \"${CURRENT_INSTALLED_DIR}/etc\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixODBC/${FILE}" "#define SYSTEM_LIB_PATH \"${CURRENT_INSTALLED_DIR}/lib\"" "")
endforeach()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unixodbcConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

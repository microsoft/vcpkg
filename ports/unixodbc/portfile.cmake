
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lurcher/unixODBC
    REF v2.3.9
    SHA512 473f8d39f5976b4c34394d880d6e511b73e33a1fbd6b828a0929787983cd9b5fe7e16776ed51776ce44b54aa61c62be689c0731489b3989acb99c135fb492ec5
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
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixodbc_conf.h" "#define BIN_PREFIX \"${CURRENT_INSTALLED_DIR}/tools/unixodbc/bin\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixodbc_conf.h" "#define DEFLIB_PATH \"${CURRENT_INSTALLED_DIR}/lib\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixodbc_conf.h" "#define EXEC_PREFIX \"${CURRENT_INSTALLED_DIR}\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixodbc_conf.h" "#define INCLUDE_PREFIX \"${CURRENT_INSTALLED_DIR}/include\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixodbc_conf.h" "#define LIB_PREFIX \"${CURRENT_INSTALLED_DIR}/lib\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixodbc_conf.h" "#define PREFIX \"${CURRENT_INSTALLED_DIR}\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixodbc_conf.h" "#define SYSTEM_FILE_PATH \"${CURRENT_INSTALLED_DIR}/etc\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/unixodbc_conf.h" "#define SYSTEM_LIB_PATH \"${CURRENT_INSTALLED_DIR}/lib\"" "")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unixodbcConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

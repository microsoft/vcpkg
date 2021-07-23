if (NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_fail_port_install(MESSAGE "${PORT} is only for openssl on Unix-like systems" ON_TARGET "UWP" "Windows")
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH MASTER_COPY_SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF ${OPENSSL_VERSION}
)

if(CMAKE_HOST_WIN32)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES make perl)
    set(MAKE ${MSYS_ROOT}/usr/bin/make.exe)
    set(PERL ${MSYS_ROOT}/usr/bin/perl.exe)
else()
    find_program(MAKE make)
    if(NOT MAKE)
        message(FATAL_ERROR "Could not find make. Please install it through your package manager.")
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${CMAKE_CURRENT_LIST_DIR}
    PREFER_NINJA
    OPTIONS
        -DSOURCE_PATH=${MASTER_COPY_SOURCE_PATH}
        -DPERL=${PERL}
        -DMAKE=${MAKE}
        -DVCPKG_CONCURRENCY=${VCPKG_CONCURRENCY}
    OPTIONS_RELEASE
        -DINSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_pkgconfig()

file(GLOB HEADERS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/include/openssl/*.h)
set(RESOLVED_HEADERS)
foreach(HEADER ${HEADERS})
    get_filename_component(X "${HEADER}" REALPATH)
    list(APPEND RESOLVED_HEADERS "${X}")
endforeach()

file(INSTALL ${RESOLVED_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/openssl)
file(INSTALL ${MASTER_COPY_SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

if(CMAKE_HOST_WIN32)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES make perl)
    set(MAKE "${MSYS_ROOT}/usr/bin/make.exe")
    set(PERL "${MSYS_ROOT}/usr/bin/perl.exe")
else()
    find_program(MAKE make)
    if(NOT MAKE)
        message(FATAL_ERROR "Could not find make. Please install it through your package manager.")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}"
    OPTIONS
        -DSOURCE_PATH=${SOURCE_PATH}
        -DPERL=${PERL}
        -DMAKE=${MAKE}
        -DVCPKG_CONCURRENCY=${VCPKG_CONCURRENCY}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(GLOB HEADERS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/include/openssl/*.h")
set(RESOLVED_HEADERS)
foreach(HEADER ${HEADERS})
    get_filename_component(X "${HEADER}" REALPATH)
    list(APPEND RESOLVED_HEADERS "${X}")
endforeach()

file(INSTALL ${RESOLVED_HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include/openssl")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

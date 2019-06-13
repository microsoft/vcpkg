find_package(ZLIB REQUIRED)
find_package(BZip2 REQUIRED)

find_path(LIBZIP_INCLUDE_DIR NAMES zip.h)
mark_as_advanced(LIBZIP_INCLUDE_DIR)

find_library(LIBZIP_LIBRARY NAMES zip)
mark_as_advanced(LIBZIP_LIBRARY)

include(CMakeFindDependencyMacro)
find_package_handle_standard_args(
    LIBZIP 
    REQUIRED_VARS
        LIBZIP_LIBRARY
        LIBZIP_INCLUDE_DIR
)

if (LIBZIP_FOUND)
    set(LIBZIP_INCLUDE_DIRS "${LIBZIP_INCLUDE_DIR}")

    if (NOT TARGET libzip::libzip)
        add_library(libzip::libzip UNKNOWN IMPORTED)
        set_target_properties(libzip::libzip
            PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES ${LIBZIP_INCLUDE_DIRS}
                INTERFACE_LINK_LIBRARIES "ZLIB::ZLIB;BZip2::BZip2"
                IMPORTED_LOCATION "${LIBZIP_LIBRARY}"
        )
    endif()
endif()

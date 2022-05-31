cmake_policy(PUSH)
cmake_policy(SET CMP0012 NEW)
cmake_policy(SET CMP0054 NEW)
if(POLICY CMP0079)
    cmake_policy(SET CMP0079 NEW)
endif()
list(FIND ARGS "CONFIG" Z_VCPKG_LIBXML2_CONFIG)

set(LIBXML2_INCLUDE_DIR "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include" CACHE PATH "" FORCE)
find_library(LIBXML2_LIBRARY_DEBUG
    NAMES xml2 libxml2 xml2s libxml2s xml2d libxml2d xml2sd libxml2sd
    NAMES_PER_DIR
    PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib"
    NO_DEFAULT_PATH
)
find_library(LIBXML2_LIBRARY_RELEASE
    NAMES xml2 libxml2 xml2s libxml2s
    NAMES_PER_DIR
    PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib"
    NO_DEFAULT_PATH
)
include(SelectLibraryConfigurations)
select_library_configurations(LIBXML2)
unset(LIBXML2_FOUND)
if(CMAKE_VERSION VERSION_LESS "3.10")
    set(LIBXML2_INCLUDE_DIRS "${LIBXML2_INCLUDE_DIR}")
    set(LIBXML2_LIBRARIES "${LIBXML2_LIBRARIES}" CACHE STRING "CMake 3.10 cache variable" FORCE)
else()
    set(LIBXML2_LIBRARY "${LIBXML2_LIBRARIES}" CACHE STRING "CMake 3.10 cache variable" FORCE)
endif()

_find_package(${ARGS})

if(LibXml2_FOUND AND Z_VCPKG_LIBXML2_CONFIG STREQUAL "-1")
    # Backfill LibXml2::LibXml2 to versions of CMake before 3.10
    if(NOT TARGET LibXml2::LibXml2)
        add_library(LibXml2::LibXml2 UNKNOWN IMPORTED)
    endif()
    # FindLibXml2.cmake sets IMPORTED_LOCATION to our LIBXML2_LIBRARY list, so we must overwrite it.
    set_target_properties(LibXml2::LibXml2 PROPERTIES
        IMPORTED_CONFIGURATIONS "RELEASE"
        IMPORTED_LOCATION "${LIBXML2_LIBRARY_RELEASE}"
        IMPORTED_LOCATION_RELEASE "${LIBXML2_LIBRARY_RELEASE}"
    )
    if(LIBXML2_LIBRARY_DEBUG)
        set_target_properties(LibXml2::LibXml2 PROPERTIES
            IMPORTED_CONFIGURATIONS "RELEASE;DEBUG"
            IMPORTED_LOCATION_DEBUG "${LIBXML2_LIBRARY_DEBUG}"
        )
    endif()
    if(CMAKE_DL_LIBS)
        list(APPEND LIBXML2_LIBRARIES ${CMAKE_DL_LIBS})
        set_property(TARGET LibXml2::LibXml2 APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${CMAKE_DL_LIBS})
    endif()
    if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
        find_package(Iconv) # CMake 3.11
        find_package(LibLZMA)
        find_package(Threads)
        find_package(ZLIB)
        list(APPEND LIBXML2_LIBRARIES ${LIBLZMA_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT} ${ZLIB_LIBRARIES})
        set_property(TARGET LibXml2::LibXml2 APPEND PROPERTY INTERFACE_LINK_LIBRARIES "LibLZMA::LibLZMA" "Threads::Threads" "ZLIB::ZLIB")
        if(Iconv_LIBRARIES)
            list(APPEND LIBXML2_LIBRARIES ${Iconv_LIBRARIES})
            set_property(TARGET LibXml2::LibXml2 APPEND PROPERTY INTERFACE_LINK_LIBRARIES "Iconv::Iconv")
        endif()
        if(UNIX)
            list(APPEND LIBXML2_LIBRARIES m)
            set_property(TARGET LibXml2::LibXml2 APPEND PROPERTY INTERFACE_LINK_LIBRARIES "m")
        endif()
        if(WIN32)
            list(APPEND LIBXML2_LIBRARIES ws2_32)
            set_property(TARGET LibXml2::LibXml2 APPEND PROPERTY INTERFACE_LINK_LIBRARIES "ws2_32")
        endif()
    endif()
endif()
unset(Z_VCPKG_LIBXML2_CONFIG)
cmake_policy(POP)

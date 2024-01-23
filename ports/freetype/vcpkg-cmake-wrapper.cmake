cmake_policy(PUSH)
cmake_policy(SET CMP0012 NEW)
cmake_policy(SET CMP0054 NEW)

# CMake comes with FindFreetype module which conflicts with Freetype 2.13.x's and onwards freetype-config.cmake
# which now defines the same target. To fix this, we stop the FindFreetype.cmake module from running, and just
# use the configs settings instead.
list(REMOVE_ITEM ARGS NO_MODULE CONFIG MODULE)
_find_package(${ARGS} NAMES freetype)

if(NOT TARGET Freetype::Freetype)
    message( FATAL_ERROR "The freetype vcpkg-cmake-wrapper.cmake assumes the existence of the"
            "'Freetype::Freetype' target, which should be exposed in freetype-config.cmake through freetype-targets.cmake" )
endif()
if(NOT TARGET freetype)
    message( FATAL_ERROR "The freetype vcpkg-cmake-wrapper.cmake assumes the existence of the"
            "'freetype' target, which should be exposed in freetype-config.cmake through freetype-targets.cmake" )
endif()
# we need to make sure that targets that previously depended on the module definition of Freetype still have access
# to the exposed result variables needed here:
# https://cmake.org/cmake/help/latest/module/FindFreetype.html#result-variables
# Those variables are:
#     FREETYPE_FOUND
#     FREETYPE_INCLUDE_DIRS
#     Don't know if these need to actually be exposed, they are merely mentioned in the above link.
#         FREETYPE_INCLUDE_DIR_ft2build
#         FREETYPE_INCLUDE_DIR_freetype2
#     FREETYPE_LIBRARIES
#     FREETYPE_VERSION_STRING
set(FREETYPE_FOUND TRUE)

# Not trying to get LINK_LIBRARIES because only interface is exposed on the INTERFACE as of this update.  In future updates
# we may need to add changes here as Freetype continually adds changes to it's CMake distribution strategy (22/01/2024)
get_target_property(TEMP_VCPKG_FREETYPE_CONFIG_TARGET_INTERFACE_LINK_LIBRARIES Freetype::Freetype INTERFACE_LINK_LIBRARIES)
set(FREETYPE_LIBRARIES "")
list(APPEND FREETYPE_LIBRARIES ${TEMP_VCPKG_FREETYPE_CONFIG_TARGET_INTERFACE_LINK_LIBRARIES})
unset(TEMP_VCPKG_FREETYPE_CONFIG_TARGET_INTERFACE_LINK_LIBRARIES)



# Not trying to get INCLUDE_DIRECTORIES because only INTERFACE is exposed on the target as of this update.  In future updates
# we may need to add changes here as Freetype continually adds changes to it's CMake distribution strategy (22/01/2024)
# Note for whatever reason we can't get the interface include directories from the Freetype::Freetype target...
get_target_property(TEMP_VCPKG_FREETYPE_CONFIG_TARGET_INTERFACE_INCLUDE_DIRECTORIES freetype INTERFACE_INCLUDE_DIRECTORIES)
set(FREETYPE_INCLUDE_DIRS "")
list(APPEND FREETYPE_INCLUDE_DIRS ${TEMP_VCPKG_FREETYPE_CONFIG_TARGET_INTERFACE_INCLUDE_DIRECTORIES})

# Don't think we need these targets exposed, but they are mentioned in https://cmake.org/cmake/help/latest/module/FindFreetype.html#result-variables
# so exposing them anyway.  In practice INTERFACE_INCLUDE_DIRECTORIES ends up just being the base install include
# directory, and FREETYPE_INCLUDE_DIR_ft2build and FREETYPE_INCLUDE_DIR_freetype2 end up being the same thing
set(FREETYPE_INCLUDE_DIR_ft2build ${TEMP_VCPKG_FREETYPE_CONFIG_TARGET_INTERFACE_INCLUDE_DIRECTORIES})
set(FREETYPE_INCLUDE_DIR_freetype2 ${TEMP_VCPKG_FREETYPE_CONFIG_TARGET_INTERFACE_INCLUDE_DIRECTORIES})
unset(TEMP_VCPKG_FREETYPE_CONFIG_TARGET_INTERFACE_INCLUDE_DIRECTORIES)


# Version is not set on Freetype::Freetype or freetype, we have to get it from this variable.
set(FREETYPE_VERSION_STRING ${Freetype_VERSION})


if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
    if("@FT_REQUIRE_ZLIB@")
        find_package(ZLIB)
    endif()
    if("@FT_REQUIRE_BZIP2@")
        find_package(BZip2)
    endif()
    if("@FT_REQUIRE_PNG@")
        find_package(PNG)
    endif()
    if("@FT_REQUIRE_BROTLI@")
        find_library(BROTLIDEC_LIBRARY_RELEASE NAMES brotlidec brotlidec-static PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" PATH_SUFFIXES lib NO_DEFAULT_PATH)
        find_library(BROTLIDEC_LIBRARY_DEBUG NAMES brotlidec brotlidec-static brotlidecd brotlidec-staticd PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug" PATH_SUFFIXES lib NO_DEFAULT_PATH)
        find_library(BROTLICOMMON_LIBRARY_RELEASE NAMES brotlicommon brotlicommon-static PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" PATH_SUFFIXES lib NO_DEFAULT_PATH)
        find_library(BROTLICOMMON_LIBRARY_DEBUG NAMES brotlicommon brotlicommon-static brotlicommond brotlicommon-staticd PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug" PATH_SUFFIXES lib NO_DEFAULT_PATH)
        include(SelectLibraryConfigurations)
        select_library_configurations(BROTLIDEC)
        select_library_configurations(BROTLICOMMON)
    endif("@FT_REQUIRE_BROTLI@")

    if(TARGET Freetype::Freetype)
        if("@FT_REQUIRE_ZLIB@")
            set_property(TARGET Freetype::Freetype APPEND PROPERTY INTERFACE_LINK_LIBRARIES ZLIB::ZLIB)
        endif()
        if("@FT_REQUIRE_BZIP2@")
            set_property(TARGET Freetype::Freetype APPEND PROPERTY INTERFACE_LINK_LIBRARIES BZip2::BZip2)
        endif()
        if("@FT_REQUIRE_PNG@")
            set_property(TARGET Freetype::Freetype APPEND PROPERTY INTERFACE_LINK_LIBRARIES PNG::PNG)
        endif()
        if("@FT_REQUIRE_BROTLI@")
            if(BROTLIDEC_LIBRARY_DEBUG)
                set_property(TARGET Freetype::Freetype APPEND PROPERTY INTERFACE_LINK_LIBRARIES "\$<\$<CONFIG:DEBUG>:${BROTLIDEC_LIBRARY_DEBUG}>")
                set_property(TARGET Freetype::Freetype APPEND PROPERTY INTERFACE_LINK_LIBRARIES "\$<\$<CONFIG:DEBUG>:${BROTLICOMMON_LIBRARY_DEBUG}>")
            endif()
            if(BROTLIDEC_LIBRARY_RELEASE)
                set_property(TARGET Freetype::Freetype APPEND PROPERTY INTERFACE_LINK_LIBRARIES "\$<\$<NOT:$<CONFIG:DEBUG>>:${BROTLIDEC_LIBRARY_RELEASE}>")
                set_property(TARGET Freetype::Freetype APPEND PROPERTY INTERFACE_LINK_LIBRARIES "\$<\$<NOT:$<CONFIG:DEBUG>>:${BROTLICOMMON_LIBRARY_RELEASE}>")
            endif()
        endif()
    endif()

    if(FREETYPE_LIBRARIES)
        if("@FT_REQUIRE_ZLIB@")
            list(APPEND FREETYPE_LIBRARIES ${ZLIB_LIBRARIES})
        endif()
        if("@FT_REQUIRE_BZIP2@")
            list(APPEND FREETYPE_LIBRARIES ${BZIP2_LIBRARIES})
        endif()
        if("@FT_REQUIRE_PNG@")
            list(APPEND FREETYPE_LIBRARIES ${PNG_LIBRARIES})
        endif()
        if("@FT_REQUIRE_BROTLI@")
            list(APPEND FREETYPE_LIBRARIES ${BROTLIDEC_LIBRARIES} ${BROTLICOMMON_LIBRARIES})
        endif()
    endif()
endif()
cmake_policy(POP)

#[===[.md:
# vcpkg_install_meson

Builds a meson project previously configured with `vcpkg_configure_meson()`.

## Usage
```cmake
vcpkg_install_meson([ADD_BIN_TO_PATH])
```

## Parameters:
### ADD_BIN_TO_PATH
Adds the appropriate Release and Debug `bin\` directories to the path during the build such that executables can run against the in-tree DLLs.

## Examples

* [fribidi](https://github.com/Microsoft/vcpkg/blob/master/ports/fribidi/portfile.cmake)
* [libepoxy](https://github.com/Microsoft/vcpkg/blob/master/ports/libepoxy/portfile.cmake)
#]===]

function(vcpkg_install_meson)
    vcpkg_find_acquire_program(NINJA)
    unset(ENV{DESTDIR}) # installation directory was already specified with '--prefix' option
    cmake_parse_arguments(PARSE_ARGV 0 _im "ADD_BIN_TO_PATH" "" "")

    if(VCPKG_TARGET_IS_OSX)
        if(DEFINED ENV{SDKROOT})
            set(_VCPKG_ENV_SDKROOT_BACKUP $ENV{SDKROOT})
        endif()
        set(ENV{SDKROOT} "${VCPKG_DETECTED_CMAKE_OSX_SYSROOT}")

        if(DEFINED ENV{MACOSX_DEPLOYMENT_TARGET})
            set(_VCPKG_ENV_MACOSX_DEPLOYMENT_TARGET_BACKUP $ENV{MACOSX_DEPLOYMENT_TARGET})
        endif()
        set(ENV{MACOSX_DEPLOYMENT_TARGET} "${VCPKG_DETECTED_CMAKE_OSX_DEPLOYMENT_TARGET}")
    endif()

    foreach(BUILDTYPE "debug" "release")
        if(DEFINED VCPKG_BUILD_TYPE AND NOT VCPKG_BUILD_TYPE STREQUAL BUILDTYPE)
            continue()
        endif()

        if(BUILDTYPE STREQUAL "debug")
            set(SHORT_BUILDTYPE "dbg")
        else()
            set(SHORT_BUILDTYPE "rel")
        endif()

        message(STATUS "Package ${TARGET_TRIPLET}-${SHORT_BUILDTYPE}")
        if(_im_ADD_BIN_TO_PATH)
            set(_BACKUP_ENV_PATH "$ENV{PATH}")
            if(BUILDTYPE STREQUAL "debug")
                vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/debug/bin")
            else()
                vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/bin")
            endif()
        endif()
        vcpkg_execute_required_process(
            COMMAND ${NINJA} install -v
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE}
            LOGNAME package-${TARGET_TRIPLET}-${SHORT_BUILDTYPE}
        )
        if(_im_ADD_BIN_TO_PATH)
            set(ENV{PATH} "${_BACKUP_ENV_PATH}")
        endif()
    endforeach()

    set(RENAMED_LIBS "")
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL static AND NOT VCPKG_TARGET_IS_MINGW)
        # Meson names all static libraries lib<name>.a which basically breaks the world
        file(GLOB_RECURSE LIBRARIES "${CURRENT_PACKAGES_DIR}*/**/lib*.a")
        foreach(_library IN LISTS LIBRARIES)
            get_filename_component(LIBDIR "${_library}" DIRECTORY )
            get_filename_component(LIBNAME "${_library}" NAME)
            string(REGEX REPLACE ".a$" ".lib" LIBNAMENEW "${LIBNAME}")
            string(REGEX REPLACE "^lib" "" LIBNAMENEW "${LIBNAMENEW}")
            file(RENAME "${_library}" "${LIBDIR}/${LIBNAMENEW}")
            # For cmake fixes.
            string(REGEX REPLACE ".a$" "" LIBRAWNAMEOLD "${LIBNAME}")
            string(REGEX REPLACE ".lib$" "" LIBRAWNAMENEW "${LIBNAMENEW}")
            list(APPEND RENAMED_LIBS ${LIBRAWNAMENEW})
            set(${LIBRAWNAME}_OLD ${LIBRAWNAMEOLD})
            set(${LIBRAWNAME}_NEW ${LIBRAWNAMENEW})
        endforeach()
        file(GLOB_RECURSE CMAKE_FILES "${CURRENT_PACKAGES_DIR}*/*.cmake")
        foreach(_cmake IN LISTS CMAKE_FILES)
            foreach(_lib IN LISTS RENAMED_LIBS)
                vcpkg_replace_string("${_cmake}" "${${_lib}_OLD}" "${${_lib}_NEW}")
            endforeach()
        endforeach()
    endif()

    if(VCPKG_TARGET_IS_OSX)
        if(DEFINED _VCPKG_ENV_SDKROOT_BACKUP)
            set(ENV{SDKROOT} "${_VCPKG_ENV_SDKROOT_BACKUP}")
        else()
            unset(ENV{SDKROOT})
        endif()
        if(DEFINED _VCPKG_ENV_MACOSX_DEPLOYMENT_TARGET_BACKUP)
            set(ENV{MACOSX_DEPLOYMENT_TARGET} "${_VCPKG_ENV_MACOSX_DEPLOYMENT_TARGET_BACKUP}")
        else()
            unset(ENV{MACOSX_DEPLOYMENT_TARGET})
        endif()
    endif()
endfunction()

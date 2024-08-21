if(NOT TARGET libmpv)
    # find lib
    find_library(LIBMPV_LIBRARY NAMES mpv-2 PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)

    # set include path
    set(LIBMPV_INCLUDE_DIR "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include")
    
    # check lib and include
    if(NOT LIBMPV_LIBRARY OR NOT EXISTS "${LIBMPV_INCLUDE_DIR}")
        message(FATAL_ERROR "libmpv not found. Please ensure the library and include directory are correctly specified.")
    endif()

    # set target
    add_library(libmpv INTERFACE IMPORTED)
    set_target_properties(libmpv PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${LIBMPV_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "${LIBMPV_LIBRARY}"
    )
endif()

# set version
set(LIBMPV_VERSION "0.38.0")


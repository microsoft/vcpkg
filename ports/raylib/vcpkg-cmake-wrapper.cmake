set(raylib_USE_STATIC_LIBS @STATIC@)

_find_package(${ARGS})

if(raylib_FOUND)
    get_filename_component(_raylib_lib_name ${raylib_LIBRARY} NAME)

    set(raylib_LIBRARY
        debug ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/${_raylib_lib_name}
        optimized ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/${_raylib_lib_name}
    )

    set(raylib_LIBRARIES ${raylib_LIBRARY})
endif()

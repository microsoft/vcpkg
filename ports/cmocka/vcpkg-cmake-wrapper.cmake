_find_package(${ARGS})

get_filename_component(_cmocka_lib_name ${CMOCKA_LIBRARY} NAME)

set(CMOCKA_LIBRARY
    debug ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/${_cmocka_lib_name}
    optimized ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/${_cmocka_lib_name}
)

set(CMOCKA_LIBRARIES ${CMOCKA_LIBRARY})

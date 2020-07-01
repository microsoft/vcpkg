_find_package(${ARGS})

get_filename_component(_cmocka_lib_name ${CMOCKA_LIBRARY} NAME)

set(CMOCKA_LIBRARY
    debug ${CURRENT_INSTALLED_DIR}/debug/lib/${_cmocka_lib_name}
    optimized ${CURRENT_INSTALLED_DIR}/lib/${_cmocka_lib_name}
)

set(CMOCKA_LIBRARIES ${CMOCKA_LIBRARY})

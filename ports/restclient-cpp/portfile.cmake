if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mrtazz/restclient-cpp
    REF fdf722bbab55d0838200dfbf2c3a2815741c8a7e #v2024-01-09
    SHA512 da1c0286b782c7baa3c40bf5bede5c78e0adde9a3172233cbdede792705b074c26e746f192cccb2eded4bf528f10d1fd5bc276fc1b6a3b9cc695fbeb9feadfff
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_GTest=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_jsoncpp=TRUE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/restclient-cpp)

vcpkg_copy_pdbs()

# Remove includes in debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

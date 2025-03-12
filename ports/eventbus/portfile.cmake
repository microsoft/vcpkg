if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

# before this revision the build would fail on windows
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gelldur/EventBus
    REF 4689564c4c775456bfa0dfd976b4f48aca5f4d2a
    SHA512 0f1f3c21d1c5a18da87e331f252cb464143ba2038a26e6edb6b11c9544c02dd1919fe728e803b382e8f6b89550582d7905170437c184f784cfa3f28c784a7e59
    HEAD_REF master
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
        -DENABLE_TEST=OFF 
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/EventBus)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

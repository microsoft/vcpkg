if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mrtazz/restclient-cpp
    REF "${VERSION}"
    SHA512 d1d192b6aeb84735c978a6e419077d93c067f1de282b773bd09c06ee2f6ad40e4a40a832ab9e568a8d9f92daa4411cc9b61f3e72f202c91e85049e2055160ca2
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

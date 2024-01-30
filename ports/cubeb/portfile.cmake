vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mozilla/cubeb
    REF f1bfefbbd412eaa0fe89f5afb3c11b427dc2446a
    SHA512 541bdcdc17c02f51e6faae1c90e0ddf30f40b137bb47498f7845919107190a4acb97d88e26ccf4877dbce7aeddee0f6538fd34c71396bc6a81644438a1a3242e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DUSE_SANITIZERS=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_TOOLS=OFF
        -DDOXYGEN_EXECUTABLE= # Prevents the generation of documentation
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cubeb)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

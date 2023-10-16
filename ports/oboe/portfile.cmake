vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/oboe
    REF 1.7-stable
    SHA512 2b89b9ba40e3b1f6f8d2b7ab4f7ef5bfec70d89e1f93b85cc01ab30793c50a5d4a550a768e0ddf3050614f54b98c00b3847c25e9ff7cfc0698cfbb4910102321
    HEAD_REF master
    PATCHES
        fix_install.patch
)

set(CMAKE_ARGS "")

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(CMAKE_ARGS "-DBUILD_SHARED_LIBS=true -DANDROID_STL=c++_shared")
else()
    set(CMAKE_ARGS "-DBUILD_SHARED_LIBS=false")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DOBOE_EXAMPLES=OFF
        ${CMAKE_ARGS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

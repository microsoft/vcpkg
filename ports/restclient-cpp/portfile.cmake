include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mrtazz/restclient-cpp
    REF 6336cae5275c9aeddf99f13c49e8f9320f7ca4bc
    SHA512 fbc638f82db8d0d101f4239152be67eb460659f3a7204db9523d3b5740b007b8fe434f78bf5d9f8059901aa639ba96c15b28b1e2fe5f09471accf64c2d577684 
    HEAD_REF master
    PATCHES
        0001_add_mt_msvc.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(COMPILE_TYPE SHARED)
else()
    set(COMPILE_TYPE STATIC)
endif()


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_GTest=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_jsoncpp=TRUE
        -DCOMPILE_TYPE=${COMPILE_TYPE}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/restclient-cpp)

# Remove includes in debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/restclient-cpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/restclient-cpp/LICENSE ${CURRENT_PACKAGES_DIR}/share/restclient-cpp/copyright)

# Copy pdb files
vcpkg_copy_pdbs()

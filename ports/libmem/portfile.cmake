vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rdbo/libmem
    REF 5.0.2
    SHA512 d7c5a1a42d65a00ed3aa8ba8f6974650801d3436ae90e072fea29d4dcb32a3963e2610c89a16b87d94a9613c8f2f0e8deb83b673a1771a9cd1eb716a56106a16
    HEAD_REF master
)

vcpkg_from_git(
    OUT_SOURCE_PATH CAPSTONE_PATH
    URL https://github.com/aquynh/capstone
    REF dec87d6190c682227f554f5721cf7b00b58bdad5
)

vcpkg_from_git(
    OUT_SOURCE_PATH KEYSTONE_PATH
    URL https://github.com/keystone-engine/keystone
    REF 2ba6b8c5e76fa66942e3122b495206f6c974834a
)

vcpkg_from_git(
    OUT_SOURCE_PATH VCVARS_PATH
    URL https://github.com/nathan818fr/vcvars-bash
    REF 7041b84cb3e035a0351430a817dff4ed6a16dfd7
)

set(EXTERNAL_DIR ${SOURCE_PATH}/external)

file(MAKE_DIRECTORY ${EXTERNAL_DIR})

file(COPY ${CAPSTONE_PATH}/ DESTINATION ${EXTERNAL_DIR}/capstone)

file(COPY ${KEYSTONE_PATH}/ DESTINATION ${EXTERNAL_DIR}/keystone)

file(COPY ${VCVARS_PATH}/ DESTINATION ${EXTERNAL_DIR}/vcvars-bash)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DCMAKE_C_FLAGS_RELEASE="/MD ${VCPKG_CMAKE_FLAGS}"
        -DCMAKE_CXX_FLAGS_RELEASE="/MD ${VCPKG_CMAKE_FLAGS}"
        -DCMAKE_C_FLAGS_DEBUG="/MDd ${VCPKG_CMAKE_FLAGS}"
        -DCMAKE_CXX_FLAGS_DEBUG="/MDd ${VCPKG_CMAKE_FLAGS}"
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

#vcpkg_fixup_cmake_targets(CONFIG_PATH lib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

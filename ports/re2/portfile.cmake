include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/re2
    REF d9cebde0175aa1ffd38aab9a395a038464d55ce7
    SHA512 820ebc96f6cc583e50bdd637b8bf6b4e8ef6be5a74a49174bf845d037f0dd21ee3b1fbc220bc3cbbd6987205195b6c0990040f43da723f90038a20690a7553ff
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DRE2_BUILD_TESTING=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/re2 RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

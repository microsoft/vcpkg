#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ryanhaining/cppitertools
    REF d716cf6c8281ab6383d1fbecb456e0b9d808694c
    SHA512 47bc490d798b445e965169a754dc977d5add217f133130671301dee6294744fa4b3f7a3b146cbd002c31325e5bc7c2206d57560a6db58693ca13ca972ca09d39
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib 
                    ${CURRENT_PACKAGES_DIR}/debug 
                    ${CURRENT_PACKAGES_DIR}/share/doc)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppitertools RENAME copyright)
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jtv/libpqxx
    REF ff7bf80ea942fd91a6ce526405ecbc64131f634f # 6.4.7
    SHA512 e4f94ecee4ac0b67059f8381a4f71798793b69d5da8762cdf665909e4209d2cde88a77358e04e60c524ee369b2a91325e309273e1ca12648c05b5aacdb832b71
    HEAD_REF master
    PATCHES
        fix-deprecated-bug.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config-public-compiler.h.in DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config-internal-compiler.h.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libpqxx RENAME copyright)

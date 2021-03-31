vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bitdefender/bddisasm
    REF v1.32.1
    SHA512 78062081ab38f208c29e1a8cd50daad9203c93ab68cb3e48250fc3b38b7bfdb6a878a995c353f63ac7a6144f305dbdc0f5d60d67558f0403a669197979143de1
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS -DBDD_INCLUDE_TOOL=OFF
)

vcpkg_install_cmake()

file(INSTALL
    ${CURRENT_PORT_DIR}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/bddisasm TARGET_PATH share/bddisasm)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO axiomatic-systems/Bento4
    REF 83c48e6e2a3f8e4be7ad2eddaa0639303184146d # v1.6.0-639
    SHA512 764c1102dc1e2a0f48395427b5b0a96f87d7124cceb61eb24008f245cf1f5f057753307c38f6f7e74d6838d6600c436d8540e94cbca12385cb4fffb02995069b
    HEAD_REF master 
    PATCHES
        fix-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_APPS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/Documents/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

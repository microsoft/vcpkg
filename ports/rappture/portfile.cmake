vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AenBleidd/rappture
    REF 03982392195b0d9768532a1ea7cfb9bf909a1d04
    SHA512 9acfa5e08803016a815cf275429e0b2315f00fc17c87eb362a978c68a21138855c57bacc0b443e260e004871daef750374c47103fa16257d70628542e74eb63b
    HEAD_REF master
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/rappture.patch"
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(
    INSTALL ${SOURCE_PATH}/license.terms
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)

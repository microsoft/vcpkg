include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO htacg/tidy-html5
    REF 5.4.0
    SHA512 d92c89f2ef371499f9c3de6f9389783d2449433b4da1f5a29e2eb81b7a7db8dd9f68e220cdde092d446e9bd779bcbc30f84bda79013526540f29d00f438cb402
    HEAD_REF master)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/remove_execution_character_set.patch
)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON -DBUILD_SHARED_LIB=ON -DTIDY_CONSOLE_SHARED=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/tidyd.exe)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/tidy.exe ${CURRENT_PACKAGES_DIR}/tools/tidy.exe)
file(INSTALL ${SOURCE_PATH}/README/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/tidy-html5 RENAME copyright)

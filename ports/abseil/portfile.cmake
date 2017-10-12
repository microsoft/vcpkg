include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Abseil currently only supports being built for desktop")
endif()

message("NOTE: THIS PORT IS USING AN UNOFFICIAL BUILDSYSTEM. THE BINARY LAYOUT AND CMAKE INTEGRATION WILL CHANGE IN THE FUTURE.")
message("To use from cmake:\n  find_package(unofficial-abseil REQUIRED)\n  link_libraries(unofficial::abseil::strings)")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF cdf20caa491f59c0a35a8d8fbec0d948e4bc7e4c
    SHA512 04889e7804b644821d0bf5d1b13f15a072e748bf0465442c64528e014c71f415544e9146c9518f9fe7bb14a295b18f293c3f7b672f6a51dba9909f3b74667fae
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-intrin.patch"
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-abseil)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/abseil ${CURRENT_PACKAGES_DIR}/share/unofficial-abseil)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/abseil RENAME copyright)

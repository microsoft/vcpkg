include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Abseil currently only supports being built for desktop")
endif()

message("NOTE: THIS PORT IS USING AN UNOFFICIAL BUILDSYSTEM. THE BINARY LAYOUT AND CMAKE INTEGRATION WILL CHANGE IN THE FUTURE.")
message("To use from cmake:\n  find_package(unofficial-abseil REQUIRED)\n  link_libraries(unofficial::abseil::strings)")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF 1a9ba5e2e5a14413704f0c913fac53359576d3b6
    SHA512 756e494c30324c937ca655d91afdee9acb923c7ee837a7c685441305bea2d54a75b3b21be7355abe416660984ba51ace9d234d70168fb029c601b7442397e8ff
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-abseil)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/abseil ${CURRENT_PACKAGES_DIR}/share/unofficial-abseil)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/abseil RENAME copyright)

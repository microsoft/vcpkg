include(vcpkg_common_functions)

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    message(FATAL_ERROR "This portfile does not support Linux or OSX")
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/angle
    REF ms-master
    SHA512 eecdb7012c0630b24fde540fb6a558f4ee5326fc1218773b779953d0fe0ef02da68ceb2577822cfc0374392a88b871201bfe291e3b85c3dd005edc83f84fec1f
    PATCHES
    PATCHES
        001-fix-uwp.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=1
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-angle RENAME copyright)

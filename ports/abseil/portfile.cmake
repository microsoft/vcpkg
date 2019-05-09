include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Abseil currently only supports being built for desktop")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abseil/abseil-cpp
    REF cd86d0d20ab167c33b23d3875db68d1d4bad3a3b
    SHA512 88e3edf395a11bdcd09d831dee3fad14a556761aafbc207e09ce17865e0663d9039a7d7954c95576270f7207cd00176b2ea107c61c6a059a5627c6fe062a66b5
    HEAD_REF master
    PATCHES fix-usage-lnk-error.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-abseil TARGET_PATH share/unofficial-abseil)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/abseil RENAME copyright)

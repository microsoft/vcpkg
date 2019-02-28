include(vcpkg_common_functions)

if (TARGET_TRIPLET MATCHES "^x(86|64)-windows$" AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(WARNING "\
The author of imgui strongly advises users of this lib against using a DLL. \
For more details, please visit: \
https://github.com/Microsoft/vcpkg/issues/5110"
    )
endif ()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF v1.68
    SHA512 4a7996f188816eb1caa3130546fbfbe2069a8a338daf0540ae09e7c7d6a40082e25144e91c94f53d7ff6023925c92ce591e4d59614e08b1ca7b91097519bf4a4
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DIMGUI_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/imgui)

configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/imgui/copyright COPYONLY)

include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF 2da1c66d151aec08aee06be4c5948b3cd256a617
    SHA512 fe73a6d786d0536669c7fbfb7e2e31e5f7e9e61998521439b299b1e700c9bd9e52172abdd68bb82706296d1b57ebcb4eb7e4c48abdb94639305b5701c959eae3
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
vcpkg_fixup_cmake_targets()

configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/imgui/copyright COPYONLY)

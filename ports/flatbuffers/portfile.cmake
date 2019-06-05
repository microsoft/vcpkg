include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/flatbuffers
    REF v1.10.0
    SHA512 b8382c8e9a45d6aca83270e93704b9ef2938e4ef9bb5165edbd8f286329e86353037ad6e54a99fd3d70b0c893d06cfd8766e00f05497e69be4b9e6c0506133d2
    HEAD_REF master
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/ignore_use_of_cmake_toolchain_file.patch
        ${CMAKE_CURRENT_LIST_DIR}/no-werror.patch
)

set(OPTIONS)
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    list(APPEND OPTIONS -DFLATBUFFERS_BUILD_FLATC=OFF -DFLATBUFFERS_BUILD_FLATHASH=OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFLATBUFFERS_BUILD_TESTS=OFF
        -DFLATBUFFERS_BUILD_GRPCTEST=OFF
        ${OPTIONS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/flatbuffers")

file(GLOB flatc_path ${CURRENT_PACKAGES_DIR}/bin/flatc*)
if(flatc_path)
    make_directory(${CURRENT_PACKAGES_DIR}/tools/flatbuffers)
    get_filename_component(flatc_executable ${flatc_path} NAME)
    file(
        RENAME
        ${flatc_path}
        ${CURRENT_PACKAGES_DIR}/tools/flatbuffers/${flatc_executable}
    )
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/flatbuffers)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/flatbuffers)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/flatbuffers/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/flatbuffers/copyright)

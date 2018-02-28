if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  message(FATAL_ERROR "scintilla only supports dynamic linkage")
endif()
if(VCPKG_CRT_LINKAGE STREQUAL "static")
  message(FATAL_ERROR "scintilla only supports dynamic crt")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO torch/torch7
    REF 89ede3ba90c906a8ec6b9a0f4bef188ba5bb2fd8
    SHA512 0b28762768129f5e59e24d505e271418bb4513db0e99acb293f01095949700711116463b299fe42d65ca07c1f0a9f6d0d1d72e21275a2825a4a9fb0197525e72
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/debug.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/lib/TH
    PREFER_NINJA
    OPTIONS
        -DWITH_OPENMP=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYRIGHT.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/torch-th RENAME copyright)

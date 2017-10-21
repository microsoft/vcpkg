include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "cpp-redis only supports static library linkage.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cylix/tacopie
    REF 2.4.1
    SHA512 a1579080412114d3899492cd9559bb0eadd6048c1f84ac66ec8ca47bd6fbb35306f0d203d789bd1b7ed0a0a5ab27434dfe6583a1c67873c85bca4b6e2a186d77
    HEAD_REF master
)

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(MSVC_RUNTIME_LIBRARY_CONFIG "/MD")
else()
    set(MSVC_RUNTIME_LIBRARY_CONFIG "/MT")
endif()

# tacopie forcibly removes "/RTC1" in its cmake file. Because this is an ABI-sensitive flag, we need to re-add it in a form that won't be detected.
set(VCPKG_CXX_FLAGS_DEBUG "${VCPKG_CXX_FLAGS_DEBUG} -RTC1")
set(VCPKG_C_FLAGS_DEBUG "${VCPKG_C_FLAGS_DEBUG} -RTC1")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMSVC_RUNTIME_LIBRARY_CONFIG=${MSVC_RUNTIME_LIBRARY_CONFIG}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tacopie RENAME copyright)

vcpkg_copy_pdbs()

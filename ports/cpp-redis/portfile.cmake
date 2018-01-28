include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cylix/cpp_redis
    REF 4.3.0
    SHA512 d4a2865b72b4dfa80b6d3c004245014a77e74d4a3d254d6b0a9d50e890a22dc3d9ce54688a8c9185ecee9bbf8cdf76046a9788c70887ccf8a08d5cdcef298b46
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-cmakelists.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-export.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/tacopie/CMakeLists.txt DESTINATION ${SOURCE_PATH}/tacopie)

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(MSVC_RUNTIME_LIBRARY_CONFIG "/MD")
else()
    set(MSVC_RUNTIME_LIBRARY_CONFIG "/MT")
endif()

# cpp-redis forcibly removes "/RTC1" in its cmake file. Because this is an ABI-sensitive flag, we need to re-add it in a form that won't be detected.
set(VCPKG_CXX_FLAGS_DEBUG "${VCPKG_CXX_FLAGS_DEBUG} -RTC1")
set(VCPKG_C_FLAGS_DEBUG "${VCPKG_C_FLAGS_DEBUG} -RTC1")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMSVC_RUNTIME_LIBRARY_CONFIG=${MSVC_RUNTIME_LIBRARY_CONFIG}
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=TRUE
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB_RECURSE FILES "${CURRENT_PACKAGES_DIR}/include/*")
foreach(file ${FILES})
    file(READ ${file} _contents)
    string(REPLACE "ifndef __CPP_REDIS_USE_CUSTOM_TCP_CLIENT" "if 1" _contents "${_contents}")
    file(WRITE ${file} "${_contents}")
endforeach()

file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/lib ${CURRENT_PACKAGES_DIR}/debug/bin/bin DESTINATION ${CURRENT_PACKAGES_DIR}/debug)
file(COPY ${CURRENT_PACKAGES_DIR}/lib/lib ${CURRENT_PACKAGES_DIR}/bin/bin DESTINATION ${CURRENT_PACKAGES_DIR})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/lib ${CURRENT_PACKAGES_DIR}/debug/bin/bin ${CURRENT_PACKAGES_DIR}/lib/lib ${CURRENT_PACKAGES_DIR}/bin/bin)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cpp-redis RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()

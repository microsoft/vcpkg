include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "cpp-redis only supports static library linkage.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cylix/cpp_redis
    REF 3.5.2
    SHA512  d19445c93fad9fba39c7aed07b2d196ec0c96366324a2a2ee856c930683b5428fe8b5bc46de4b2b23112aae83f8229a4703c2355d1c74831602ec3a7f8dac315
    HEAD_REF master
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
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB_RECURSE FILES "${CURRENT_PACKAGES_DIR}/include/*")
foreach(file ${FILES})
    file(READ ${file} _contents)
    string(REPLACE "ifndef __CPP_REDIS_USE_CUSTOM_TCP_CLIENT" "if 1" _contents "${_contents}")
    file(WRITE ${file} "${_contents}")
endforeach()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cpp-redis RENAME copyright)

vcpkg_copy_pdbs()

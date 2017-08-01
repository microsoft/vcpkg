include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "cpp-redis only supports static library linkage.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cylix/cpp_redis
    REF 3.5.1
    SHA512  2c50cf777d5955f7bcb94a55514fac444d0dcacc2df343dd89969889be7653a793620dbaac9d6dd0f444eee7f0664c4eb96a1d83477d207143660764afeea129
    HEAD_REF master
)

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(MSVC_RUNTIME_LIBRARY_CONFIG "/MD")
else()
    set(MSVC_RUNTIME_LIBRARY_CONFIG "/MT")
endif()

# cpp-redis forcibly removes "/RTC1" in its cmake file. Because this is an ABI-sensitive flag, we need to re-add it in a form that won't be detected.
list(APPEND VCPKG_CXX_FLAGS_DEBUG "-RTC1")
list(APPEND VCPKG_C_FLAGS_DEBUG "-RTC1")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_CUSTOM_TCP_CLIENT=TRUE
        -DMSVC_RUNTIME_LIBRARY_CONFIG=${MSVC_RUNTIME_LIBRARY_CONFIG}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB_RECURSE FILES "${CURRENT_PACKAGES_DIR}/include/*")
foreach(file ${FILES})
    file(READ ${file} _contents)
    string(REPLACE "ifndef __CPP_REDIS_USE_CUSTOM_TCP_CLIENT" "if 0" _contents "${_contents}")
    file(WRITE ${file} "${_contents}")
endforeach()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cpp-redis RENAME copyright)

vcpkg_copy_pdbs()

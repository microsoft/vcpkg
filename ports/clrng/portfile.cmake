vcpkg_fail_port_install(ON_ARCH "arm64")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO clMathLibraries/clRNG
    REF 4a16519ddf52ee0a5f0b7e6288b0803b9019c13b
    SHA512 28bda5d2a156e7394917f8c40bd1e8e7b52cf680abc0ef50c2650b1d546c0a1d0bd47ceeccce3cd7c79c90a15494c3d27829e153613a7d8e18267ce7262eeb6e
    HEAD_REF master
    PATCHES
        001-build-fixup.patch
)

file(REMOVE ${SOURCE_PATH}/src/FindOpenCL.cmake)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND NOT VCPKG_CMAKE_SYSTEM_NAME)
    set(R123_SSE_FLAG [[-DCMAKE_C_FLAGS="/DR123_USE_SSE=0"]])
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(SHARED_LIBRARY_FLAG "-DBUILD_SHARED_LIBRARY=ON")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(SHARED_LIBRARY_FLAG "-DBUILD_SHARED_LIBRARY=OFF")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(BUILD_64_FLAG "-DBUILD64=ON")
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BUILD_64_FLAG "-DBUILD64=OFF")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/src
    PREFER_NINJA
    OPTIONS
        ${SHARED_LIBRARY_FLAG}
        ${BUILD_64_FLAG}
        -DBUILD_TEST=OFF
        -DBUILD_CLIENT=OFF
        ${R123_SSE_FLAG}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(
        REMOVE_RECURSE
            "${CURRENT_PACKAGES_DIR}/bin"
            "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(
        GLOB DEBUG_CRT_FILES
            ${CURRENT_PACKAGES_DIR}/debug/bin/concrt*.dll
            ${CURRENT_PACKAGES_DIR}/debug/bin/msvcp*.dll
            ${CURRENT_PACKAGES_DIR}/debug/bin/vcruntime*.dll)
    file(REMOVE ${DEBUG_CRT_FILES})
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/clRNG)

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

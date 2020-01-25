set(OATPP_VERSION "0.19.12")

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()
if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
  message(FATAL_ERROR "${PORT} does not support ARM")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

message(STATUS "Building oatpp-libressl")

# get the source
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-libressl
    REF 1fe8f1dd5d6586718885fce3ab23148c153d50dc # 0.19.12
    SHA512 f1d513ed8eb66fac5bd408f97ddb87bb8141c7c58826b466f7b9f7a6dda79368ec80282d852c8da5ebf12bdd15e9e8564d4fea3d287554062f9dc6a86ffb4e9d
    HEAD_REF master
    PATCHES "libress-submodule-downgrade-required-libressl-version.patch"
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(OATPP_BUILD_SHARED_LIBRARIES_OPTION "ON")
else()
    set(OATPP_BUILD_SHARED_LIBRARIES_OPTION "OFF")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"
        "-DCMAKE_CXX_FLAGS=-D_CRT_SECURE_NO_WARNINGS"
        "-DLIBRESSL_ROOT_DIR=${CURRENT_INSTALLED_DIR}"
        "-DBUILD_SHARED_LIBS:BOOL=${OATPP_BUILD_SHARED_LIBRARIES_OPTION}"
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-libressl-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

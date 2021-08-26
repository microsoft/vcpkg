vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK
    REF 960c4a6aa8cc9f47e357c696b5377d817550bf88
    SHA512 515494520a31491587418ab6cb1b28333481e0a20cb25d3f9bc875ac211faf1636641afdfee2ecdf816ea1222305ea52565992953b3bab68fffe40fa25e23145
    HEAD_REF master
    PATCHES
        fix-openxr-sdk-jsoncpp.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SDK_SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK-Source
    REF 09cbbc9d3bc540a53d5f2d76b8074ddc0b96e933
    SHA512 1fc777d7aaea585dd8e9f9ac60a71a7eb55017183f33e51f987b94af6bba8d7808771abf9fc377c6e2b613f282db08a095595b4bc6899d4eaa6eabb45405dc1b
    HEAD_REF master
    PATCHES
        fix-openxr-sdk-jsoncpp.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH HPP_SOURCE_PATH
    REPO KhronosGroup/OpenXR-hpp
    REF 6fcea9e472622c9c7f4df0b5f0bfe7ff5d8553f7
    SHA512 04d1f9db6fd0a01cdf3274089ab17bf17974ff799b4690561c16067e83710e1422a2aefd070b26023ff832eb58e6a3365297a818c9546ea4c531328bd1fb2de4
    HEAD_REF master
    PATCHES
        002-fix-hpp-gen.patch
)

# Weird behavior inside the OpenXR loader.  On Windows they force shared libraries to use static crt, and
# vice-versa.  Might be better in future iterations to patch the CMakeLists.txt for OpenXR
if (VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        set(DYNAMIC_LOADER OFF)
        set(VCPKG_CRT_LINKAGE dynamic)
    else()
        set(DYNAMIC_LOADER ON)
        set(VCPKG_CRT_LINKAGE static)
    endif()
endif()

vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_API_LAYERS=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_CONFORMANCE_TESTS=OFF
        -DDYNAMIC_LOADER=${DYNAMIC_LOADER}
        -DPYTHON_EXECUTABLE=${PYTHON3}
        -DBUILD_WITH_SYSTEM_JSONCPP=ON
)

vcpkg_install_cmake()

# Generate the OpenXR C++ bindings 
set(ENV{OPENXR_REPO} ${SDK_SOURCE_PATH})
file(STRINGS ${HPP_SOURCE_PATH}/headers.txt HEADER_LIST REGEX "^openxr.*")
foreach(HEADER ${HEADER_LIST})
    vcpkg_execute_required_process(
        COMMAND ${PYTHON3} ${HPP_SOURCE_PATH}/scripts/hpp_genxr.py -registry ${SDK_SOURCE_PATH}/specification/registry/xr.xml -o ${CURRENT_PACKAGES_DIR}/include/openxr ${HEADER}
        WORKING_DIRECTORY ${HPP_SOURCE_PATH}
        LOGNAME openxrhpp
    )
endforeach()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/OpenXR)
else(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/openxr TARGET_PATH share/OpenXR)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

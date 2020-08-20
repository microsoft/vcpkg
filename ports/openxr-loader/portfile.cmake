vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK
    REF e3a4e41d61544d8e2eba73f00da99b6818ec472b
    SHA512 26c6b547aa30d89895efcc835dddc3b58ab57f0e450a4ae82655a990a816dd57c70e43267a10da75b1c2bd160189942e443c8e27367d6648417d1c9c134e7694
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH SDK_SOURCE_PATH
    REPO KhronosGroup/OpenXR-SDK-Source
    REF 6dee6e228f47857adf5d7673eb90c64f04d33c60
    SHA512 0c522eef95b4d8bdc8e4f1ca852cd9798ff2bca9ef8511446d9cdf80bc314b0da454ab5c203658bbe43d3e7ff3d757b9427c3f75829b2a022a25041d1a2d2b12
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH HPP_SOURCE_PATH
    REPO KhronosGroup/OpenXR-hpp
    REF 097a7535563fc84bb7648ea9c5a4531a1e909458
    SHA512 fe953405724e9c4a8218cd269a23317ebc8164330a519eb82de75e832bc05e2c51d24bca24e4ce13724bf275c33b26f6646e25f29eeffe6840ffc552f3351ad0
    HEAD_REF master
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
)

vcpkg_install_cmake()

set(ENV{OPENXR_REPO} ${SDK_SOURCE_PATH})

vcpkg_execute_required_process(
    COMMAND ${PYTHON3} ${HPP_SOURCE_PATH}/scripts/hpp_genxr.py -registry ${SDK_SOURCE_PATH}/specification/registry/xr.xml -o ${CURRENT_PACKAGES_DIR}/include/openxr openxr.hpp
    WORKING_DIRECTORY ${HPP_SOURCE_PATH}
    LOGFILE openxrhpp
)

vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include/openxr
    PATCHES
        001-fix-array-decl.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/OpenXR)
else(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/openxr TARGET_PATH share/OpenXR)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()

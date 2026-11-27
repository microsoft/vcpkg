set(PATCHES
    "mark-threads-private.patch"
    "fix-dependency.patch"
)

if (VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    list(APPEND PATCHES "fix-osx-x64.patch")
endif()

if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    list(APPEND PATCHES "fix-win-arm64.patch")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anjo76/angelscript
    REF "v${VERSION}"
    SHA512 15adc23c5b3346e01b9925490827fb580d30ed5260967ac4f5155c1d55983a0a251130c1338b4b0dbcdd26f49505ae5dbd92d5ccff9724e88d75f6197659ad24
    HEAD_REF master
    PATCHES
        ${PATCHES}
)

string(APPEND SOURCE_PATH "/sdk")

if (VCPKG_TARGET_IS_ANDROID AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    vcpkg_replace_string("${SOURCE_PATH}/angelscript/source/as_callfunc_arm_gcc.S"
[[.globl armFuncObjLast       /* Make the function globally accessible.*/]]
[[.globl armFuncObjLast       /* Make the function globally accessible.*/
.type armFuncObjLast, %function]])
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/angelscript/projects/cmake"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Angelscript")

# Copy the addon files
if("addons" IN_LIST FEATURES)
    file(INSTALL "${SOURCE_PATH}/add_on/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/angelscript" FILES_MATCHING PATTERN "*.h" PATTERN "*.cpp")
endif()

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/../LICENSE.md"
)

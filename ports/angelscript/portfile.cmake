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
    SHA512 50797b0626377a403fcbb3bffbc349e06c95081d4f3cba5a465e31990fdaeea051fefecfb7ead1a4fcf77419eb54b9c22a4632f968f62d36349890971e4f5796
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

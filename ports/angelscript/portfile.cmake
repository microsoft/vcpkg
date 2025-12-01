vcpkg_download_distfile(ARCHIVE
    URLS "https://angelcode.com/angelscript/sdk/files/angelscript_${VERSION}.zip"
    FILENAME "angelscript_${VERSION}.zip"
    SHA512 87c94042932f15d07fe6ede4c3671b1f73ac757b68ab360187591497eeabc56a4ddb7901e4567108e44886a2011a29c2884d4b7389557826f36a6c384f4a9c69
)

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

if (VCPKG_TARGET_IS_ANDROID AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    list(APPEND PATCHES "fix-ndk-arm.patch")
endif()

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        ${PATCHES}
)

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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/docs/manual/doc_license.html")

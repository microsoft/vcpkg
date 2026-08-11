message(
    "${PORT} requires Microsoft Visual Studio with the C++ workload and the Windows Driver Kit (WDK) to build consuming drivers."
)

vcpkg_check_linkage(
    ONLY_STATIC_LIBRARY
    ONLY_STATIC_CRT
)

if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_MINGW)
    message(FATAL_ERROR "crtsys supports Windows desktop MSVC/WDK triplets only.")
endif()

vcpkg_download_distfile(CRTSYS_ARCHIVE
    URLS
        "https://github.com/ntoskrnl7/crtsys/releases/download/v${VERSION}/crtsys-${VERSION}-prebuilt.zip"
    FILENAME
        "crtsys-${VERSION}-prebuilt.zip"
    SHA512
        96dfdd5c40895c6e4cea20d1176e90daa47164f00daf4bc96ef896077579a96a0b7f7124519a903bb9610bb900752681bf5bb3bbe104f6e6f644db76c12322ab
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${CRTSYS_ARCHIVE}"
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(CRTSYS_PACKAGE_ARCHITECTURE "ARM")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(CRTSYS_PACKAGE_ARCHITECTURE "ARM64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR
       VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(CRTSYS_PACKAGE_ARCHITECTURE "${VCPKG_TARGET_ARCHITECTURE}")
else()
    message(FATAL_ERROR
        "crtsys does not provide prebuilt libraries for ${VCPKG_TARGET_ARCHITECTURE}.")
endif()

file(INSTALL "${SOURCE_PATH}/include"
    DESTINATION "${CURRENT_PACKAGES_DIR}")
file(INSTALL "${SOURCE_PATH}/lib"
    DESTINATION "${CURRENT_PACKAGES_DIR}")
file(INSTALL "${SOURCE_PATH}/build"
    DESTINATION "${CURRENT_PACKAGES_DIR}")
file(INSTALL "${SOURCE_PATH}/share/crtsys/cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/crtsys")

# A crtsys release carries several MSVC toolsets and architectures. Keep all
# toolsets so the package follows the consuming WDK project, but retain only
# the architecture represented by the selected vcpkg triplet.
function(crtsys_keep_package_architecture ROOT_DIRECTORY)
    if(NOT EXISTS "${ROOT_DIRECTORY}")
        return()
    endif()

    file(GLOB CRTSYS_TOOLSET_DIRECTORIES LIST_DIRECTORIES TRUE
        "${ROOT_DIRECTORY}/v*")
    foreach(CRTSYS_TOOLSET_DIRECTORY IN LISTS CRTSYS_TOOLSET_DIRECTORIES)
        if(NOT IS_DIRECTORY "${CRTSYS_TOOLSET_DIRECTORY}")
            continue()
        endif()

        file(GLOB CRTSYS_ARCHITECTURE_DIRECTORIES LIST_DIRECTORIES TRUE
            "${CRTSYS_TOOLSET_DIRECTORY}/*")
        foreach(CRTSYS_ARCHITECTURE_DIRECTORY IN LISTS CRTSYS_ARCHITECTURE_DIRECTORIES)
            if(NOT IS_DIRECTORY "${CRTSYS_ARCHITECTURE_DIRECTORY}")
                continue()
            endif()

            get_filename_component(CRTSYS_ARCHITECTURE_NAME
                "${CRTSYS_ARCHITECTURE_DIRECTORY}" NAME)
            if(NOT CRTSYS_ARCHITECTURE_NAME STREQUAL CRTSYS_PACKAGE_ARCHITECTURE)
                file(REMOVE_RECURSE "${CRTSYS_ARCHITECTURE_DIRECTORY}")
            endif()
        endforeach()
    endforeach()
endfunction()

crtsys_keep_package_architecture("${CURRENT_PACKAGES_DIR}/lib/native")
crtsys_keep_package_architecture(
    "${CURRENT_PACKAGES_DIR}/build/native/codecs/lib")
crtsys_keep_package_architecture(
    "${CURRENT_PACKAGES_DIR}/build/native/kernel-codecs/lib")

file(INSTALL "${CURRENT_PORT_DIR}/crtsys-vcpkg.targets"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/crtsys/msbuild")
file(INSTALL
    "${CURRENT_PORT_DIR}/tools/crtsys-vs-init.ps1"
    "${CURRENT_PORT_DIR}/tools/crtsys-vs-init.cmd"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${CURRENT_PORT_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/README.md"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME "readme.md")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/docs/third-party-notices.md"
    "${CURRENT_PORT_DIR}/ldk-copyright"
)

# Debug and Release archives intentionally share crtsys' toolset-specific
# lib/native tree. CrtSys.cmake and the MSBuild integration select the correct
# configuration explicitly rather than relying on vcpkg autolinking.
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

# Ldk.lib retains /DEFAULTLIB directives from its MSVC compilation, but crtsys
# consumes it only in a WDK kernel link where crtsys supplies the runtime and
# the driver target is compiled with /MT. vcpkg's user-mode CRT inspection
# therefore cannot classify this archive correctly.
set(VCPKG_POLICY_SKIP_CRT_LINKAGE_CHECK enabled)

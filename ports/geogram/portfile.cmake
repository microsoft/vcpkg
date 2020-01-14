include(vcpkg_common_functions)

set(GEOGRAM_VERSION 1.6.9)

vcpkg_download_distfile(ARCHIVE
    URLS "https://gforge.inria.fr/frs/download.php/file/37779/geogram_${GEOGRAM_VERSION}.tar.gz"
    FILENAME "geogram_${GEOGRAM_VERSION}.tar.gz"
    SHA512 1b5c7540bef734c1908f213f26780aba63b4911a8022d5eb3f7c90eabe2cb69efd1f298b30cdc8e2c636a5b37c8c25832dd4aad0b7c2ff5f0a5b5caa17970136
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GEOGRAM_VERSION}
    PATCHES
        fix-cmake-config-and-install.patch
)

file(COPY ${CURRENT_PORT_DIR}/Config.cmake.in DESTINATION ${SOURCE_PATH}/cmake)

set(GEOGRAM_WITH_GRAPHICS OFF)
if("graphics" IN_LIST FEATURES)
    set(GEOGRAM_WITH_GRAPHICS ON)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(VORPALINE_BUILD_DYNAMIC FALSE)
    if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME MATCHES "WindowsStore")
        set(VORPALINE_PLATFORM Win-vs-generic)
    endif()
    if (VCPKG_CMAKE_SYSTEM_NAME MATCHES "Linux")
        message("geogram on Linux only supports dynamic library linkage. Building dynamic.")
        set(VCPKG_LIBRARY_LINKAGE dynamic)
        set(VORPALINE_PLATFORM Linux64-gcc-dynamic )
    endif()
    if (VCPKG_CMAKE_SYSTEM_NAME MATCHES "Darwin")
        message("geogram on Darwin only supports dynamic library linkage. Building dynamic.")
        set(VCPKG_LIBRARY_LINKAGE dynamic)
        set(VORPALINE_PLATFORM Darwin-clang-dynamic)
    endif()
else()
    set(VORPALINE_BUILD_DYNAMIC TRUE)
    if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME MATCHES "WindowsStore")
        set(VORPALINE_PLATFORM Win-vs-generic)
    endif()
    if (VCPKG_CMAKE_SYSTEM_NAME MATCHES "Linux")
        set(VORPALINE_PLATFORM Linux64-gcc-dynamic )
    endif()
    if (VCPKG_CMAKE_SYSTEM_NAME MATCHES "Darwin")
        set(VORPALINE_PLATFORM Darwin-clang-dynamic)
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # Geogram cannot be built with ninja because it embeds $(Configuration) in some of the generated paths. These require MSBuild in order to be evaluated.
    #PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DVORPALINE_BUILD_DYNAMIC=${VORPALINE_BUILD_DYNAMIC}
        -DGEOGRAM_WITH_GRAPHICS=${GEOGRAM_WITH_GRAPHICS}
        -DGEOGRAM_LIB_ONLY=ON
        -DGEOGRAM_USE_SYSTEM_GLFW3=ON
        -DVORPALINE_PLATFORM=${VORPALINE_PLATFORM}
        -DGEOGRAM_WITH_VORPALINE=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(READ ${CURRENT_PACKAGES_DIR}/share/geogram/GeogramTargets.cmake TARGET_CONFIG)
string(REPLACE [[INTERFACE_INCLUDE_DIRECTORIES "/src/lib;${_IMPORT_PREFIX}/include"]]
               [[INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"]] TARGET_CONFIG "${TARGET_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/geogram/GeogramTargets.cmake "${TARGET_CONFIG}")

# Handle copyright
file(COPY ${SOURCE_PATH}/doc/devkit/license.dox DESTINATION ${CURRENT_PACKAGES_DIR}/share/geogram)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/geogram/license.dox ${CURRENT_PACKAGES_DIR}/share/geogram/copyright)

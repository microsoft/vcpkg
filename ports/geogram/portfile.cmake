set(GEOGRAM_VERSION 1.7.5)
vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_download_distfile(ARCHIVE
    URLS "https://gforge.inria.fr/frs/download.php/file/38314/geogram_${GEOGRAM_VERSION}.tar.gz"
    FILENAME "geogram_${GEOGRAM_VERSION}_47dcbb8.tar.gz"
    SHA512 47dcbb8a5c4e5f791feb8d9b209b04b575b0757e8b89de09c82ef2324a36d4056a1f3001537038c8a752045b0e6b6eedf5421ad49132214c0f60163ff095c36f
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GEOGRAM_VERSION}
    PATCHES
        fix-cmake-config-and-install.patch
        fix-windows-dynamic.patch
)

file(COPY ${CURRENT_PORT_DIR}/Config.cmake.in DESTINATION ${SOURCE_PATH}/cmake)


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    "graphics" GEOGRAM_WITH_GRAPHICS
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(VORPALINE_BUILD_DYNAMIC FALSE)
    if (VCPKG_TARGET_IS_WINDOWS)
        set(VORPALINE_PLATFORM Win-vs-generic)
    endif()
    if (VCPKG_CRT_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS)
        message("geogram on Windows with CRT dynamic linkage only supports dynamic library linkage. Building dynamic.")
        set(VCPKG_LIBRARY_LINKAGE dynamic)
        set(VORPALINE_PLATFORM Win-vs-dynamic-generic)
    endif()
    if (VCPKG_TARGET_IS_LINUX)
        message("geogram on Linux only supports dynamic library linkage. Building dynamic.")
        set(VCPKG_LIBRARY_LINKAGE dynamic)
        set(VORPALINE_PLATFORM Linux64-gcc-dynamic )
    endif()
    if (VCPKG_TARGET_IS_OSX)
        message("geogram on Darwin only supports dynamic library linkage. Building dynamic.")
        set(VCPKG_LIBRARY_LINKAGE dynamic)
        set(VORPALINE_PLATFORM Darwin-clang-dynamic)
    endif()
else()
    set(VORPALINE_BUILD_DYNAMIC TRUE)
    if (VCPKG_TARGET_IS_WINDOWS)
        set(VORPALINE_PLATFORM Win-vs-generic)
    endif()
    if (VCPKG_TARGET_IS_LINUX)
        set(VORPALINE_PLATFORM Linux64-gcc-dynamic )
    endif()
    if (VCPKG_TARGET_IS_OSX)
        set(VORPALINE_PLATFORM Darwin-clang-dynamic)
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # Geogram cannot be built with ninja because it embeds $(Configuration) in some of the generated paths. These require MSBuild in order to be evaluated.
    #PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DVORPALINE_BUILD_DYNAMIC=${VORPALINE_BUILD_DYNAMIC}
        -DGEOGRAM_LIB_ONLY=ON
        -DGEOGRAM_USE_SYSTEM_GLFW3=ON
        -DVORPALINE_PLATFORM=${VORPALINE_PLATFORM}
        -DGEOGRAM_WITH_VORPALINE=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/share/geogram/GeogramTargets.cmake
    [[INTERFACE_INCLUDE_DIRECTORIES "/src/lib;${_IMPORT_PREFIX}/include"]]
    [[INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"]]
    )

# Handle copyright
file(INSTALL ${SOURCE_PATH}/doc/devkit/license.dox DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alicevision/geogram
    REF 8b2ae6148c7ab1564fa2700673b4275296ce80d3 #1.7.6
    SHA512 0ec0deded92c8d5d100b6e77f8cfbbbaf7b744c230e10abd0b86861960cda9713ff65209575fdc09034afcb0e9137428a20c00d399c09fd58ce541fed2105a2d
    PATCHES
        fix-vcpkg-install.patch
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

vcpkg_fixup_pkgconfig()

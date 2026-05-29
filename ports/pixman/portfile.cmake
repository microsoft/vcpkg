vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.freedesktop.org
    REPO pixman/pixman
    REF "pixman-${VERSION}"
    SHA512 f0abfef9bfd2d1c51995e1f4ffac0cedcd8e55dc2c404a5456f7673e837dd171613a8d4132744b10f0d3f7ec36726dc73f72c8cd109d954e904142d147b431b3
    PATCHES
        no-host-cpu-checks.patch
)

set(x86_architectures x86 x64)
if(VCPKG_TARGET_ARCHITECTURE IN_LIST x86_architectures AND NOT VCPKG_TARGET_IS_UWP)
    list(APPEND OPTIONS
        -Dmmx=enabled
        -Dsse2=enabled
        -Dssse3=enabled
    )
else()
    list(APPEND OPTIONS
        -Dmmx=disabled
        -Dsse2=disabled
        -Dssse3=disabled
    )
    if(VCPKG_TARGET_IS_ANDROID)
        vcpkg_cmake_get_vars(cmake_vars_file)
        include("${cmake_vars_file}")
        find_path(cpu_features_dir
            NAMES cpu-features.c
            PATHS "${VCPKG_DETECTED_CMAKE_ANDROID_NDK}"
            PATH_SUFFIXES
                "sources/android/cpufeatures" # NDK r27c
            NO_DEFAULT_PATH
        )
        if(VCPKG_DETECTED_CMAKE_ANDROID_ARM_NEON AND cpu_features_dir)
            list(APPEND OPTIONS
                "-Dcpu-features-path=${cpu_features_dir}"
            )
        endif()
    endif()
    if(VCPKG_TARGET_IS_WINDOWS)
        # -Darm-simd=enabled does not work with arm64-windows
        list(APPEND OPTIONS
            -Da64-neon=disabled
            -Darm-simd=disabled
            -Dneon=disabled
        )
    endif()
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
        -Ddemos=disabled
        -Dgtk=disabled
        -Dlibpng=enabled
        -Dtests=disabled
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

set(licenses "${SOURCE_PATH}/COPYING")
if(VCPKG_DETECTED_CMAKE_ANDROID_ARM_NEON AND cpu_features_dir)
    file(READ "${cpu_features_dir}/cpu-features.c" cpu_features_c)
    string(REGEX REPLACE "[*]/.*" "*/\n" cpu_features_license "${cpu_features_c}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/${TARGET_TRIPLET}-rel/cpu-features (BSD-2-Clause)" "${cpu_features_license}")
    list(APPEND licenses "${CURRENT_PACKAGES_DIR}/${TARGET_TRIPLET}-rel/cpu-features (BSD-2-Clause)")
endif()
vcpkg_install_copyright(FILE_LIST ${licenses})

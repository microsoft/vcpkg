vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mborgerding/kissfft
    REF "${VERSION}"
    SHA512 bd715868ce0e93a291a0592fb1f8b960e832fc64efe863755e52b67d5addff9bcb444a1bf2570d1914c52b41dad1023d0d86400f5ea30c9fb84cd6b4f7210708
    HEAD_REF master
    PATCHES
        fix-install-dirs.patch
        fix-linkage.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KISSFFT_STATIC)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp KISSFFT_OPENMP
        tools  KISSFFT_TOOLS
)

if("tools" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PKGCONFIG)
endif()

set(datatypes float double int16_t int32_t)

foreach(datatype IN LISTS datatypes)
    vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            -DKISSFFT_DATATYPE=${datatype}
            -DKISSFFT_PKGCONFIG=ON
            -DKISSFFT_TEST=OFF
            -DKISSFFT_STATIC=${KISSFFT_STATIC}
            ${FEATURE_OPTIONS}
        LOGFILE_BASE "config-${TARGET_TRIPLET}-${datatype}"
    )

    vcpkg_cmake_build(
        LOGFILE_BASE "install-${TARGET_TRIPLET}-${datatype}"
        TARGET install
    )

    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/kissfft")

    vcpkg_copy_pdbs()
endforeach()

vcpkg_fixup_pkgconfig()

if("tools" IN_LIST FEATURES)
    set(tool_names)

    foreach(datatype IN LISTS datatypes)
        if("openmp" IN_LIST FEATURES)
            list(APPEND tool_names
                "fastconv-${datatype}-openmp"
                "fastconvr-${datatype}-openmp"
                "fft-${datatype}-openmp"
                "psdpng-${datatype}-openmp"
            )
        else()
            list(APPEND tool_names
                "fastconv-${datatype}"
                "fastconvr-${datatype}"
                "fft-${datatype}"
                "psdpng-${datatype}"
            )
        endif()
    endforeach()

    vcpkg_copy_tools(
        TOOL_NAMES ${tool_names}
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/kissfft/kiss_fft.h"
        "#ifdef KISS_FFT_SHARED"
        "#if 1 //#ifdef KISS_FFT_SHARED"
    )
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/kissfft")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

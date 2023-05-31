vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mborgerding/kissfft
    REF 8f47a67f595a6641c566087bf5277034be64f24d
    SHA512 bd715868ce0e93a291a0592fb1f8b960e832fc64efe863755e52b67d5addff9bcb444a1bf2570d1914c52b41dad1023d0d86400f5ea30c9fb84cd6b4f7210708
    HEAD_REF master
    PATCHES
        fix-install-dirs.patch
        fix-find-libpng.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KISSFFT_STATIC)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        alloca KISSFFT_USE_ALLOCA
        openmp KISSFFT_OPENMP
        tools  KISSFFT_TOOLS
)

set(conflict_features)
set(datatype_features double float int16 int32 simd)

foreach(feature IN LISTS datatype_features)
    if(feature IN_LIST FEATURES)
        list(APPEND conflict_features "${feature}")
    endif()
endforeach()

list(LENGTH conflict_features conflict_features_length)
if(conflict_features_length GREATER_EQUAL 2)
    message(FATAL_ERROR "These datatype features are conflict: '${conflict_features}'")
endif()

if("float" IN_LIST FEATURES)
    set(KISSFFT_DATATYPE "float")
elseif("double" IN_LIST FEATURES)
    set(KISSFFT_DATATYPE "double")
elseif("int16" IN_LIST FEATURES)
    set(KISSFFT_DATATYPE "int16_t")
elseif("int32" IN_LIST FEATURES)
    set(KISSFFT_DATATYPE "int32_t")
elseif("simd" IN_LIST FEATURES)
    set(KISSFFT_DATATYPE "simd")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DKISSFFT_PKGCONFIG=ON
        -DKISSFFT_TEST=OFF
        -DKISSFFT_STATIC=${KISSFFT_STATIC}
        -DKISSFFT_DATATYPE=${KISSFFT_DATATYPE}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

vcpkg_fixup_pkgconfig()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            fastconv
            fastconvr
            fft
            psdpng
        AUTO_CLEAN
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/kissfft/kiss_fft.h"
        "#ifdef KISS_FFT_SHARED"
        "if 1 //#ifdef KISS_FFT_SHARED"
    )
endif()

if("double" IN_LIST FEATURES)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/kissfft/kiss_fft.h"
        "#   define kiss_fft_scalar float"
        "#   define kiss_fft_scalar double"
    )
elseif("int16" IN_LIST FEATURES)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/kissfft/kiss_fft.h"
        "#ifdef FIXED_POINT"
        "#define FIXED_POINT 16\n\n#ifdef FIXED_POINT"
    )
elseif("int32" IN_LIST FEATURES)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/kissfft/kiss_fft.h"
        "#ifdef FIXED_POINT"
        "#define FIXED_POINT 32\n\n#ifdef FIXED_POINT"
    )
elseif("simd" IN_LIST FEATURES)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/kissfft/kiss_fft.h"
        "#ifdef USE_SIMD"
        "if 1 //#ifdef USE_SIMD"
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

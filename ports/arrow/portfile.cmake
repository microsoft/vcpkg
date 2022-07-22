vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/arrow
    REF apache-arrow-8.0.0
    SHA512 08b6ab4a3c5e0dd9c46402da8e7b9ef9f918eea177413cb31695192dfdb5a472ebbfef255b8343fe775d81e8b5eb268c3428a699fac48b36bf808f5b81e83a64
    HEAD_REF master
    PATCHES
        vs-2022-fixes.patch
        all.patch
        fix-ThirdPartyToolchain.patch
)
file(REMOVE "${SOURCE_PATH}/cpp/cmake_modules/Findzstd.cmake"
            "${SOURCE_PATH}/cpp/cmake_modules/FindBrotli.cmake"
            "${SOURCE_PATH}/cpp/cmake_modules/Find-c-aresAlt.cmake"
            "${SOURCE_PATH}/cpp/cmake_modules/FindLz4.cmake"
            "${SOURCE_PATH}/cpp/cmake_modules/FindSnappy.cmake"
            "${SOURCE_PATH}/cpp/cmake_modules/FindThrift.cmake"
            "${SOURCE_PATH}/cpp/cmake_modules/FindGLOG.cmake"
            "${SOURCE_PATH}/cpp/cmake_modules/Findutf8proc.cmake"
            "${SOURCE_PATH}/cpp/cmake_modules/FindRapidJSONAlt.cmake"
            "${SOURCE_PATH}/cpp/cmake_modules/FindgRPCAlt.cmake"
            "${SOURCE_PATH}/cpp/cmake_modules/FindgflagsAlt.cmake"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        csv         ARROW_CSV
        dataset     ARROW_DATASET
        filesystem  ARROW_FILESYSTEM
        flight      ARROW_FLIGHT
        json        ARROW_JSON
        orc         ARROW_ORC
        parquet     ARROW_PARQUET
        parquet     PARQUET_REQUIRE_ENCRYPTION
        plasma      ARROW_PLASMA
        s3          ARROW_S3
        cuda        ARROW_CUDA
)

if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)
    set(MALLOC_OPTIONS -DARROW_JEMALLOC=OFF)
elseif("jemalloc" IN_LIST FEATURES)
    set(MALLOC_OPTIONS -DARROW_JEMALLOC=ON)
else()
    set(MALLOC_OPTIONS -DARROW_JEMALLOC=OFF)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND ("mimalloc" IN_LIST FEATURES))
    set(MALLOC_OPTIONS ${MALLOC_OPTIONS} -DARROW_MIMALLOC=ON)
else()
    set(MALLOC_OPTIONS ${MALLOC_OPTIONS} -DARROW_MIMALLOC=OFF)
endif()

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" ARROW_BUILD_SHARED)
string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "static" ARROW_BUILD_STATIC)
string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" ARROW_DEPENDENCY_USE_SHARED)

if(VCPKG_TARGET_IS_WINDOWS)
    set(THRIFT_USE_SHARED OFF)
else()
    set(THRIFT_USE_SHARED ${ARROW_DEPENDENCY_USE_SHARED})
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${MALLOC_OPTIONS}
        ${S3_OPTIONS}
        -DCMAKE_SYSTEM_PROCESSOR=${VCPKG_TARGET_ARCHITECTURE}
        -DARROW_BUILD_SHARED=${ARROW_BUILD_SHARED}
        -DARROW_BUILD_STATIC=${ARROW_BUILD_STATIC}
        -DARROW_BUILD_TESTS=OFF
        -DARROW_DEPENDENCY_SOURCE=SYSTEM
        -DARROW_DEPENDENCY_USE_SHARED=${ARROW_DEPENDENCY_USE_SHARED}
        -DARROW_THRIFT_USE_SHARED=${THRIFT_USE_SHARED} 
        -DBUILD_WARNING_LEVEL=PRODUCTION
        -DARROW_WITH_BROTLI=ON
        -DARROW_WITH_BZ2=ON
        -DARROW_WITH_LZ4=ON
        -DARROW_WITH_SNAPPY=ON
        -DARROW_WITH_ZLIB=ON
        -DARROW_WITH_ZSTD=ON
        -DZSTD_MSVC_LIB_PREFIX=
    MAYBE_UNUSED_VARIABLES
        ZSTD_MSVC_LIB_PREFIX
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/arrow_static.lib")
    message(FATAL_ERROR "Installed lib file should be named 'arrow.lib' via patching the upstream build.")
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/arrow)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")

configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake ${CURRENT_PACKAGES_DIR}/share/${PORT} @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(GLOB PARQUET_FILES ${CURRENT_PACKAGES_DIR}/share/${PORT}/Parquet*)
file(COPY ${PARQUET_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/share/parquet")
file(REMOVE_RECURSE ${PARQUET_FILES})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/FindParquet.cmake ${CURRENT_PACKAGES_DIR}/share/parquet/FindParquet.cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if ("plasma" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES plasma-store-server AUTO_CLEAN)
endif ()

vcpkg_fixup_pkgconfig()

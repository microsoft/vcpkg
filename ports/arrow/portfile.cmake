include(vcpkg_common_functions)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  message(FATAL_ERROR "Apache Arrow only supports x64")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/arrow
    REF apache-arrow-0.13.0
    SHA512 bbb14d11abf267a6902c7c9e0215ba7c5284f07482be2de42707145265d2809c89c2d4d8f8b918fdb8c33a5ecbd650875b987a1a694cdf653e766822be67a47d
    HEAD_REF master
)

set(CPP_SOURCE_PATH "${SOURCE_PATH}/cpp")

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" ARROW_BUILD_SHARED)
string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "static" ARROW_BUILD_STATIC)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "static" IS_STATIC)

if (IS_STATIC)
    set(PARQUET_ARROW_LINKAGE static)
    set(BOOST_USE_SHARED off)
    set(USE_STATIC_CRT on)
else()
    set(PARQUET_ARROW_LINKAGE shared)
    set(BOOST_USE_SHARED on)
    set(USE_STATIC_CRT off)
endif()

# Some dependencies get 'd' added to their name for debug builds. The convention should be that the names are the same,
# and vcpkg looks in the debug lib as a higher priority for debug builds. So I believe these dependencies are wrong.
# If that's the case, we have three options:
# 1) Fix the dependencies. This will break stuff.
# 2) Add to this port FindX.cmake files to override the behaviour.
# 3) Let's copy files around.
# Last option seems like the least worst.
if (NOT IS_STATIC)
    # Only do this for non-static builds because if we're static, linking doesn't happen yet so we can kick the can
    # down the road.
    
    # file(COPY ...) only lets you specify a directory to copy to, so if you want to copy you can't change the name.
    # Sneakily get round this by copying to tmp with the same name and then renaming it.
    file(COPY ${CURRENT_INSTALLED_DIR}/debug/lib/zlibd.lib DESTINATION ${CURRENT_INSTALLED_DIR}/debug/lib/tmp)
    file(RENAME ${CURRENT_INSTALLED_DIR}/debug/lib/tmp/zlibd.lib ${CURRENT_INSTALLED_DIR}/debug/lib/zlib.lib)
    file(COPY ${CURRENT_INSTALLED_DIR}/debug/lib/zstdd.lib DESTINATION ${CURRENT_INSTALLED_DIR}/debug/lib/tmp)
    file(RENAME ${CURRENT_INSTALLED_DIR}/debug/lib/tmp/zstdd.lib ${CURRENT_INSTALLED_DIR}/debug/lib/zstd.lib)
    file(COPY ${CURRENT_INSTALLED_DIR}/debug/lib/thriftmdd.lib DESTINATION ${CURRENT_INSTALLED_DIR}/debug/lib/tmp)
    file(RENAME ${CURRENT_INSTALLED_DIR}/debug/lib/tmp/thriftmdd.lib ${CURRENT_INSTALLED_DIR}/debug/lib/thriftmd.lib)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${CPP_SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DARROW_DEPENDENCY_SOURCE=SYSTEM
    -DARROW_BUILD_TESTS=off
    -DRAPIDJSON_HOME=${CURRENT_INSTALLED_DIR}
    -DFLATBUFFERS_HOME=${CURRENT_INSTALLED_DIR}
    -DARROW_ZLIB_VENDORED=ON
    -DBROTLI_HOME=${CURRENT_INSTALLED_DIR}
    -DLZ4_HOME=${CURRENT_INSTALLED_DIR}
    -DZSTD_HOME=${CURRENT_INSTALLED_DIR}
    -DSNAPPY_HOME=${CURRENT_INSTALLED_DIR}
    -DBOOST_ROOT=${CURRENT_INSTALLED_DIR}
    -DGFLAGS_HOME=${CURRENT_INSTALLED_DIR}
    -DZLIB_HOME=${CURRENT_INSTALLED_DIR}
    -DARROW_PARQUET=ON
    -DARROW_BUILD_STATIC=${ARROW_BUILD_STATIC}
    -DARROW_BUILD_SHARED=${ARROW_BUILD_SHARED}
    -DBUILD_STATIC=${ARROW_BUILD_STATIC}
    -DBUILD_SHARED=${ARROW_BUILD_SHARED}
    -DPARQUET_ARROW_LINKAGE=${PARQUET_ARROW_LINKAGE}
    -DDOUBLE_CONVERSION_HOME=${CURRENT_INSTALLED_DIR}
    -DGLOG_HOME=${CURRENT_INSTALLED_DIR}
    -DARROW_BOOST_USE_SHARED=${BOOST_USE_SHARED}
    -DARROW_USE_STATIC_CRT=${USE_STATIC_CRT}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(WIN32)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/arrow_static.lib ${CURRENT_PACKAGES_DIR}/lib/arrow.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/arrow_static.lib ${CURRENT_PACKAGES_DIR}/debug/lib/arrow.lib)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
    else()
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/arrow_static.lib ${CURRENT_PACKAGES_DIR}/debug/lib/arrow_static.lib)
    endif()
endif()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/arrow/cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/arrow/arrowConfig.cmake ${CURRENT_PACKAGES_DIR}/share/arrow/cmake/arrowConfig.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/arrow/arrowConfigVersion.cmake ${CURRENT_PACKAGES_DIR}/share/arrow/cmake/arrowConfigVersion.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/arrow/arrowTargets-release.cmake ${CURRENT_PACKAGES_DIR}/share/arrow/cmake/arrowTargets-release.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/arrow/arrowTargets.cmake ${CURRENT_PACKAGES_DIR}/share/arrow/cmake/arrowTargets.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/arrow/arrowTargets-debug.cmake ${CURRENT_PACKAGES_DIR}/share/arrow/cmake/arrowTargets-debug.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/arrow RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

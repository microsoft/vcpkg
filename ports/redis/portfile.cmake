# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/redis-win-3.2.100)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/MSOpenTech/redis/archive/win-3.2.100.zip"
    FILENAME "redis-win-3.2.100.zip"
    SHA512 441f7ed42a55604fa74e9793cb75bb5ac65dac6dc8ff9acf000fd24f3c3942175d72373ae6c0ec2b344e81ff2600eb8ba96acb8c5c7358f446383bdac60eee94
)
vcpkg_extract_source_archive(${ARCHIVE})

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    MESSAGE(FATAL_ERROR " dynamic linkage is not supported.")
endif()

message(STATUS "Installing")
IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSEIF(TRIPLET_SYSTEM_ARCH MATCHES "arm")
	MESSAGE(FATAL_ERROR " ARM is currently not supported.")
ELSE()
	SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

LIST(APPEND VCXPROJECTS
    "deps/jemalloc-win/projects/jemalloc/proj.win32/vc2013/jemalloc.vcxproj"
    "msvs/RedisBenchmark/RedisBenchmark.vcxproj"
    "msvs/RedisCheckAof/RedisCheckAof.vcxproj"
    "msvs/RedisCli/RedisCli.vcxproj"
    "msvs/RedisServer.vcxproj"
    "msvs/lua/lua/lua.vcxproj"
    "msvs/hiredis/hiredis.vcxproj"
    "msvs/geohash/geohash.vcxproj"
    "src/Win32_Interop/Win32_Interop.vcxproj"
)  

FOREACH(P ${VCXPROJECTS})
    message(STATUS "Upgrading " ${P})
    file(READ ${SOURCE_PATH}/${P} PROJ)
    string(REPLACE
        "4.0"
        "14.0"
        PROJ "${PROJ}")
    string(REPLACE
        "<PlatformToolset>v120</PlatformToolset>"
        "<PlatformToolset>v140</PlatformToolset>"
        PROJ "${PROJ}")
    file(WRITE ${SOURCE_PATH}/${P} "${PROJ}")
ENDFOREACH()
message(STATUS "Upgrading projects done")

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/msvs/RedisServer.sln
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/redis RENAME copyright)

#Install Debug libraries
file(GLOB debug_libs ${SOURCE_PATH}/msvs/${BUILD_ARCH}/Debug/*.lib)
file(INSTALL ${debug_libs}
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)

#Install Release libraries
file(GLOB release_libs ${SOURCE_PATH}/msvs/${BUILD_ARCH}/Release/*.lib)
file(INSTALL ${release_libs}
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)

# Install Headers
file(GLOB headers ${SOURCE_PATH}/deps/hiredis/*.h)
file(INSTALL ${headers}
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/redis/deps/hiredis
)
file(GLOB headers ${SOURCE_PATH}/src/Win32_Interop/*.h)
file(INSTALL ${headers}
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/redis/src/Win32_Interop
)
file(INSTALL ${SOURCE_PATH}/deps/hiredis/adapters
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/redis/deps/hiredis
)
file(INSTALL ${SOURCE_PATH}/deps/jemalloc-win/include
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/redis/deps/jemalloc-win
)

vcpkg_copy_pdbs()
message(STATUS "Installing done")




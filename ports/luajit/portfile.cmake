# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#


include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/luajit2-2.1-20161104)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/openresty/luajit2/archive/v2.1-20161104.zip"
    FILENAME "luajit2-2.1-20161104.zip"
    SHA512 71483ef1f00d57ae1716cf1b424cfda860f9545613dbde55381adb5cfb8b5291929e31fede921723a8009abcf110a0dc844f9c41df382ed43496d99e9e229775
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-select-crt-runtime.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(LUAJIT_LINKAGE amalg)
else()
    set(LUAJIT_LINKAGE static)
endif()

message(STATUS "Building Release")
vcpkg_execute_required_process(
    COMMAND cmd /c msvcbuild.bat ${LUAJIT_LINKAGE}
    WORKING_DIRECTORY ${SOURCE_PATH}/src
    LOGNAME ${TARGET_TRIPLET}-build-rel
)
file(COPY ${SOURCE_PATH}/src/lua51.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
file(COPY ${SOURCE_PATH}/src/jit DESTINATION ${CURRENT_PACKAGES_DIR}/lib/lua/)
file(COPY ${SOURCE_PATH}/src/luajit.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/)
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(COPY ${SOURCE_PATH}/src/lua51.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin/)
	file(COPY ${SOURCE_PATH}/src/lua51.dll DESTINATION ${CURRENT_PACKAGES_DIR}/tools/)
endif()

message(STATUS "Building Debug")
vcpkg_execute_required_process(
    COMMAND cmd /c msvcbuild.bat debug ${LUAJIT_LINKAGE}
    WORKING_DIRECTORY ${SOURCE_PATH}/src
    LOGNAME ${TARGET_TRIPLET}-build-dbg
)
file(COPY ${SOURCE_PATH}/src/lua51.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
file(COPY ${SOURCE_PATH}/src/jit DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/lua/)
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(COPY ${SOURCE_PATH}/src/lua51.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/)
endif()


message(STATUS "Installing includes")
file(COPY ${SOURCE_PATH}/src/lauxlib.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/luajit-2.1/)
file(COPY ${SOURCE_PATH}/src/lua.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/luajit-2.1/)
file(COPY ${SOURCE_PATH}/src/lua.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/luajit-2.1/)
file(COPY ${SOURCE_PATH}/src/luaconf.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/luajit-2.1/)
file(COPY ${SOURCE_PATH}/src/luajit.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/luajit-2.1/)
file(COPY ${SOURCE_PATH}/src/lualib.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/luajit-2.1/)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/luajit/copyright)

vcpkg_copy_pdbs()


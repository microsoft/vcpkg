# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/LuaJIT-2.0.4)
vcpkg_download_distfile(ARCHIVE
    URLS "http://luajit.org/download/LuaJIT-2.0.4.tar.gz"
    FILENAME "LuaJIT-2.0.4.tar.gz"
    SHA512 a72957bd85d8f457269e78bf08c19b28c5707df5d19920d61918f8a6913f55913ce13037fb9a6463c04cefde0c6644739f390e09d656e4bbc2c236927aa3f8f9
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001-force-visual-studio-14-vcvarsall.patch
        ${CMAKE_CURRENT_LIST_DIR}/0002-select-crt-runtime.patch
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


include(vcpkg_common_functions)

if(NOT VCPKG_TARGET_IS_WINDOWS)
  message(FATAL_ERROR "This port is only for Windows Desktop")
endif()

find_program(NMAKE nmake)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ebiggers/libdeflate
    REF v1.5
    SHA512 8e86e87733bb1b2b2d4dda6ce0be96b57a125776c1f81804d5fc6f51516dd52796d9bb800ca4044c637963136ae390cfaf5cd804e9ae8b5d93d36853d0e807f6
    HEAD_REF master
    PATCHES
        makefile.patch
)

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(CRT_LINK_FLAG_PREFIX "/MD")
elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(CRT_LINK_FLAG_PREFIX "/MT")
endif()

set(CL_FLAGS_REL "${CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG /Z7")
set(CL_FLAGS_DBG "${CRT_LINK_FLAG_PREFIX}d /Z7 /Ob0 /Od /RTC1")

message(STATUS "Build ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} /f Makefile.msc clean all "CL_FLAGS=${CL_FLAGS_REL}"
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}-rel
)
message(STATUS "Build ${TARGET_TRIPLET}-rel done")

file (COPY ${SOURCE_PATH}/gzip.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file (COPY ${SOURCE_PATH}/gunzip.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file (COPY ${SOURCE_PATH}/libdeflate.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file (COPY ${SOURCE_PATH}/libdeflate.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file (INSTALL ${SOURCE_PATH}/libdeflatestatic.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib RENAME libdeflate.lib)
endif()

message(STATUS "Build ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} /f Makefile.msc clean all "CL_FLAGS=${CL_FLAGS_DBG}"
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}-dbg
)
message(STATUS "Build ${TARGET_TRIPLET}-dbg done")

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file (COPY ${SOURCE_PATH}/libdeflate.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file (COPY ${SOURCE_PATH}/libdeflate.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file (INSTALL ${SOURCE_PATH}/libdeflatestatic.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib RENAME libdeflate.lib)
endif()

file(
    COPY ${SOURCE_PATH}/libdeflate.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libdeflate RENAME copyright)

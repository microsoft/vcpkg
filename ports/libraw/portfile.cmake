vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LibRaw/LibRaw
    REF aeb6a2b6f1e0f752340580e60a7ed56099b4ff21 #2021-2-24
    SHA512 7eeccdc1cd1e35b4463ce3c2097a2e097de9aac49dccfeaa695024264d35a8f974b8e830b4f5b39c1a8130905fb6341edaccde6889bf125a65f8d2f20adcf90e
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH LIBRAW_CMAKE_SOURCE_PATH
    REPO LibRaw/LibRaw-cmake
    REF 5d54a89d1e3229b313b2cf3db8bf493dfc153cdb #2021-2-24
    SHA512 546814981fa80f3befbf96f264fbd08092e83e2f4f42fe206a7bc997c19e35a4d8904689eaafc5fccacb083a518039bf73a507d705c4a73eaa93eb28b2de8a6f
    HEAD_REF master
    PATCHES
        fix-incorrect-pdb.patch
        lcms2_debug_fix.patch
)

file(COPY ${LIBRAW_CMAKE_SOURCE_PATH}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${LIBRAW_CMAKE_SOURCE_PATH}/cmake DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DINSTALL_CMAKE_MODULE_PATH=${CURRENT_PACKAGES_DIR}/share/libraw
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()

file(READ ${CURRENT_PACKAGES_DIR}/include/libraw/libraw_types.h LIBRAW_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    string(REPLACE "#ifdef LIBRAW_NODLL" "#if 1" LIBRAW_H "${LIBRAW_H}")
else()
    string(REPLACE "#ifdef LIBRAW_NODLL" "#if 0" LIBRAW_H "${LIBRAW_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/libraw/libraw_types.h "${LIBRAW_H}")

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    # Rename thread-safe version to be "raw.lib". This is unfortunately needed
    # because otherwise libraries that build on top of libraw have to choose.
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/raw.lib ${CURRENT_PACKAGES_DIR}/debug/lib/rawd.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/raw_r.lib ${CURRENT_PACKAGES_DIR}/lib/raw.lib)
    if(NOT VCPKG_BUILD_TYPE STREQUAL "release")
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/raw_rd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/rawd.lib)
    endif()

    # Cleanup
    file(GLOB RELEASE_EXECUTABLES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
    file(REMOVE ${RELEASE_EXECUTABLES})
    if(NOT VCPKG_BUILD_TYPE STREQUAL "release")
        file(GLOB DEBUG_EXECUTABLES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
        file(REMOVE ${DEBUG_EXECUTABLES})
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/raw.dll ${CURRENT_PACKAGES_DIR}/debug/bin/rawd.dll)
    endif()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Rename cmake module into a config in order to allow more flexible lookup rules
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libraw/FindLibRaw.cmake ${CURRENT_PACKAGES_DIR}/share/libraw/libraw-config.cmake)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libraw)
endif()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)


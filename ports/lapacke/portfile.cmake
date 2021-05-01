include(vcpkg_find_fortran)
SET(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

set(lapacke_ver 3.8.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  "Reference-LAPACK/lapack"
    REF "v${lapacke_ver}"
    SHA512 17786cb7306fccdc9b4a242de7f64fc261ebe6a10b6ec55f519deb4cb673cb137e8742aa5698fd2dc52f1cd56d3bd116af3f593a01dcf6770c4dcc86c50b2a7f
    HEAD_REF master
)

set(VCPKG_CRT_LINKAGE_BACKUP ${VCPKG_CRT_LINKAGE})
vcpkg_find_fortran(FORTRAN_CMAKE)
if(VCPKG_USE_INTERNAL_Fortran)
    if(VCPKG_CRT_LINKAGE_BACKUP STREQUAL static) 
        message(FATAL_ERROR "LAPACKE cannot be used without supplying an external fortran compiler")
    endif()
endif()    
vcpkg_configure_cmake(
        PREFER_NINJA
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            "-DUSE_OPTIMIZED_LAPACK=ON"
            "-DUSE_OPTIMIZED_BLAS=ON"
            "-DLAPACKE=ON"
            ${FORTRAN_CMAKE}
        )

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/lapacke-${lapacke_ver})

set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lapacke.pc")
if(EXISTS "${pcfile}")
    file(READ "${pcfile}" _contents)
    set(_contents "prefix=${CURRENT_INSTALLED_DIR}\n${_contents}")
    file(WRITE "${pcfile}" "${_contents}")
endif()
set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lapacke.pc")
if(EXISTS "${pcfile}")
    file(READ "${pcfile}" _contents)
    set(_contents "prefix=${CURRENT_INSTALLED_DIR}/debug\n${_contents}")
    file(WRITE "${pcfile}" "${_contents}")
endif()
# has to remove lapack.pc
set(pcfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lapack.pc")
if(EXISTS "${pcfile}")
    file(REMOVE "${pcfile}")
endif()
set(pcfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lapack.pc")
if(EXISTS "${pcfile}")
    file(REMOVE "${pcfile}")
endif()
vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# remove debug includes
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_TARGET_IS_WINDOWS)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/liblapacke.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/liblapacke.lib" "${CURRENT_PACKAGES_DIR}/lib/lapacke.lib")
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/liblapacke.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/liblapacke.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/lapacke.lib")
    endif()
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/lapacke)
    #file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindLAPACK.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/lapack)
    #what's the meaning of this line? FindLAPACK.cmake?
endif()

# Make sure LAPACKE can be found
vcpkg_configure_cmake(SOURCE_PATH ${CURRENT_PORT_DIR}
                      OPTIONS -DCMAKE_PREFIX_PATH="${CURRENT_PACKAGES_DIR}")

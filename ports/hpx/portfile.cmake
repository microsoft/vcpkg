include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)                                          
    message(STATUS "Warning: Static building of HPX not supported yet. Building dynamic.") 
    set(VCPKG_LIBRARY_LINKAGE dynamic)                                              
endif()                                                                             

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO STEllAR-GROUP/hpx
    REF 1.1.0
    SHA512 435250143ddbd2608995fe3dc5c229a096312d7ac930925ae56d0abd2d5689886126f6e81bc7e37b84ca9bc99f951ef1f39580168a359c48788ac8d008bc7078
    HEAD_REF master
)

SET(BOOST_PATH "${CURRENT_INSTALLED_DIR}/share/boost")
SET(HWLOC_PATH "${CURRENT_INSTALLED_DIR}/share/hwloc")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBOOST_ROOT=${BOOST_PATH}
        -DHWLOC_ROOT=${HWLOC_ROOT}
        -DHPX_WITH_VCPKG=ON
        -DHPX_WITH_HWLOC=ON
        -DHPX_WITH_TESTS=OFF
        -DHPX_WITH_EXAMPLES=OFF
        -DHPX_WITH_TOOLS=OFF
        -DHPX_WITH_RUNTIME=OFF
)

vcpkg_install_cmake()

# post build cleanup
if(NOT VCPKG_USE_HEAD_VERSION)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/hpx-1.1.0 ${CURRENT_PACKAGES_DIR}/share/hpx)
else()
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/hpx-1.2.0 ${CURRENT_PACKAGES_DIR}/share/hpx)
endif()

file(INSTALL
    ${SOURCE_PATH}/LICENSE_1_0.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/hpx RENAME copyright)

file(GLOB __hpx_cmakes ${CURRENT_PACKAGES_DIR}/lib/cmake/HPX/*.*)
foreach(__hpx_cmake ${__hpx_cmakes})
    file(COPY ${__hpx_cmake} DESTINATION ${CURRENT_PACKAGES_DIR}/share/hpx/cmake)
    file(REMOVE ${__hpx_cmake})
endforeach()

file(GLOB __hpx_dlls ${CURRENT_PACKAGES_DIR}/lib/*.dll)
foreach(__hpx_dll ${__hpx_dlls})
    file(COPY ${__hpx_dll} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE ${__hpx_dll})
endforeach()

file(GLOB __hpx_dlls ${CURRENT_PACKAGES_DIR}/lib/hpx/*.dll)
foreach(__hpx_dll ${__hpx_dlls})
    file(COPY ${__hpx_dll} DESTINATION ${CURRENT_PACKAGES_DIR}/bin/hpx)
    file(REMOVE ${__hpx_dll})
endforeach()

file(GLOB __hpx_dlls ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
foreach(__hpx_dll ${__hpx_dlls})
    file(COPY ${__hpx_dll} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${__hpx_dll})
endforeach()

file(GLOB __hpx_dlls ${CURRENT_PACKAGES_DIR}/debug/lib/hpx/*.dll)
foreach(__hpx_dll ${__hpx_dlls})
    file(COPY ${__hpx_dll} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/hpx)
    file(REMOVE ${__hpx_dll})
endforeach()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/bazel)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/bazel)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)

vcpkg_copy_pdbs()


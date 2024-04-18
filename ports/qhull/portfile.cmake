vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qhull/qhull
    REF 613debeaea72ee66626dace9ba1a2eff11b5d37d
    SHA512 5b8ff9665ba73621a9859a6e86717b980b67f8d79d6c78cbf5672bce66aed671f7d64fcbec457bca79eef2e17e105f136017afdf442bb430b9f4a059d7cb93c3
    HEAD_REF master
    PATCHES
        include-qhullcpp-shared.patch
        fix-missing-symbols.patch # upstream https://github.com/qhull/qhull/pull/93
        noapp.patch # upstream https://github.com/qhull/qhull/pull/124
        fix-qhullcpp-cpp20-support.patch # upstream https://github.com/qhull/qhull/pull/122
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

if("tools" IN_LIST FEATURES)
    list(APPEND QHULL_OPTIONS -DBUILD_APPLICATIONS:BOOL=ON)
else()
    list(APPEND QHULL_OPTIONS -DBUILD_APPLICATIONS:BOOL=OFF)
endif()
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        ${QHULL_OPTIONS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/share/man"
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share/man"
    "${CURRENT_PACKAGES_DIR}/debug/share/doc"
)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Qhull)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/qhull/QhullTargets-interface.cmake" [[
        add_library(Qhull::qhull_r IMPORTED INTERFACE)
        set_target_properties(Qhull::qhull_r PROPERTIES INTERFACE_LINK_LIBRARIES Qhull::qhullstatic_r)
]])
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(active_basename "qhullstatic")
    set(inactive_basename "qhull")
else()
    set(active_basename "qhull")
    set(inactive_basename "qhullstatic")
endif()
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${inactive_basename}_r.pc")
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${inactive_basename}.pc") # qhullstatic.pc in dynamic build
if(NOT DEFINED VCPKG_BUILD_TYPE)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${inactive_basename}_rd.pc")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${active_basename}_rd.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${active_basename}_r.pc")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/qhullstatic_d.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/qhullstatic.pc")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${inactive_basename}.pc") # qhullstatic.pc in dynamic build
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/qhullcpp_d.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/qhullcpp.pc")
endif()
vcpkg_fixup_pkgconfig()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES
        qconvex
        qdelaunay
        qhalf
        qhull
        qvoronoi
        rbox
        AUTO_CLEAN
    )
endif()

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME usage)
file(INSTALL "${SOURCE_PATH}/COPYING.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

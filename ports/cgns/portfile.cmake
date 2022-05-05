
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGNS/CGNS
    REF ec538ac11dbaff510464a831ef094b0d6bf7216c # v4.3.0
    SHA512 3c04829ff99c0f4f1cd705f0807fda0a65f970c7eecd23ec624cf09fb6fa2a566c63fc94d46c1d0754910bbff8f98c3723e4f32ef66c3e7e41930313454fa10b
    HEAD_REF develop
    PATCHES
        hdf5.patch
        linux_lfs.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
   FEATURES
     "fortran"      CGNS_ENABLE_FORTRAN
     "tests"        CGNS_ENABLE_TESTS
     "hdf5"         CGNS_ENABLE_HDF5
     "lfs"          CGNS_ENABLE_LFS
     "legacy"       CGNS_ENABLE_LEGACY
     "cgnstools"    CGNS_BUILD_CGNSTOOLS
)

set(CGNS_BUILD_OPTS "")
if(VCPKG_TARGET_ARCHITECTURE MATCHES "64")
    list(APPEND CGNS_BUILD_OPTS "-DCGNS_ENABLE_64BIT=ON")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND CGNS_BUILD_OPTS "-DCGNS_BUILD_SHARED=ON;-DCGNS_USE_SHARED=ON")
else()
    list(APPEND CGNS_BUILD_OPTS "-DCGNS_BUILD_SHARED=OFF;-DCGNS_USE_SHARED=OFF")
endif()

# By default, when possible, vcpkg_cmake_configure uses ninja-build as its build system
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${CGNS_BUILD_OPTS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Moves all *.cmake files from /debug/lib/cmake/cgns/ to /share/cgns/
# See /docs/maintainers/ports/vcpkg-cmake-config/vcpkg_cmake_config_fixup.md for more details
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/cgns")

vcpkg_copy_tools(
    TOOL_NAMES
        cgnscheck
        cgnscompress
        cgnsconvert
        cgnsdiff
        cgnslist
        cgnsnames
    AUTO_CLEAN
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(TOOLS "adf2hdf.bat" "hdf2adf.bat" "cgnsupdate.bat")
elseif(VCPKG_TARGET_IS_LINUX)
    set(TOOLS "adf2hdf" "hdf2adf" "cgnsupdate")
endif()

foreach(TOOL ${TOOLS})
    file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/${TOOL}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${TOOL}")
endforeach()

if("cgnstools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            calcwish
            plotwish
            cgiowish
            aflr3_to_cgns
            cgns_info
            cgns_to_aflr3
            cgns_to_fast
            cgns_to_plot3d
            cgns_to_tecplot
            cgns_to_vtk
            convert_dataclass
            convert_location
            convert_variables
            extract_subset
            fast_to_cgns
            interpolate_cgns
            patran_to_cgns
            plot3d_to_cgns
            tecplot_to_cgns
            tetgen_to_cgns
            update_ngon
            vgrid_to_cgns
        AUTO_CLEAN
    )

    if(VCPKG_TARGET_IS_WINDOWS)
        # Copy tools from "bin" to "tools/cgns"
        set(CGNSTOOLS "cgconfig.bat" "cgnscalc.bat" "unitconv.bat" "cgnsview.bat" "cgnsplot.bat" "cgnsnodes.bat")
        foreach(CGNSTOOL IN LISTS CGNSTOOLS)
            file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${CGNSTOOL}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${CGNSTOOL}")
        endforeach()

        # Adjust paths in batch file
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/cgconfig.bat" "${CURRENT_PACKAGES_DIR}\\bin" "${CURRENT_PACKAGES_DIR}\\tools\\cgns")
    elseif(VCPKG_TARGET_IS_LINUX)
        # Copy tools from "bin" to "tools/cgns"
        set(CGNSTOOLS "cgconfig" "cgnscalc.sh" "unitconv.sh" "cgnsview.sh" "cgnsplot.sh" "cgnsnodes.sh")
        foreach(CGNSTOOL IN LIOSTS CGNSTOOLS)
            file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${CGNSTOOL}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${CGNSTOOL}")
        endforeach()

        # adjust paths in batch files
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/cgconfig" "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools/cgns")
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

if (EXISTS "${CURRENT_PACKAGES_DIR}/debug")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

file(REMOVE "${CURRENT_PACKAGES_DIR}/include/cgnsBuild.defs" "${CURRENT_PACKAGES_DIR}/include/cgnsconfig.h")
file(INSTALL "${CURRENT_PORT_DIR}/cgnsconfig.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include") # the include is all that is needed

# Handle copyright
configure_file("${SOURCE_PATH}/license.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

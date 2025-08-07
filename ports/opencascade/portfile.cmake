string(REPLACE "." "_" VERSION_STR "V${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Open-Cascade-SAS/OCCT
    REF "${VERSION_STR}"
    SHA512 4ec271ec8db5f0d6f77ea5c0633b40334c796421806a344c568fb8d9ed942fec63f8dfcc65ab9f65e0446d5cd7a49beede5ac693421971b350e828ab1a19d773
    HEAD_REF master
    PATCHES
        fix-install-prefix-path.patch
        drop-bin-letter-d.patch
        dependencies.patch
        install-include-dir.patch
        remove-vcpkg-enabling.patch
        csf-redifinition.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(BUILD_TYPE "Shared")
else()
    set(BUILD_TYPE "Static")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        freeimage   USE_FREEIMAGE
        freetype    USE_FREETYPE
        rapidjson   USE_RAPIDJSON
        samples     INSTALL_SAMPLES
        tbb         USE_TBB
        vtk         USE_VTK
)

# We turn off BUILD_MODULE_Draw as it requires TCL 8.6 and TK 8.6 specifically which conflicts with vcpkg only having TCL 9.0 
# And pre-built ActiveTCL binaries are behind a marketing wall :(
# We use the Unix install layout for Windows as it matches vcpkg
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_LIBRARY_TYPE=${BUILD_TYPE}
        -DBUILD_MODULE_Draw=OFF
        -DBUILD_DOC_Overview=OFF
        -DBUILD_MODULE_DETools=OFF
        -DINSTALL_DIR_LAYOUT=Unix
        -DINSTALL_DIR_DOC=share/trash
        -DINSTALL_DIR_SCRIPT=share/trash # not relocatable
        -DINSTALL_TEST_CASES=OFF
        -DUSE_TK=OFF
    OPTIONS_DEBUG
        -DINSTALL_SAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/opencascade)

#make occt includes relative to source_file
file(GLOB extra_headers
    LIST_DIRECTORIES false
    RELATIVE "${CURRENT_PACKAGES_DIR}/include/opencascade"
    "${CURRENT_PACKAGES_DIR}/include/opencascade/*.h"
)
list(JOIN extra_headers "|" extra_headers)
file(GLOB files "${CURRENT_PACKAGES_DIR}/include/opencascade/*.[hgl]xx")
foreach(file_name IN LISTS files)
    file(READ "${file_name}" filedata)
    string(REGEX REPLACE "(# *include) <([a-zA-Z0-9_]*[.][hgl]xx|${extra_headers})>" [[\1 "\2"]] filedata "${filedata}")
    file(WRITE "${file_name}" "${filedata}")
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/opencascade/samples/qt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/trash")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE_LGPL_21.txt"
        "${SOURCE_PATH}/OCCT_LGPL_EXCEPTION.txt"
)

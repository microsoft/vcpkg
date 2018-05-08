# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(VTK-DICOM_SHORT_VERSION "0.8")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "dgobbi/vtk-dicom"
    REF "ca27801fad6356c98ba19e760b9b4b8e9128f60e"
    SHA512 d4916fa385e6f26da0a5d7eb981497c9121ff4f67b4b03e518aa4974d2b0ef207168e939e5063e705c15f627ace56e39aca5f5891d333924cbc80c9277aa7dd2
    HEAD_REF "master"
)

if ("gdcm" IN_LIST FEATURES)
    set(USE_GDCM                      ON )
else()
    set(USE_GDCM                      OFF )
endif()


if(USE_GDCM)
    list(APPEND ADDITIONAL_OPTIONS
        -DUSE_GDCM=ON
        -DUSE_DCMTK=OFF
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
    OPTIONS
        -DBUILD_PROGRAMS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_SHARED_LIBS=ON
        ${ADDITIONAL_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/vtk-dicom)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/vtk-dicom/Copyright.txt ${CURRENT_PACKAGES_DIR}/share/vtk-dicom/copyright)
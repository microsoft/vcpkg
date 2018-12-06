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

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/FMILibrary-2.0.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://jmodelica.org/fmil/FMILibrary-2.0.3-src.zip"
    FILENAME "FMILibrary-2.0.3-src.zip"
    SHA512 86e4b5019d8f2a76b01141411845d977fb3949617604de0b34351f23647e3e8b378477de184e1c4f2f59297bc4c7de3155e0edba9099b8924594a36b37b04cc8
)

vcpkg_extract_source_archive(${ARCHIVE})

# Note that if you have configured and built both static and shared library on Windows
# but want to link with the static library compile time define "FMILIB_BUILDING_LIBRARY" must be set.
if (WIN32 AND VCPKG_LIBRARY_LINKAGE STREQUAL static)
    SET(FMILIB_BUILDING_LIBRARY ON)
else() 
    SET(FMILIB_BUILDING_LIBRARY OFF)
endif()

# Use static run-time libraries (/MT or /MTd code generation flags)
# This is only used when generating Microsoft Visual Studio solutions. If the options is on then the library will
# be built against static runtime, otherwise - dynamic runtime (/MD or /MDd). Make sure the client code is using
# matching runtime
if (WIN32 AND VCPKG_CRT_LINKAGE STREQUAL static)
    SET(FMILIB_BUILD_WITH_STATIC_RTLIB ON)
else()
    SET(FMILIB_BUILD_WITH_STATIC_RTLIB OFF)
endif()

# On LINUX position independent code (-fPIC) must be used on all files to be linked into a shared library (.so file).
# On other systems this is not needed (either is default or relocation is done). Set this option to OFF if you
# are building an application on Linux and use static library only
if (UNIX AND VCPKG_LIBRARY_LINKAGE STREQUAL static)
    SET(FMILIB_BUILD_FOR_SHARED_LIBS OFF)
else() 
    SET(FMILIB_BUILD_FOR_SHARED_LIBS ON)
endif()

# Only build the requested library
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    SET(FMILIB_BUILD_STATIC_LIB ON)
    SET(FMILIB_BUILD_SHARED_LIB OFF)
else()
    SET(FMILIB_BUILD_STATIC_LIB OFF)
    SET(FMILIB_BUILD_SHARED_LIB ON)
endif()

SET(OPTIONS
    -DFMILIB_BUILD_TESTS=OFF
    -DFMILIB_BUILD_STATIC_LIB=${FMILIB_BUILD_STATIC_LIB} 
    -DFMILIB_BUILD_SHARED_LIB=${FMILIB_BUILD_SHARED_LIB}
    -DFMILIB_BUILDING_LIBRARY=${FMILIB_BUILDING_LIBRARY}  
    -DFMILIB_BUILD_WITH_STATIC_RTLIB=${FMILIB_BUILD_WITH_STATIC_RTLIB} 
)

# Reset package dir
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR})
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR})

foreach(BUILDTYPE "rel" "dbg")

    message("Building ${TARGET_TRIPLET}-${BUILDTYPE}...")

    string(COMPARE EQUAL ${BUILDTYPE} "rel" RELEASE_BUILD)

    SET(BUILD_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${BUILDTYPE})

    # Reset working dir
    file(REMOVE_RECURSE ${BUILD_DIR})
    file(MAKE_DIRECTORY ${BUILD_DIR}) 

    if(RELEASE_BUILD)
        SET(FMILIB_INSTALL_PREFIX ${CURRENT_PACKAGES_DIR})
    else()
        SET(FMILIB_INSTALL_PREFIX ${CURRENT_PACKAGES_DIR}/debug)
    endif()

    # Step 1: Configure
    vcpkg_execute_required_process(COMMAND 
        cmake 
            -DFMILIB_INSTALL_PREFIX=${FMILIB_INSTALL_PREFIX}
            -DFMILIB_DEFAULT_BUILD_TYPE_RELEASE=${RELEASE_BUILD}  
            ${OPTIONS}
            ${SOURCE_PATH}
        WORKING_DIRECTORY 
            ${BUILD_DIR}
    )

    # Step 2: Build
    # Custom build - becouse vcpkg_configure_cmake() + vcpkg_install_cmake() fails on Linux for some unknown reason
    if (UNIX)
        find_program(MAKE make)
        if(NOT MAKE)
            message(FATAL_ERROR "Could not find make. Please install it through your package manager.")
        endif()
        vcpkg_execute_required_process(COMMAND make "install"  WORKING_DIRECTORY ${BUILD_DIR})
    else()
        if(RELEASE_BUILD)
            SET(CONFIG "MinSizeRel")
        else()
            SET(CONFIG "Debug")
        endif()
        vcpkg_execute_required_process(COMMAND 
            cmake 
                --build . 
                --config ${CONFIG} 
                --target "install" 
            WORKING_DIRECTORY 
                ${BUILD_DIR}
        )
    endif()

    if (RELEASE_BUILD)

        # remove /doc folder
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/doc)

        # Move .dll files (if any) from /lib to /bin 
        file(GLOB TMP ${CURRENT_PACKAGES_DIR}/lib/*.dll)
        if (TMP) 
            file(COPY ${TMP} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
            file(REMOVE ${TMP})

            # Add bin to path
            set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin;$ENV{PATH}")
        endif()

    else()

        # remove duplicate folders in /debug
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/doc)

        # Move .dll files (if any) from /lib to /bin 
        file(GLOB TMP ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
        if (TMP)
            file(COPY ${TMP} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
            file(REMOVE ${TMP})

            # Add bin to path
            set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/bin;$ENV{PATH}")
        endif()

    endif()

    message("Building ${TARGET_TRIPLET}-${BUILDTYPE}... Done")

endforeach()

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/fmilib RENAME copyright)

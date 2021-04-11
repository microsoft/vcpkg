
set(VERSION dev-v0.9)
vcpkg_download_distfile(ARCHIVE
    URLS "https://api.github.com/repos/JonathanSalwan/Triton/tarball/${VERSION}"
    FILENAME "triton-${VERSION}.tar.gz"
    SHA512 7d33f2654cae4868fbbcb3a3ec709c8f5f2e692c6d989cd2c9c95886b9623731d399ae23c7b4189be239c388c07b89bdd415bbf215bffed629ce50d8785079b4
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
)

# Capstone path should be adapted in Windows
if(VCPKG_TARGET_IS_WINDOWS)  
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(CAPSTONE_LIBRARY ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib/capstone${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
    else()
        set(CAPSTONE_LIBRARY ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib/capstone_dll${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
    endif()

    set(CAPSTONE_INCLUDE_DIR ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/include/capstone)
else()
    set(CAPSTONE_INCLUDE_DIR ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/include)
	set(CAPSTONE_LIBRARY ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib/libcapstone${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})
endif()

# Z3
set(Z3_LIBRARY ${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib/libz3${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX})


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DZ3_INTERFACE=${Z3_INTERFACE}
		-DPYTHON_BINDINGS=${PYTHON_BINDINGS}
		-DPYTHON36=${PYTHON36}
		-DSTATICLIB=${STATICLIB}
		-DZ3_LIBRARY=${Z3_LIBRARY}
		-DCAPSTONE_LIBRARY=${CAPSTONE_LIBRARY}
		-DCAPSTONE_INCLUDE_DIR=${CAPSTONE_INCLUDE_DIR}
		-DPYTHON_INCLUDE_DIR="${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/include"
		-DPYTHON_LIBRARY=${PYTHON_LIBRARY}
       )

vcpkg_install_cmake()
vcpkg_copy_pdbs()

configure_file("${CURRENT_BUILDTREES_DIR}/src/dev-v0.9-fd0ccd4864.clean/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/triton/copyright" COPYONLY)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
	file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/triton.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/triton.dll ${CURRENT_PACKAGES_DIR}/bin/triton.dll)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/triton.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/triton.dll ${CURRENT_PACKAGES_DIR}/debug/bin/triton.dll)
endif()


vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mikmod/libmikmod
    REF 3.3.11.1
    FILENAME "libmikmod-3.3.11.1.tar.gz"
    SHA512 f2439e2b691613847cd0787dd4e050116683ce7b05c215b8afecde5c6add819ea6c18e678e258c0a80786bef463f406072de15127f64368f694287a5e8e1a9de
    PATCHES 
        fix-missing-dll.patch
        name_conflict.patch
        find-openal.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(ENABLE_STATIC ON)
else()
    set(ENABLE_STATIC OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_DOC=OFF
        -DENABLE_THREADS=ON
        -DDISABLE_HQMIXER=OFF
        -DENABLE_AF=ON
        -DENABLE_AIFF=ON
        -DENABLE_NAS=ON
        -DENABLE_OPENAL=ON
        -DENABLE_PIPE=ON
        -DENABLE_RAW=ON
        -DENABLE_STDOUT=ON
        -DENABLE_WAV=ON
        -DOPENAL_INCLUDE_DIR="${CURRENT_INSTALLED_DIR}/include"
        -DENABLE_STATIC=${ENABLE_STATIC}
    OPTIONS_RELEASE -DENABLE_SIMD=ON
    OPTIONS_DEBUG -DENABLE_SIMD=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/COPYING.LESSER" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-mpi/hwloc
    REF 5e185ccfff2728fa351cea41f6d9fefebfb88078 # hwloc-2.5.0
    SHA512 96f6421c40eede3a3c273a1ffa06accc43767421d5fb7b402a83caea1ef1a3bb8282c08ed94bc696296f37f3df80cd86403dac1012f2218b674569c8afcf3de9
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(OPTIONS ac_cv_prog_cc_c99= # To avoid the compiler check for C99 which will fail for MSVC
                 --disable-plugin-dlopen) 
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS "HWLOC_LDFLAGS=-no-undefined")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${OPTIONS} 
        --disable-libxml2
        --disable-opencl
        --disable-cairo
        --disable-cuda
        --disable-libudev
        --disable-levelzero
        --disable-nvml
        --disable-rsmi
        --disable-pci
        #--disable-cpuid
        #--disable-picky
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS) # hardcode import specifiers. 
    file(READ ${CURRENT_PACKAGES_DIR}/include/hwloc/autogen/config.h PUBLIC_CONFIG_H)
    string(REPLACE "defined( DECLSPEC_EXPORTS )" "0" PUBLIC_CONFIG_H "${PUBLIC_CONFIG_H}")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        string(REPLACE "defined( _USRDLL )" "0" PUBLIC_CONFIG_H "${PUBLIC_CONFIG_H}")
    else()
        string(REPLACE "defined( _USRDLL )" "1" PUBLIC_CONFIG_H "${PUBLIC_CONFIG_H}")
    endif()
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/hwloc/autogen/config.h "${PUBLIC_CONFIG_H}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

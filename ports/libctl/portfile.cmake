#set(PORT_DEBUG TRUE)

message(STATUS "${PORT} currently requires the following library from the system package manager:
    guile-2.2-dev
This can be installed on Ubuntu systems via sudo apt install guile-2.2-dev")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NanoComp/libctl
    REF aa56a410f33fb2fd80605faf35dfa7906785edef
    SHA512 0351f35e433089bf8437ab17eaa0cf13d9d578776806011e1ecfe48cda769ebc21801f0e5b31bf3f80a62ceae170f0d5e9c9b817e01e39bffd8c062b3ff1731c
    HEAD_REF master
)

include(vcpkg_find_fortran)
vcpkg_find_fortran(FORTRAN_CMAKE)

if(CMAKE_HOST_WIN32)
	vcpkg_acquire_msys(MSYS_ROOT PACKAGES autoconf)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES make)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES libguile)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
    #set(ENV{CC} "gcc")
    #set(ENV{CXX} "g++")
    set(ENV{FC} "gfortran")
    message(STATUS "Switching to MinGW toolchain, including ${SCRIPTS}/toolchains/mingw.cmake")
    include("${SCRIPTS}/toolchains/mingw.cmake")
    #set(ENV{CFLAGS} "-mabi=ms ${MACHINE_FLAG} ${VCPKG_C_FLAGS}")
    #set(ENV{CXXFLAGS} "-mabi=ms ${MACHINE_FLAG} ${VCPKG_CXX_FLAGS}")
    set(ENV{FFLAGS} "-mabi=ms ${MACHINE_FLAG} ${VCPKG_Fortran_FLAGS}")
endif()

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        --enable-debug
)

vcpkg_install_make()

# remove debug include folder
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include/)

# remove debug bin folder
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/)

# remove bin folder
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/)

vcpkg_copy_pdbs()

# remove debug share folder
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share/)

# remove share folder
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

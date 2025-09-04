set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Ipopt
    REF "releases/${VERSION}"
    SHA512 98b413b6beaf300175ef6f4e97ba4be6bdeee6aadcd0657eaf9da0142eba0f0b5ca3c84958e88757a13b42ccacb8137bb7bbae4f51f018ec7bbddc19eceedcc1
    PATCHES
      mumps_pcfiles.patch
    #REF ec43e37a06054246764fb116e50e3e30c9ada089
    #HEAD_REF master
    #SHA512 f5b30e81b4a1a178e9a0e2b51b4832f07441b2c3e9a2aa61a6f07807f94185998e985fcf3c34d96fbfde78f07b69f2e0a0675e1e478a4e668da6da60521e0fd6
)
file(COPY "${CURRENT_INSTALLED_DIR}/share/coin-or-buildtools/" DESTINATION "${SOURCE_PATH}")

set(ENV{ACLOCAL} "aclocal -I \"${SOURCE_PATH}/BuildTools\"")

set(CONFIGURE_ARGS
      --without-spral
      --without-hsl
      --without-asl
      --with-lapack
      --enable-relocatable
      --disable-f77
      --disable-java
      #--with-pardiso
      #--without-wsmp
      #--with-precision        floating-point precision to use: single or double(default)
      #--with-intsize          integer type to use: specify 32 for int or 64(default) for int64_t
)

if("mumps" IN_LIST FEATURES)
    list(APPEND CONFIGURE_ARGS "--with-mumps")
    #list(APPEND CONFIGURE_ARGS "--mumps-pcfiles=mumps-solver")
    #list(APPEND CONFIGURE_ARGS "--with-mumps-lflags=-L${CURRENT_INSTALLED_DIR}/lib/ -ldmumps -lsmumps")
    #list(APPEND CONFIGURE_ARGS "--with-mumps-cflags=-I${CURRENT_INSTALLED_DIR}/include/")
endif()

if(VCPKG_HOST_IS_LINUX)
    list(APPEND CONFIGURE_ARGS "LIBS=-lgfortran -lm")
endif()

# link against openblas, assumed static lib
#set(OPENBLAS_LIB "${CMAKE_STATIC_LIBRARY_PREFIX}openblas${CMAKE_STATIC_LIBRARY_SUFFIX}")
#set(LAPACK_LIB "${CMAKE_STATIC_LIBRARY_PREFIX}lapack${CMAKE_STATIC_LIBRARY_SUFFIX}")

#if(VCPKG_HOST_IS_WINDOWS)
#    list(APPEND CONFIGURE_ARGS "--with-lapack-lflags=${CURRENT_INSTALLED_DIR}/lib/${OPENBLAS_LIB}")
#elseif(VCPKG_HOST_IS_LINUX)
#    list(APPEND CONFIGURE_ARGS "--with-lapack-lflags=-L${CURRENT_INSTALLED_DIR}/lib -llapack -lgfortran -lm")
#endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${CONFIGURE_ARGS}
)
vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()


# Install usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

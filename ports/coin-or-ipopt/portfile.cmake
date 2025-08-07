set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Ipopt
    REF ec43e37a06054246764fb116e50e3e30c9ada089
    SHA512 f5b30e81b4a1a178e9a0e2b51b4832f07441b2c3e9a2aa61a6f07807f94185998e985fcf3c34d96fbfde78f07b69f2e0a0675e1e478a4e668da6da60521e0fd6
    HEAD_REF master
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
endif()

# link against openblas, assumed static lib
set(OPENBLAS_LIB "${CMAKE_STATIC_LIBRARY_PREFIX}openblas${CMAKE_STATIC_LIBRARY_SUFFIX}")

if(VCPKG_HOST_IS_WINDOWS)
	list(APPEND CONFIGURE_ARGS "--with-lapack-lflags=${CURRENT_INSTALLED_DIR}/lib/${OPENBLAS_LIB}")
elseif(VCPKG_HOST_IS_LINUX)
  list(APPEND CONFIGURE_ARGS "--with-lapack-lflags=-L${CURRENT_INSTALLED_DIR}/lib -lopenblas -lm")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
      ${CONFIGURE_ARGS}
)
vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Install usage file and custom FindModules
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
#file(REMOVE "${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

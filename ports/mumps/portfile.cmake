set(VCPKG_BUILD_TYPE release)

set(CONFIGURE_VERSION "3.0.10")

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/coin-or-tools/ThirdParty-Mumps/archive/releases/${CONFIGURE_VERSION}.tar.gz"
    FILENAME "ThirdParty-Mumps-releases-${CONFIGURE_VERSION}.tar.gz"
    SHA512 1f6f98c01fa63d6a95bbbbec216e4270965a776bcf678fc1ac70873fc636c674fa0f8ccf7289a44717ae32ccf92b6b851452a655c398754571140e2e27a60c98
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "ThirdParty-Mumps-releases-${CONFIGURE_VERSION}"
)

##### implments ./get.MUMPS
# get sources
vcpkg_download_distfile(MUMPS_SOURCE
    URLS "http://coin-or-tools.github.io/ThirdParty-Mumps/MUMPS_${VERSION}.tar.gz"
    FILENAME "ThirdParty-Mumps-releases-${VERSION}.tar.gz"
    SHA512 af0ec3f2c69ff48349cfe68817a81cac2242cdff782ec12331749d4cfa095c2ae016d01da4c7969c122b5eef318c23b2ef7f0b5c2a78c6629cad0cb4dc8765aF
)
# extract source
vcpkg_extract_source_archive(
    MUMPS_SOURCE_PATH
    ARCHIVE "${MUMPS_SOURCE}"
    SOURCE_BASE "MUMPS_${VERSION}"
    WORKING_DIRECTORY ${SOURCE_PATH}
    PATCHES
        mumps_mpi.patch
        fortran_mangling_fix.patch
)

## move files
file(RENAME "${MUMPS_SOURCE_PATH}" "${SOURCE_PATH}/MUMPS")
file(RENAME "${SOURCE_PATH}/MUMPS/libseq/mpi.h" "${SOURCE_PATH}/MUMPS/libseq/mumps_mpi.h")
#####

set(CONFIGURE_ARGS
    #"--prefix=${CURRENT_INSTALLED_DIR}"
    "--with-metis"
    "--with-lapack"
)
#list(APPEND CONFIGURE_ARGS "--with-metis-cflags=-I${CURRENT_INSTALLED_DIR}/include/")

# link against openblas, assumed static lib
set(OPENBLAS_LIB "${CMAKE_STATIC_LIBRARY_PREFIX}openblas${CMAKE_STATIC_LIBRARY_SUFFIX}")

if(VCPKG_HOST_IS_LINUX)
    list(APPEND CONFIGURE_ARGS "--with-lapack-lflags=-L${CURRENT_INSTALLED_DIR}/lib/ -lopenblas -lm")
    #list(APPEND CONFIGURE_ARGS "--with-lapack-lflags=${CURRENT_INSTALLED_DIR}/lib/${OPENBLAS_LIB}")
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        #AUTOCONFIG
        OPTIONS
        ${CONFIGURE_ARGS}
    )
    vcpkg_install_make()
endif()

if(VCPKG_HOST_IS_WINDOWS)
    list(APPEND CONFIGURE_ARGS "--with-lapack-lflags=${CURRENT_INSTALLED_DIR}/lib/${OPENBLAS_LIB}")
    #list(APPEND CONFIGURE_ARGS "--with-lapack-lflags=-L${CURRENT_INSTALLED_DIR}/lib/ -lopenblas -lm")
    list(APPEND CONFIGURE_ARGS "--prefix=/install_dir")

    list(APPEND CONFIGURE_ARGS "--enable-msvc")

    # Fortran Compiler
    list(APPEND CONFIGURE_ARGS "FC=ifx")
    list(APPEND CONFIGURE_ARGS "CC=cl.exe")
    list(APPEND CONFIGURE_ARGS "LD=link.exe")
    list(APPEND CONFIGURE_ARGS "AR=lib.exe")
    list(APPEND CONFIGURE_ARGS "ADD_FCFLAGS=-name:lowercase -assume:underscore")

    # find fortran libaries while configure compile tests
    set(IFX_ROOT "C:/PROGRA~2/Intel/oneAPI/compiler/latest")
    list(APPEND CONFIGURE_ARGS "LDFLAGS=-L${IFX_ROOT}/lib")

    set(ENV{PATH} "$ENV{PATH};${IFX_ROOT}/bin/")

    # acquire tools needed by configure
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES bash make findutils)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
    unset(ENV{MSYSTEM_PREFIX})

    ################# use custom_build_commands
    ## configure
    vcpkg_execute_build_process(
        COMMAND bash ./configure ${CONFIGURE_ARGS}
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME "execute-configure-${TARGET_TRIPLET}-${VCPKG_BUILD_TYPE}"
    )
    ## make
    vcpkg_execute_build_process(
        COMMAND make all
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME "execute-build-${TARGET_TRIPLET}-${VCPKG_BUILD_TYPE}"
    )
    ## install
    vcpkg_execute_build_process(
        COMMAND make DESTDIR=${SOURCE_PATH} install
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME "execute-install-${TARGET_TRIPLET}-${VCPKG_BUILD_TYPE}"
    )

    # install in staging
    file(INSTALL "${SOURCE_PATH}/install_dir/lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${SOURCE_PATH}/install_dir/bin" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(INSTALL "${SOURCE_PATH}/install_dir/include" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    # install
    file(INSTALL "${SOURCE_PATH}/install_dir/lib" DESTINATION "${CURRENT_INSTALLED_DIR}/lib")
    file(INSTALL "${SOURCE_PATH}/install_dir/bin" DESTINATION "${CURRENT_INSTALLED_DIR}/bin")
    file(INSTALL "${SOURCE_PATH}/install_dir/include" DESTINATION "${CURRENT_INSTALLED_DIR}/include")
    ##############
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Install usage file and custom FindModules
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/FindMUMPS_MPI.cmake"  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

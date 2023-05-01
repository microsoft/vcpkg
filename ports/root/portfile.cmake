vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if(TARGET_TRIPLET STREQUAL "x64-windows-static-md")
    set(VCPKG_BUILD_TYPE "release") # for testing
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO root-project/root
    REF 360c0c7c545fe5f8924e0dcbaeea314777595a60 # 55e26c43341d2175e9703311bef455f3bcf6bf44 04/25/2023
    SHA512 8d1f586bb2fe599d157e17b67e4fd219ac551b1420bb04a8d0351dde5d3cb794be9fbef7f21f46cb4933000c432495a4588511a8ab08f761d532703f0ad7627f # e56026de02bdca275933e0dd2131e2d527224c1956cdf1afb0b6d12090e5e90e7e2c3277040f388417b7becc58d4a659540271fe168d864a7f568ed6278164f7
    HEAD_REF master
    PATCHES
        fix_find_package.patch
        fix_ninja_msvc.diff
        more-patches.patch
        build-fixes.patch
        ryml.patch
        fix-curl-linkage.patch
        fix-debug.patch
        fix-afterimage.patch
)

message(WARNING "Cling vendors llvm as such there might be similar exported symbols as llvm. If you use both with the MSBuild integration you are on your own!")

#string(APPEND VCPKG_C_FLAGS_DEBUG "-D__TBB_NO_IMPLICIT_LINKAGE=1") # This requires otherwise _DEBUG to be set correctly. Should maybe be guarded with TBB_USE_DEBUG in the tbb headers instead. 
#string(APPEND VCPKG_CXX_FLAGS_DEBUG "-D__TBB_NO_IMPLICIT_LINKAGE=1")

vcpkg_find_acquire_program(GIT)
cmake_path(GET GIT PARENT_PATH GIT_DIR)
vcpkg_add_to_path("${GIT_DIR}")

vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/python3")
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    #WINDOWS_USE_MSBUILD
    OPTIONS
        -DBUILD_TESTING=OFF
        -DVCPKG_HOST_TRIPLET=${_HOST_TRIPLET}
        "-DPYTHON_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/python3/python${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        -Dbuiltin_tbb=OFF
        -Dbuiltin_gtest=OFF
        -Dbuiltin_ftgl=OFF
        -DCMAKE_CXX_STANDARD=17
        "-DLLVM_ENABLE_ASSERTIONS=on" # This list of settings are extracted from upstream CI with a few tweaks. 
        "-Dalien=off"
        "-Dall=off"
        "-Darrow=off"
        "-Dasan=off"
        "-Dasimage=on"
        "-Dasserts=off"
        "-Dbuiltin_afterimage=off"
        "-Dbuiltin_cppzmq=off"
        "-Dbuiltin_davix=off"
        "-Dbuiltin_fftw3=off"
        "-Dbuiltin_gsl=off"
        "-Dbuiltin_llvm=on"
        "-Dbuiltin_openssl=off"
        "-Dbuiltin_openui5=on"
        "-Dbuiltin_unuran=on"
        "-Dbuiltin_vc=off"
        "-Dbuiltin_vdt=off"
        "-Dbuiltin_veccore=off"
        "-Dbuiltin_xrootd=off"
        "-Dbuiltin_xxhash=off"
        "-Dbuiltin_zeromq=off"
        "-Dbuiltin_zlib=off"
        "-Dbuiltin_zstd=off"
        "-Dccache=off"
        "-Dcefweb=off"
        "-Dclad=on"
        "-Dclingtest=off"
        "-Dcocoa=off"
        "-Dcoverage=off"
        "-Dcuda=off"
        "-Dcudnn=off"
        "-Dcxxmodules=off"
        "-Ddaos=off"
        "-Ddataframe=on"
        "-Ddavix=off"
        "-Ddcache=off"
        "-Ddev=off"
        "-Ddistcc=off"
        "-Dexceptions=on"
        "-Dfcgi=off"
        "-Dfftw3=on"
        "-Dfitsio=on"
        "-Dfortran=off"
        "-Dgdml=on"
        "-Dgfal=off"
        "-Dgminimal=off"
        "-Dgnuinstall=off"
        "-Dgsl_shared=off"
        "-Dgviz=off"
        "-Dhttp=on"
        "-Dimt=on"
        "-Djemalloc=off"
        "-Dlibcxx=off"
        "-Dllvm13_broken_tests=off"
        "-Dmacos_native=off"
        "-Dmathmore=on"
        "-Dmemory_termination=off"
        "-Dminimal=off"
        "-Dminuit2=on"
        "-Dminuit2_mpi=off"
        "-Dminuit2_omp=off"
        "-Dmlp=on"
        "-Dmonalisa=off"
        "-Dmpi=off"
        "-Dmysql=off"
        "-Dodbc=on"
        "-Dopengl=on"
        "-Doracle=off"
        "-Dpgsql=off"
        "-Dpyroot2=off"
        "-Dpyroot3=off" # requires numpy
        "-Dpyroot=off"
        "-Dpyroot_legacy=off"
        "-Dpythia6=off"
        "-Dpythia6_nolink=off"
        "-Dpythia8=off"
        "-Dqt5web=off"
        "-Dqt6web=off"
        "-Dr=off"
        "-Droofit=on"
        "-Droofit_multiprocess=off"
        "-Droot7=on"
        "-Drootbench=off"
        "-Droottest=off" # build roottest
        "-Drpath=on"
        "-Druntime_cxxmodules=off"
        "-Dshadowpw=off"
        "-Dshared=on"
        "-Dsoversion=off"
        "-Dspectrum=on"
        "-Dsqlite=off"
        "-Dssl=off"
        "-Dtcmalloc=off"
        "-Dtest_distrdf_dask=off"
        "-Dtest_distrdf_pyspark=off"
        "-Dtesting=off" # build tests
        "-Dtmva-cpu=on"
        "-Dtmva-gpu=off"
        "-Dtmva-pymva=on"
        "-Dtmva-rmva=off"
        "-Dtmva-sofie=off"
        "-Dtmva=on"
        "-Dunuran=on"
        "-During=off"
        "-Dvc=off"
        "-Dvdt=off"
        "-Dveccore=off"
        "-Dvecgeom=off"
        "-Dwebgui=on"
        "-Dwin_broken_tests=off"
        "-Dx11=off"
        "-Dxml=off"
        "-Dxproofd=off"
        "-Dxrootd=off"
        ##--trace-expand
    OPTIONS_RELEASE
        "-Dwinrtdebug=off"
    OPTIONS_DEBUG
        "-Dwinrtdebug=on"
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/include"
        "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_tools(
  TOOL_NAMES
    bindexplib
    genreflex
    hadd
    proofserv
    rmkdepend
    root
    rootcint
    rootcling
    rootnb
    rootreadspeed
  AUTO_CLEAN)
  
vcpkg_install_copyright(FILE_LIST "${CURRENT_PACKAGES_DIR}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/LICENSE"
                    "${CURRENT_PACKAGES_DIR}/bin/__pycache__"
                    "${CURRENT_PACKAGES_DIR}/geom/gdml/doc")

# I don't actually know if this breaks stuff in root.
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/bin/root-config" "${SOURCE_PATH}" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/bin/root-config" "${CURRENT_PACKAGES_DIR}/lib" "\${libdir}")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/bin/root-config" "${CURRENT_INSTALLED_DIR}/lib" "\${libdir}")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/bin/root-config" "${CURRENT_INSTALLED_DIR}/include" "\${incdir}")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/etc/notebook/jupyter_notebook_config.py" "${CURRENT_PACKAGES_DIR}" "os.path.dirname(__file__)+'/../../'")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/compiledata.h" "-I${SOURCE_PATH}" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/RConfigOptions.h" "${CURRENT_INSTALLED_DIR}/lib" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/RConfigOptions.h" "${CURRENT_INSTALLED_DIR}/include" "")

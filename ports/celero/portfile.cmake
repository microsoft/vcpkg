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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/Celero-master)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/DigitalInBlue/Celero/archive/master.zip"
    FILENAME "celero-v2.1.0.zip"
    SHA512 d3971b102bd1785cf21712bcf2e39193e47d5faaa39421cb1cc788340bb67aed4c32343d3b45042813fcf503d48068bc2a2d26808e2e12d8515e29c60ef40c5c
)
vcpkg_extract_source_archive(${ARCHIVE})

# Disable building of the examples
set(CELEROExperiment_celeroDemoDoNotOptizeAway OFF)
set(CELEROExperiment_celeroDemoFileWrite OFF)
set(CELEROExperiment_celeroDemoMultithread OFF)
set(CELEROExperiment_celeroDemoSimple OFF)
set(CELEROExperiment_celeroDemoSimpleJUnit OFF)
set(CELEROExperiment_celeroDemoSleep OFF)
set(CELEROExperiment_celeroDemoToString OFF)
set(CELEROExperiment_celeroDemoTransform OFF)
set(CELEROExperiment_celeroExperimentCompressBools OFF)
set(CELEROExperiment_celeroExperimentCostOfPimpl OFF)
set(CELEROExperiment_celeroExperimentParameterPassing OFF)
set(CELEROExperiment_celeroExperimentParticles OFF)
set(CELEROExperiment_celeroExperimentSimpleComparison OFF)
set(CELEROExperiment_celeroExperimentSortingRandomInts OFF)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # PREFER_NINJA Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/celero RENAME copyright)

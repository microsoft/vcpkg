if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    message(FATAL_ERROR "Caffe cannot be built for the x86 architecture")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO willyd/caffe
    REF ef43793482835f90fe7ed5e492c53f64a36a2413
    SHA512 d253566cd63b6b748738271492e565a5eab31eeaf1b63edf8b93cbc4a29fbd07c07d486cf54871236b57939dadefe3d12dd3b6a1870271fde376bdeff865fa87
    HEAD_REF windows
)

if("cuda" IN_LIST FEATURES)
    set(CPU_ONLY OFF)
else()
    set(CPU_ONLY ON)
endif()

if("mkl" IN_LIST FEATURES)
    set(BLAS MKL)
else()
    set(BLAS Open)
endif()

if("opencv" IN_LIST FEATURES)
    set(USE_OPENCV ON)
else()
    set(USE_OPENCV OFF)
endif()

if("lmdb" IN_LIST FEATURES)
    set(USE_LMDB ON)
else()
    set(USE_LMDB OFF)
endif()

if("leveldb" IN_LIST FEATURES)
    set(USE_LEVELDB ON)
else()
    set(USE_LEVELDB OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DCOPY_PREREQUISITES=OFF
    -DINSTALL_PREREQUISITES=OFF
    # Set to ON to use python
    -DBUILD_python=OFF
    -DBUILD_python_layer=OFF
    -Dpython_version=3.6
    -DBUILD_matlab=OFF
    -DBUILD_docs=OFF
    -DBLAS=${BLAS}
    -DCPU_ONLY=${CPU_ONLY}
    -DBUILD_TEST=OFF
    -DUSE_LEVELDB=${USE_LEVELDB}
    -DUSE_OPENCV=${USE_OPENCV}
    -DUSE_LMDB=${${USE_LMDB}}
    -DUSE_NCCL=OFF
)

vcpkg_install_cmake()

# Move bin to tools
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(GLOB BINARIES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
foreach(binary ${BINARIES})
    get_filename_component(binary_name ${binary} NAME)
    file(RENAME ${binary} ${CURRENT_PACKAGES_DIR}/tools/${binary_name})
endforeach()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/python)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/python)

file(GLOB DEBUG_BINARIES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${DEBUG_BINARIES})

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/caffe/CaffeTargets-debug.cmake CAFFE_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" CAFFE_DEBUG_MODULE "${CAFFE_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/caffe/CaffeTargets-debug.cmake "${CAFFE_DEBUG_MODULE}")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)


file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/caffe RENAME copyright)

vcpkg_copy_pdbs()

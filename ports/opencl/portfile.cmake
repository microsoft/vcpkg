include(vcpkg_common_functions)


# OpenCL C headers
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-Headers
    REF f039db6764d52388658ef15c30b2237bbda49803
    SHA512 5909a85f96477d731059528303435f06255e98ed8df9d4cd2b62c744b5fe41408c69c0d4068421a2813eb9ad9d70d7f1bace9ebf0db19cc09e71bb8066127c5f
    HEAD_REF master
)

file(INSTALL
        "${SOURCE_PATH}/opencl22/CL/cl.h"
        "${SOURCE_PATH}/opencl22/CL/cl_d3d10.h"
        "${SOURCE_PATH}/opencl22/CL/cl_d3d11.h"
        "${SOURCE_PATH}/opencl22/CL/cl_dx9_media_sharing.h"
        "${SOURCE_PATH}/opencl22/CL/cl_dx9_media_sharing_intel.h"
        "${SOURCE_PATH}/opencl22/CL/cl_egl.h"
        "${SOURCE_PATH}/opencl22/CL/cl_ext.h"
        "${SOURCE_PATH}/opencl22/CL/cl_ext_intel.h"
        "${SOURCE_PATH}/opencl22/CL/cl_gl.h"
        "${SOURCE_PATH}/opencl22/CL/cl_gl_ext.h"
        "${SOURCE_PATH}/opencl22/CL/cl_platform.h"
        "${SOURCE_PATH}/opencl22/CL/cl_va_api_media_sharing_intel.h"
        "${SOURCE_PATH}/opencl22/CL/opencl.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include/CL
)


# OpenCL C++ headers
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-CLHPP
    REF 5dd8bb9e32a8e2f72621566b296ac8143a554270
    SHA512 2909fe2b979b52724ef8d285180d8bfd30bdd56cb79da4effc9e03b576ec7edb5497c99a9fa30541fe63037c84ddef21d4a73e7927f3813baab2a2afeecd55ab
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_DOCS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
)

# Obtained Python is not in PATH, CMake scripts cannot invoke it
#vcpkg_build_cmake(TARGET
#        generate_clhpp
#        generate_cl2hpp
#)

# Having Python invoked manually, there's no need to copy results
#file(INSTALL
#        "${CURRENT_BUILDTREES_DIR}/CL/cl.hpp"
#        "${CURRENT_BUILDTREES_DIR}/CL/cl2.hpp"
#    DESTINATION
#        ${CURRENT_PACKAGES_DIR}/include/CL
#)

vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" "${SOURCE_PATH}/gen_cl_hpp.py"
        -i ${SOURCE_PATH}/input_cl.hpp
        -o ${CURRENT_PACKAGES_DIR}/include/CL/cl.hpp
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME generate_clhpp-${TARGET_TRIPLET}-${CMAKE_BUILD_TYPE}
)

vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" "${SOURCE_PATH}/gen_cl_hpp.py"
        -i ${SOURCE_PATH}/input_cl2.hpp
        -o ${CURRENT_PACKAGES_DIR}/include/CL/cl2.hpp
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME generate_cl2hpp-${TARGET_TRIPLET}-${CMAKE_BUILD_TYPE}
)
message(STATUS "Generating OpenCL C++ headers done")

# OpenCL ICD loader
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-ICD-Loader
    REF 26a38983cbe5824fd5be03eab8d037758fc44360
    SHA512 3029f758ff0c39b57aa10d881af68e73532fd179c54063ed1d4529b7d6e27a5219e3c24b7fb5598d790ebcdc2441e00001a963671dc90fef2fc377c76d724f54
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static") 
    message(STATUS "Building the ICD loader as a static library is not supported. Building as DLLs instead.") 
    set(VCPKG_LIBRARY_LINKAGE "dynamic") 
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOPENCL_INCLUDE_DIRS=${CURRENT_PACKAGES_DIR}/include
)

vcpkg_build_cmake(TARGET OpenCL)

file(INSTALL
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/OpenCL.lib"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/OpenCL.exp"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/lib/Release
)

file(INSTALL
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/OpenCL.lib"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/OpenCL.exp"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/lib/Debug
)

file(INSTALL
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/OpenCL.dll"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/OpenCL.pdb"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/bin/Release
)

file(INSTALL
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/OpenCL.dll"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/OpenCL.pdb"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/bin/Debug
)

file(INSTALL
        "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}
)
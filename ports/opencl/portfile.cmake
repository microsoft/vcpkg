include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# OpenCL C headers
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-Headers
    REF f039db6764d52388658ef15c30b2237bbda49803
    SHA512 5909a85f96477d731059528303435f06255e98ed8df9d4cd2b62c744b5fe41408c69c0d4068421a2813eb9ad9d70d7f1bace9ebf0db19cc09e71bb8066127c5f
    HEAD_REF master
)

file(INSTALL
        "${SOURCE_PATH}/opencl22/CL"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include
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

vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" "${SOURCE_PATH}/gen_cl_hpp.py"
        -i ${SOURCE_PATH}/input_cl.hpp
        -o ${CURRENT_PACKAGES_DIR}/include/CL/cl.hpp
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME generate_clhpp-${TARGET_TRIPLET}
)

vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" "${SOURCE_PATH}/gen_cl_hpp.py"
        -i ${SOURCE_PATH}/input_cl2.hpp
        -o ${CURRENT_PACKAGES_DIR}/include/CL/cl2.hpp
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME generate_cl2hpp-${TARGET_TRIPLET}
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOPENCL_INCLUDE_DIRS=${CURRENT_PACKAGES_DIR}/include
)

vcpkg_build_cmake(TARGET OpenCL)

file(INSTALL
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/OpenCL.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/OpenCL.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/debug/lib
)

file(INSTALL
        "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright
)
file(COPY
        ${CMAKE_CURRENT_LIST_DIR}/usage
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

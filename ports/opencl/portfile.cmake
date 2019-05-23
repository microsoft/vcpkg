include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# OpenCL C headers
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-Headers
    REF a749dc6b85b3dcb57a54b17fcbf279c4f7198648
    SHA512 dffa1a26641fcb4fa8040971c603deeae111d0615d18e6205e35fe4cb1c19b4b0f5b331e9de28f6dc6aa21d9a549bc707e16768bb1cc0f5b6cfaec918e6ac465
    HEAD_REF master
)

file(INSTALL
        "${SOURCE_PATH}/CL"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include
)

# OpenCL C++ headers
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-CLHPP
    REF bbccc50adcd667d4f7c58960b586bdc60c13f7f0
    SHA512 1bfa4461d339586bf9f32498237631f20740e3cff29242b37db96ce98e9b3fad20878c983ddc37a21ff54c4025c79e19c1c6764f71d29376498d47d569e81784
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
    REF b342ff7b7f70a4b3f2cfc53215af8fa20adc3d86
    SHA512 6e7620a4a971fb292fd4079a2c011c7b31f553ec14bf5503462ac3fe6769931acf549e9c8a2d5aafd6307dc246432006ecf65e5d8dcbc14235bec72cc858b618
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/do-not-enforce-dynamic-library.patch"
)

if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    message(STATUS "Building the ICD loader as a static library on Windows is not supported. Building as DLLs instead.")
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOPENCL_INCLUDE_DIRS=${CURRENT_PACKAGES_DIR}/include
)

vcpkg_build_cmake(TARGET OpenCL)

if(NOT VCPKG_CMAKE_SYSTEM_NAME) # Empty when Windows
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
endif()
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
  file(INSTALL
          "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libOpenCL.a"
      DESTINATION
          ${CURRENT_PACKAGES_DIR}/lib
  )
  
  file(INSTALL
          "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libOpenCL.a"
      DESTINATION
          ${CURRENT_PACKAGES_DIR}/debug/lib
  )
endif()

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

file(COPY
        ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

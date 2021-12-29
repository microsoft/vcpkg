# Copyright Mathieu Malaterre <malat@debian.org>
# BSD (Same as jxrlib)
# Based on https://jxrlib.codeplex.com/discussions/440294
# and modified for vcpkg packaging
cmake_minimum_required(VERSION 2.8)
project(jxrlib C)

# Need shared libs for ABI
option(BUILD_SHARED_LIBS "Build shared libraries" ON)

# Add a debug postfix
set(CMAKE_DEBUG_POSTFIX "d")

# helper macro to preserve original Makefile convention
macro(JXR_MAKE_OBJ SET_NAME)
  foreach(src ${SRC_${SET_NAME}})
    list(APPEND OBJ_${SET_NAME} ${DIR_${SET_NAME}}/${src})
  endforeach()
endmacro()

if(NOT MSVC)
  add_definitions(-D__ANSI__)
  add_compile_options(-Wno-error=implicit-function-declaration)
endif()

include(TestBigEndian)
test_big_endian(ISBIGENDIAN)
if(ISBIGENDIAN)
  set(DEF_ENDIAN _BIG__ENDIAN_)
endif()

set(DIR_SYS image/sys)
set(DIR_DEC image/decode)
set(DIR_ENC image/encode)

set(DIR_GLUE jxrgluelib)
set(DIR_TEST jxrtestlib)
set(DIR_EXEC jxrencoderdecoder)

if(NOT JXRLIB_INSTALL_BIN_DIR)
  set(JXRLIB_INSTALL_BIN_DIR "bin")
endif()

if(NOT JXRLIB_INSTALL_LIB_DIR)
  set(JXRLIB_INSTALL_LIB_DIR "lib")
endif()

if(NOT JXRLIB_INSTALL_INCLUDE_DIR)
  set(JXRLIB_INSTALL_INCLUDE_DIR "include/jxrlib")
endif()

include_directories(
  common/include
  ${DIR_SYS}
  ${DIR_GLUE}
  ${DIR_TEST}
)


# JPEG-XR
set(SRC_SYS adapthuff.c image.c strcodec.c strPredQuant.c strTransform.c perfTimerANSI.c)
JXR_MAKE_OBJ(SYS)
set(SRC_DEC decode.c postprocess.c segdec.c strdec.c strInvTransform.c strPredQuantDec.c JXRTranscode.c)
JXR_MAKE_OBJ(DEC)
set(SRC_ENC encode.c segenc.c strenc.c strFwdTransform.c strPredQuantEnc.c)
JXR_MAKE_OBJ(ENC)

add_library(jpegxr ${OBJ_ENC} ${OBJ_DEC} ${OBJ_SYS})
set_property(TARGET jpegxr
  PROPERTY COMPILE_DEFINITIONS DISABLE_PERF_MEASUREMENT ${DEF_ENDIAN}
)
set_property(TARGET jpegxr PROPERTY LINK_INTERFACE_LIBRARIES "")
install(TARGETS jpegxr
  EXPORT JXRLibTargets
  RUNTIME DESTINATION ${JXRLIB_INSTALL_BIN_DIR}
  LIBRARY DESTINATION ${JXRLIB_INSTALL_LIB_DIR}
  ARCHIVE DESTINATION ${JXRLIB_INSTALL_LIB_DIR}
)

# JXR-GLUE
set(SRC_GLUE JXRGlue.c JXRMeta.c JXRGluePFC.c JXRGlueJxr.c)
JXR_MAKE_OBJ(GLUE)
set(SRC_TEST JXRTest.c JXRTestBmp.c JXRTestHdr.c JXRTestPnm.c JXRTestTif.c JXRTestYUV.c)
JXR_MAKE_OBJ(TEST)

add_library(jxrglue ${OBJ_GLUE} ${OBJ_TEST})
set_property(TARGET jxrglue
  PROPERTY COMPILE_DEFINITIONS DISABLE_PERF_MEASUREMENT ${DEF_ENDIAN}
)
set_property(TARGET jxrglue PROPERTY LINK_INTERFACE_LIBRARIES "")
install(TARGETS jxrglue
  EXPORT JXRLibTargets
  RUNTIME DESTINATION ${JXRLIB_INSTALL_BIN_DIR}
  LIBRARY DESTINATION ${JXRLIB_INSTALL_LIB_DIR}
  ARCHIVE DESTINATION ${JXRLIB_INSTALL_LIB_DIR}
)

target_link_libraries(jxrglue jpegxr)

# install rules
install(FILES jxrgluelib/JXRGlue.h jxrgluelib/JXRMeta.h jxrtestlib/JXRTest.h
  image/sys/windowsmediaphoto.h
  DESTINATION ${JXRLIB_INSTALL_INCLUDE_DIR} COMPONENT Headers
)
install(DIRECTORY common/include/ DESTINATION ${JXRLIB_INSTALL_INCLUDE_DIR}
  FILES_MATCHING PATTERN "*.h"
)

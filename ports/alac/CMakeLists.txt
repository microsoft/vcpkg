cmake_minimum_required (VERSION 3.9)
project (alac)

set(HEADERS
  codec/EndianPortable.h
  codec/aglib.h
  codec/ALACAudioTypes.h
  codec/ALACBitUtilities.h
  codec/ALACDecoder.h
  codec/ALACEncoder.h
  codec/dplib.h
  codec/matrixlib.h
)


set (SRCS
  codec/EndianPortable.c
  codec/ALACBitUtilities.c
  codec/ALACDecoder.cpp
  codec/ALACEncoder.cpp
  codec/ag_dec.c
  codec/ag_enc.c
  codec/dp_dec.c
  codec/dp_enc.c
  codec/matrix_dec.c
  codec/matrix_enc.c
)

set(EXE_SRCS
  convert-utility/main.cpp
  convert-utility/CAFFileALAC.cpp
)

if(MSVC)
  add_compile_options(/W4 -D_CRT_SECURE_NO_WARNINGS -DTARGET_OS_WIN32)
endif()

include_directories(. codec convert-utility)

add_library(libalac ${SRCS})

add_executable(alacconvert ${EXE_SRCS})
target_link_libraries(alacconvert libalac)

install(
  TARGETS libalac
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_TOOLS)
  install (
    TARGETS alacconvert
    RUNTIME DESTINATION tools/alac
  )
endif()

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES ${HEADERS} DESTINATION include/alac)
endif()

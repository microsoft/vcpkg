cmake_minimum_required(VERSION 3.8.0)
project(bigint)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

include_directories(".")

set(
  bigint_srcs
	BigUnsigned.cc
	BigInteger.cc
	BigIntegerAlgorithms.cc
	BigUnsignedInABase.cc
	BigIntegerUtils.cc
)

set(
  bigint_hh
	NumberlikeArray.hh
	BigUnsigned.hh
	BigInteger.hh
	BigIntegerAlgorithms.hh
	BigUnsignedInABase.hh
	BigIntegerLibrary.hh
	BigIntegerUtils.hh
)

add_library(bigint ${bigint_srcs})

install(
  TARGETS bigint
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES ${bigint_hh}  DESTINATION include/bigint)
endif()

cmake_minimum_required(VERSION 3.14.0)
project(bigint CXX)

if(MSVC)
	add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

set(BIGINT_SRCS
	BigUnsigned.cc
	BigInteger.cc
	BigIntegerAlgorithms.cc
	BigUnsignedInABase.cc
	BigIntegerUtils.cc
)

set(BIGINT_HH
	NumberlikeArray.hh
	BigUnsigned.hh
	BigInteger.hh
	BigIntegerAlgorithms.hh
	BigUnsignedInABase.hh
	BigIntegerLibrary.hh
	BigIntegerUtils.hh
)

add_library(bigint ${BIGINT_SRCS})
target_include_directories(bigint PUBLIC $<INSTALL_INTERFACE:include> $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)

install(
	TARGETS bigint
	EXPORT bigint-config
)

install(
	EXPORT bigint-config
	NAMESPACE bigint::
	DESTINATION share/bigint
)

if(NOT DISABLE_INSTALL_HEADERS)
	install(FILES ${BIGINT_HH} DESTINATION include/bigint)
endif()

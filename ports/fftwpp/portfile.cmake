
vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO dealias/fftwpp
	REF  f31cf133f9f4ddf23878cb0a83e848b1f76df1a7 #2.05
	SHA512 c929fb76aba8aa5f60615bdb9d3226118a8c6686adae39fc35c75dcebbc8c199a6ef20078aa82b0b0fd3a8db494c969fc7ba749659666eceb483afed9db5b5f6
    HEAD_REF master
)

# fftwpp is a header-only library
set (FFWTPP_SOURCE_FILES
     ${SOURCE_PATH}/Array.h
     ${SOURCE_PATH}/Array.cc
     ${SOURCE_PATH}/Complex.h
     ${SOURCE_PATH}/Complex.cc
     ${SOURCE_PATH}/align.h
     ${SOURCE_PATH}/cmult-sse2.h
     ${SOURCE_PATH}/convolution.h
     ${SOURCE_PATH}/convolution.cc
     ${SOURCE_PATH}/fftw++.h
     ${SOURCE_PATH}/fftw++.cc
     ${SOURCE_PATH}/seconds.h
     ${SOURCE_PATH}/statistics.h
     ${SOURCE_PATH}/transposeoptions.h
)

set(FFWTPP_DOXY_CFG ${SOURCE_PATH}/fftw++.doxycfg)

file(INSTALL ${FFWTPP_SOURCE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(INSTALL ${FFWTPP_DOXY_CFG} DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(INSTALL ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

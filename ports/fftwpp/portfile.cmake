
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dealias/fftwpp
    REF d05a2812995a52a3834140fd3ddd2e80bf8fcd42
    SHA512 851c79245eb61ebebfde97e7a8f3b9c061e84c9df571b5a7cafc3e959941e7b0792923e0ddefde4739582932d135c578c703195017da4bd34872adce7ab8c5ee
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

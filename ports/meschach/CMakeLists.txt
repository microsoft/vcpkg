cmake_minimum_required(VERSION 3.8.0)
project(meschach)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

set(meschach_srcs
  bdfactor.c
  bkpfacto.c
  chfactor.c
  copy.c
  err.c
  extras.c
  fft.c
  givens.c
  hessen.c
  hsehldr.c
  init.c
  iter0.c
  iternsym.c
  itersym.c
  ivecop.c
  lufactor.c
  machine.c
  matlab.c
  matop.c
  matrixio.c
  meminfo.c
  memory.c
  memstat.c
  mfunc.c
  norm.c
  otherio.c
  pxop.c
  qrfactor.c
  schur.c
  solve.c
  sparse.c
  sparseio.c
  spbkp.c
  spchfctr.c
  splufctr.c
  sprow.c
  spswap.c
  submat.c
  svd.c
  symmeig.c
  update.c
  vecop.c
  version.c
  zcopy.c
  zfunc.c
  zgivens.c
  zhessen.c
  zhsehldr.c
  zlufctr.c
  zmachine.c
  zmatio.c
  zmatlab.c
  zmatop.c
  zmemory.c
  znorm.c
  zqrfctr.c
  zschur.c
  zsolve.c
  ztorture.c
  zvecop.c
)
file(GLOB  meschach_headers "*.h")

include_directories(".")

add_library(meschach ${meschach_srcs})
target_compile_definitions(meschach PRIVATE -DHAVE_MEMORY_H -DHAVE_COMPLEX_H)

install(
  TARGETS meschach
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES ${meschach_headers} DESTINATION include/meschach)
endif()

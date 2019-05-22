cmake_minimum_required(VERSION 3.9)
project(libdisasm C)

set(CMAKE_DEBUG_POSTFIX d)

set(SRCS
  ia32_implicit.c
  ia32_implicit.h
  ia32_insn.c
  ia32_insn.h
  ia32_invariant.c
  ia32_invariant.h
  ia32_modrm.c
  ia32_modrm.h
  ia32_opcode_tables.c
  ia32_opcode_tables.h
  ia32_operand.c
  ia32_operand.h
  ia32_reg.c
  ia32_reg.h
  ia32_settings.c
  ia32_settings.h
  libdis.h
  qword.h
  x86_disasm.c
  x86_format.c
  x86_imm.c
  x86_imm.h
  x86_insn.c
  x86_misc.c
  x86_operand_list.c
  x86_operand_list.h
)

include_directories(libdisasm)

add_library(libdisasm ${SRCS})

install(
  TARGETS libdisasm
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES libdis.h DESTINATION include)
endif()

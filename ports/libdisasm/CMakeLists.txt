cmake_minimum_required(VERSION 3.9)
project(libdisasm C)

set(CMAKE_DEBUG_POSTFIX d)

set(SRCS
  libdisasm/ia32_implicit.c
  libdisasm/ia32_implicit.h
  libdisasm/ia32_insn.c
  libdisasm/ia32_insn.h
  libdisasm/ia32_invariant.c
  libdisasm/ia32_invariant.h
  libdisasm/ia32_modrm.c
  libdisasm/ia32_modrm.h
  libdisasm/ia32_opcode_tables.c
  libdisasm/ia32_opcode_tables.h
  libdisasm/ia32_operand.c
  libdisasm/ia32_operand.h
  libdisasm/ia32_reg.c
  libdisasm/ia32_reg.h
  libdisasm/ia32_settings.c
  libdisasm/ia32_settings.h
  libdisasm/libdis.h
  libdisasm/qword.h
  libdisasm/x86_disasm.c
  libdisasm/x86_format.c
  libdisasm/x86_imm.c
  libdisasm/x86_imm.h
  libdisasm/x86_insn.c
  libdisasm/x86_misc.c
  libdisasm/x86_operand_list.c
  libdisasm/x86_operand_list.h
)

include_directories(libdisasm)

add_library(libdisasm ${SRCS})

if (MSVC)
    target_compile_definitions(libdisasm PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()

install(
  TARGETS libdisasm
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES libdisasm/libdis.h DESTINATION include)
endif()

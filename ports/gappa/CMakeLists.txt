cmake_minimum_required (VERSION 3.0)

project (gappa)

find_package(Boost REQUIRED)

set(SOURCEFILES
	src/arithmetic/fixed.cpp
	src/arithmetic/float.cpp
	src/arithmetic/homogen.cpp
	src/arithmetic/relative.cpp
	src/backends/backend.cpp
	src/backends/coq.cpp
	src/backends/coq_common.cpp
	src/backends/coq_lambda.cpp
	src/backends/holl.cpp
	src/backends/latex.cpp
	src/numbers/interval.cpp
	src/numbers/io.cpp
	src/numbers/real.cpp
	src/numbers/round.cpp
	src/parser/ast.cpp
	src/parser/lexer.cpp
	src/parser/parser_aux.cpp
	src/parser/parser.cpp
	src/parser/pattern.cpp
	src/parser/ring.cpp
	src/proofs/basic_proof.cpp
	src/proofs/dichotomy.cpp
	src/proofs/proof_graph.cpp
	src/proofs/property.cpp
	src/proofs/rewriting.cpp
	src/proofs/schemes.cpp
	src/proofs/updater.cpp
	src/main.cpp
	src/parameters.cpp
)

include_directories(
    src
    src/arithmetic
    src/backends
    src/numbers
    src/parser
    src/proofs
)

set(HAVE_LIBGMP 1)
set(HAVE_LIBMPFR 1)
set(HAVE_UMAP 1)
set(YYTEXT_POINTER 1)
set(PACKAGE_NAME "gappa")
set(PACKAGE_STRING "gappa")
set(PACKAGE_TARNAME "gappa")
set(PACKAGE_VERSION "1.3.5")
set(PACKAGE_TARNAME "gappa.tar.gz")
set(PACKAGE_URL "")
set(PACKAGE_BUGREPORT "")
configure_file(./config.h.in ${CMAKE_CURRENT_SOURCE_DIR}/config.h)

find_library(MPFR_LIB NAMES "mpfr")
find_library(MPIR_LIB NAMES "mpir")

add_executable (gappa ${SOURCEFILES})
target_link_libraries(gappa PUBLIC Boost::boost ${MPFR_LIB} ${MPIR_LIB})
target_compile_definitions(gappa PRIVATE "YY_NO_UNISTD_H") 
install(
  TARGETS gappa
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

install(DIRECTORY src DESTINATION include FILES_MATCHING PATTERN "*.hpp")


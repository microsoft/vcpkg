cmake_minimum_required(VERSION 3.3.0)

project(MPFR VERSION 3.1.5 LANGUAGES C)

# Find GMP (or MPIR)
find_library(GMP_LIBRARY NAMES gmp mpir)
find_path(GMP_INCLUDE_DIR "gmp.h")

set(GMP_LIBRARIES ${GMP_LIBRARY})
set(GMP_INCLUDE_DIRS ${GMP_INCLUDE_DIR})

# Sources
set(SRCS
  src/gmp_printf.c
  src/mpfr.h
  src/mpf2mpfr.h
  src/mpfr-gmp.h
  src/mpfr-impl.h
  src/mpfr-intmax.h
  src/mpfr-longlong.h
  src/mpfr-thread.h
  src/exceptions.c
  src/extract.c
  src/uceil_exp2.c
  src/uceil_log2.c
  src/ufloor_log2.c
  src/add.c
  src/add1.c
  src/add_ui.c
  src/agm.c
  src/clear.c
  src/cmp.c
  src/cmp_abs.c
  src/cmp_si.c
  src/cmp_ui.c
  src/comparisons.c
  src/div_2exp.c
  src/div_2si.c	
  src/div_2ui.c
  src/div.c
  src/div_ui.c
  src/dump.c
  src/eq.c
  src/exp10.c
  src/exp2.c
  src/exp3.c
  src/exp.c
  src/frac.c
  src/frexp.c
  src/get_d.c
  src/get_exp.c
  src/get_str.c
  src/init.c
  src/inp_str.c
  src/isinteger.c
  src/isinf.c
  src/isnan.c
  src/isnum.c
  src/const_log2.c
  src/log.c
  src/modf.c
  src/mul_2exp.c
  src/mul_2si.c
  src/mul_2ui.c
  src/mul.c
  src/mul_ui.c
  src/neg.c
  src/next.c
  src/out_str.c
  src/printf.c
  src/vasprintf.c
  src/const_pi.c
  src/pow.c
  src/pow_si.c
  src/pow_ui.c
  src/print_raw.c
  src/print_rnd_mode.c	
  src/reldiff.c
  src/round_prec.c
  src/set.c
  src/setmax.c
  src/setmin.c
  src/set_d.c
  src/set_dfl_prec.c
  src/set_exp.c
  src/set_rnd.c
  src/set_f.c
  src/set_prc_raw.c
  src/set_prec.c
  src/set_q.c
  src/set_si.c
  src/set_str.c
  src/set_str_raw.c
  src/set_ui.c
  src/set_z.c
  src/sqrt.c
  src/sqrt_ui.c
  src/sub.c
  src/sub1.c
  src/sub_ui.c
  src/rint.c
  src/ui_div.c
  src/ui_sub.c
  src/urandom.c
  src/urandomb.c
  src/get_z_exp.c
  src/swap.c
  src/factorial.c
  src/cosh.c
  src/sinh.c
  src/tanh.c
  src/sinh_cosh.c
  src/acosh.c
  src/asinh.c
  src/atanh.c
  src/atan.c
  src/cmp2.c
  src/exp_2.c
  src/asin.c
  src/const_euler.c
  src/cos.c
  src/sin.c
  src/tan.c
  src/fma.c
  src/fms.c
  src/hypot.c
  src/log1p.c
  src/expm1.c
  src/log2.c
  src/log10.c
  src/ui_pow.c	
  src/ui_pow_ui.c
  src/minmax.c
  src/dim.c
  src/signbit.c
  src/copysign.c
  src/setsign.c
  src/gmp_op.c
  src/init2.c
  src/acos.c
  src/sin_cos.c
  src/set_nan.c
  src/set_inf.c
  src/set_zero.c
  src/powerof2.c
  src/gamma.c
  src/set_ld.c
  src/get_ld.c
  src/cbrt.c
  src/volatile.c
  src/fits_s.h
  src/fits_sshort.c
  src/fits_sint.c
  src/fits_slong.c
  src/fits_u.h
  src/fits_ushort.c
  src/fits_uint.c	
  src/fits_ulong.c
  src/fits_uintmax.c
  src/fits_intmax.c
  src/get_si.c
  src/get_ui.c
  src/zeta.c
  src/cmp_d.c
  src/erf.c
  src/inits.c
  src/inits2.c
  src/clears.c
  src/sgn.c
  src/check.c
  src/sub1sp.c	
  src/version.c
  src/mpn_exp.c
  src/mpfr-gmp.c
  src/mp_clz_tab.c
  src/sum.c
  src/add1sp.c	
  src/free_cache.c
  src/si_op.c
  src/cmp_ld.c
  src/set_ui_2exp.c
  src/set_si_2exp.c
  src/set_uj.c
  src/set_sj.c
  src/get_sj.c
  src/get_uj.c
  src/get_z.c
  src/iszero.c
  src/cache.c
  src/sqr.c	
  src/int_ceil_log2.c
  src/isqrt.c
  src/strtofr.c
  src/pow_z.c
  src/logging.c
  src/mulders.c
  src/get_f.c
  src/round_p.c
  src/erfc.c
  src/atan2.c
  src/subnormal.c
  src/const_catalan.c
  src/root.c	
  src/gen_inverse.h
  src/sec.c
  src/csc.c
  src/cot.c
  src/eint.c
  src/sech.c
  src/csch.c
  src/coth.c	
  src/round_near_x.c
  src/constant.c
  src/abort_prec_max.c
  src/stack_interface.c
  src/lngamma.c
  src/zeta_ui.c
  src/set_d64.c
  src/get_d64.c
  src/jn.c
  src/yn.c
  src/rem1.c
  src/get_patches.c
  src/add_d.c
  src/sub_d.c
  src/d_sub.c
  src/mul_d.c
  src/div_d.c
  src/d_div.c
  src/li2.c
  src/rec_sqrt.c
  src/min_prec.c
  src/buildopt.c
  src/digamma.c
  src/bernoulli.c
  src/isregular.c
  src/set_flt.c
  src/get_flt.c
  src/scale2.c
  src/set_z_exp.c
  src/ai.c
  src/gammaonethird.c
  src/ieee_floats.h		
  src/grandom.c)

configure_file("src/mparam_h.in" "mparam.h")

# Create and configure the target
add_library(mpfr ${SRCS})

# target_compile_definitions(mpfr PRIVATE HAVE_CONFIG_H)
target_compile_definitions(mpfr PRIVATE __MPFR_WITHIN_MPFR)
target_compile_definitions(mpfr PRIVATE HAVE_STDINT_H)
if(BUILD_SHARED_LIBS)
    target_compile_definitions(mpfr PRIVATE __GMP_LIBGMP_DLL)
endif()

target_link_libraries(mpfr ${GMP_LIBRARIES})

target_include_directories(mpfr PUBLIC ${GMP_INCLUDE_DIRS})
target_include_directories(mpfr PRIVATE ${CMAKE_BINARY_DIR})
target_include_directories(mpfr PRIVATE ${PROJECT_SOURCE_DIR})
target_include_directories(mpfr PRIVATE ${PROJECT_SOURCE_DIR}/src)

# Install
install(
  TARGETS mpfr
  EXPORT MPFRExports
  RUNTIME DESTINATION "bin"
  LIBRARY DESTINATION "lib"
  ARCHIVE DESTINATION "lib"
  )

install(
  FILES   src/mpfr.h
  DESTINATION "include"
)

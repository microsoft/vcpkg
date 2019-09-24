cmake_minimum_required(VERSION 3.3.0)

project(MPFR VERSION 4.0.2 LANGUAGES C)

# Find GMP (or MPIR)
find_library(GMP_LIBRARY NAMES gmp mpir)
find_path(GMP_INCLUDE_DIR "gmp.h")

set(GMP_LIBRARIES ${GMP_LIBRARY})
set(GMP_INCLUDE_DIRS ${GMP_INCLUDE_DIR})

# Sources
set(SRCS
  src/abort_prec_max.c
  src/acos.c
  src/acosh.c
  src/add.c
  src/add1.c
  src/add1sp.c
  src/add_d.c
  src/add_ui.c
  src/agm.c
  src/ai.c
  src/asin.c
  src/asinh.c
  src/atan.c
  src/atan2.c
  src/atanh.c
  src/bernoulli.c
  src/beta.c
  src/buildopt.c
  src/cache.c
  src/cbrt.c
  src/check.c
  src/clear.c
  src/clears.c
  src/cmp.c
  src/cmp2.c
  src/cmp_abs.c
  src/cmp_d.c
  src/cmp_ld.c
  src/cmp_si.c
  src/cmp_ui.c
  src/comparisons.c
  src/constant.c
  src/const_catalan.c
  src/const_euler.c
  src/const_log2.c
  src/const_pi.c
  src/copysign.c
  src/cos.c
  src/cosh.c
  src/cot.c
  src/coth.c
  src/csc.c
  src/csch.c
  src/digamma.c
  src/dim.c
  src/div.c
  src/div_2exp.c
  src/div_2si.c
  src/div_2ui.c
  src/div_d.c
  src/div_ui.c
  src/dump.c
  src/d_div.c
  src/d_sub.c
  src/eint.c
  src/eq.c
  src/erandom.c
  src/erf.c
  src/erfc.c
  src/exceptions.c
  src/exp.c
  src/exp10.c
  src/exp2.c
  src/exp3.c
  src/expm1.c
  src/exp_2.c
  src/extract.c
  src/factorial.c
  src/fits_intmax.c
  src/fits_sint.c
  src/fits_slong.c
  src/fits_sshort.c
  src/fits_uint.c
  src/fits_uintmax.c
  src/fits_ulong.c
  src/fits_ushort.c
  src/fma.c
  src/fmma.c
  src/fms.c
  src/frac.c
  src/free_cache.c
  src/frexp.c
  src/gamma.c
  src/gammaonethird.c
  src/gamma_inc.c
  src/get_d.c
  src/get_d64.c
  src/get_exp.c
  src/get_f.c
  src/get_float128.c
  src/get_flt.c
  src/get_ld.c
  src/get_patches.c
  src/get_q.c
  src/get_si.c
  src/get_sj.c
  src/get_str.c
  src/get_ui.c
  src/get_uj.c
  src/get_z.c
  src/get_z_exp.c
  src/gmp_op.c
  src/grandom.c
  src/hypot.c
  src/init.c
  src/init2.c
  src/inits.c
  src/inits2.c
  src/inp_str.c
  src/int_ceil_log2.c
  src/isinf.c
  src/isinteger.c
  src/isnan.c
  src/isnum.c
  src/isqrt.c
  src/isregular.c
  src/iszero.c
  src/jn.c
  src/li2.c
  src/lngamma.c
  src/log.c
  src/log10.c
  src/log1p.c
  src/log2.c
  src/logging.c
  src/log_ui.c
  src/minmax.c
  src/min_prec.c
  src/modf.c
  src/mpfr-gmp.c
  src/mpfr-mini-gmp.c
  src/mpn_exp.c
  src/mp_clz_tab.c
  src/mul.c
  src/mulders.c
  src/mul_2exp.c
  src/mul_2si.c
  src/mul_2ui.c
  src/mul_d.c
  src/mul_ui.c
  src/neg.c
  src/next.c
  src/nrandom.c
  src/odd_p.c
  src/out_str.c
  src/pool.c
  src/pow.c
  src/powerof2.c
  src/pow_si.c
  src/pow_ui.c
  src/pow_z.c
  src/printf.c
  src/print_raw.c
  src/print_rnd_mode.c
  src/random_deviate.c
  src/rec_sqrt.c
  src/reldiff.c
  src/rem1.c
  src/rint.c
  src/rndna.c
  src/root.c
  src/round_near_x.c
  src/round_p.c
  src/round_prec.c
  src/scale2.c
  src/sec.c
  src/sech.c
  src/set.c
  src/setmax.c
  src/setmin.c
  src/setsign.c
  src/set_d.c
  src/set_d64.c
  src/set_dfl_prec.c
  src/set_exp.c
  src/set_f.c
  src/set_float128.c
  src/set_flt.c
  src/set_inf.c
  src/set_ld.c
  src/set_nan.c
  src/set_prc_raw.c
  src/set_prec.c
  src/set_q.c
  src/set_rnd.c
  src/set_si.c
  src/set_si_2exp.c
  src/set_sj.c
  src/set_str.c
  src/set_str_raw.c
  src/set_ui.c
  src/set_ui_2exp.c
  src/set_uj.c
  src/set_z.c
  src/set_zero.c
  src/set_z_exp.c
  src/sgn.c
  src/signbit.c
  src/sin.c
  src/sinh.c
  src/sinh_cosh.c
  src/sin_cos.c
  src/si_op.c
  src/sqr.c
  src/sqrt.c
  src/sqrt_ui.c
  src/stack_interface.c
  src/strtofr.c
  src/sub.c
  src/sub1.c
  src/sub1sp.c
  src/subnormal.c
  src/sub_d.c
  src/sub_ui.c
  src/sum.c
  src/swap.c
  src/tan.c
  src/tanh.c
  src/ubf.c
  src/uceil_exp2.c
  src/uceil_log2.c
  src/ufloor_log2.c
  src/ui_div.c
  src/ui_pow.c
  src/ui_pow_ui.c
  src/ui_sub.c
  src/urandom.c
  src/urandomb.c
  src/vasprintf.c
  src/version.c
  src/volatile.c
  src/yn.c
  src/zeta.c
  src/zeta_ui.c)

configure_file("src/mparam_h.in" "mparam.h")

# Create and configure the target
add_library(mpfr ${SRCS})

# target_compile_definitions(mpfr PRIVATE HAVE_CONFIG_H)
target_compile_definitions(mpfr PRIVATE __MPFR_WITHIN_MPFR)
target_compile_definitions(mpfr PRIVATE HAVE_STDINT_H)
target_compile_definitions(mpfr PRIVATE HAVE_STDARG)
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

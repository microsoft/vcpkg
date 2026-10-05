#include <stdint.h>
#include <stddef.h>

#ifndef FASTLOWESS_H
#define FASTLOWESS_H

struct fastlowess_CppLowess;

struct fastlowess_CppOnlineLowess;

struct fastlowess_CppPredictHandle;

struct fastlowess_CppStreamingLowess;

/// Result struct that can be passed across FFI boundary.
/// All arrays are allocated by Rust and must be freed by Rust.
struct fastlowess_CppLowessResult {
  /// x values, in the same order as the input (length = n)
  double *x;
  /// Smoothed y values (length = n)
  double *y;
  /// Number of data points
  unsigned long n;
  /// Standard errors (NULL if not computed)
  double *standard_errors;
  /// Lower confidence bounds (NULL if not computed)
  double *confidence_lower;
  /// Upper confidence bounds (NULL if not computed)
  double *confidence_upper;
  /// Lower prediction bounds (NULL if not computed)
  double *prediction_lower;
  /// Upper prediction bounds (NULL if not computed)
  double *prediction_upper;
  /// Residuals (NULL if not computed)
  double *residuals;
  /// Robustness weights (NULL if not computed)
  double *robustness_weights;
  /// Per-point local fit derivative (slope) (NULL if not computed)
  double *derivative;
  /// Cross-validation scores (NULL if not computed, length = cv_scores_len)
  double *cv_scores;
  /// Number of cross-validation scores
  unsigned long cv_scores_len;
  /// Fraction used for smoothing
  double fraction_used;
  /// Number of iterations performed (-1 if not available)
  int iterations_used;
  /// Diagnostics (NaN if not computed)
  double rmse;
  double mae;
  double r_squared;
  double aic;
  double aicc;
  double effective_df;
  double residual_sd;
  /// Opaque handle for `cpp_predict()`, non-NULL only if `retain_model` was set to 1.
  /// Must eventually be freed via `cpp_predict_handle_free`.
  fastlowess_CppPredictHandle *predict_handle;
  /// Error message (NULL if no error)
  char *error;
};

/// Result of `cpp_predict()`. All arrays are allocated by Rust and must be freed via
/// `cpp_predict_free_result`.
struct fastlowess_CppPredictResult {
  /// Predicted y values, one per query point (length = n)
  double *y;
  /// Number of query points
  unsigned long n;
  /// Standard errors (NULL if not requested)
  double *standard_errors;
  /// Lower confidence bounds (NULL if not requested)
  double *confidence_lower;
  /// Upper confidence bounds (NULL if not requested)
  double *confidence_upper;
  /// Lower prediction bounds (NULL if not requested)
  double *prediction_lower;
  /// Upper prediction bounds (NULL if not requested)
  double *prediction_upper;
  /// Local fit's derivative (slope) at each query point (NULL if not requested)
  double *derivative;
  /// Error message (NULL if no error)
  char *error;
};

struct fastlowess_CppOnlineOutput {
  int has_value;
  double y;
  double standard_error;
  double residual;
  double robustness_weight;
  int iterations_used;
  /// Local fit derivative (slope) for the latest point (NaN if not computed)
  double derivative;
  /// Lower confidence interval bound for the latest point (NaN if not computed)
  double confidence_lower;
  /// Upper confidence interval bound for the latest point (NaN if not computed)
  double confidence_upper;
  /// Lower prediction interval bound for the latest point (NaN if not computed)
  double prediction_lower;
  /// Upper prediction interval bound for the latest point (NaN if not computed)
  double prediction_upper;
  char *error;
};

extern "C" {

const char *cpp_last_error_message();

/// Returns 1 if this library was built with the `gpu` Cargo feature enabled, 0 otherwise.
int cpp_gpu_enabled();

/// Returns the crate version as a static, null-terminated C string.
const char *cpp_version();

/// C++ wrapper constructor.
///
/// # Safety
/// Pointers must be valid null-terminated strings or null. Arrays must be valid.
fastlowess_CppLowess *cpp_lowess_new(double fraction,
                                     int iterations,
                                     double delta,
                                     const char *weight_function,
                                     const char *robustness_method,
                                     const char *scaling_method,
                                     const char *boundary_policy,
                                     double confidence_intervals,
                                     double prediction_intervals,
                                     int return_diagnostics,
                                     int return_residuals,
                                     int return_robustness_weights,
                                     int return_derivative,
                                     const char *zero_weight_fallback,
                                     double auto_converge,
                                     const double *cv_fractions,
                                     unsigned long cv_fractions_len,
                                     const char *cv_method,
                                     int cv_k,
                                     int parallel,
                                     int return_se,
                                     int return_sorted,
                                     const char *backend,
                                     const char *missing,
                                     int retain_model);

/// Set CV seed for reproducible K-fold splits.
///
/// # Safety
/// ptr must be valid.
void cpp_lowess_set_cv_seed(fastlowess_CppLowess *ptr, unsigned long seed);

/// Fit the batch model.
///
/// # Safety
/// `ptr` must be a valid CppLowess pointer. `x_values` and `y_values` must be
/// valid arrays of length `n`. `custom_weights` is optional: pass null and 0 to omit.
fastlowess_CppLowessResult cpp_lowess_fit(fastlowess_CppLowess *ptr,
                                          const double *x_values,
                                          const double *y_values,
                                          unsigned long n,
                                          const double *custom_weights,
                                          unsigned long custom_weights_len);

/// Free batch model.
///
/// # Safety
/// `ptr` must be a valid pointer returned by `cpp_lowess_new` or null.
void cpp_lowess_free(fastlowess_CppLowess *ptr);

/// Evaluate a fitted model (retained via `retain_model = 1`) at out-of-sample query
/// points not in the training set.
///
/// # Safety
/// `handle` must be a valid pointer returned via `CppLowessResult::predict_handle`.
/// `new_x` must be a valid array of length `new_x_len`. `extrapolation` must be a
/// valid null-terminated string or null (defaults to "clamp").
fastlowess_CppPredictResult cpp_predict(fastlowess_CppPredictHandle *handle,
                                        const double *new_x,
                                        unsigned long new_x_len,
                                        int return_se,
                                        double confidence_level,
                                        double prediction_level,
                                        int return_derivative,
                                        const char *extrapolation,
                                        double max_extrapolation_distance,
                                        double max_neighbor_distance);

/// Free a CppPredictResult's heap-allocated buffers.
///
/// # Safety
/// `result` must be a valid pointer to a CppPredictResult struct.
void cpp_predict_free_result(fastlowess_CppPredictResult *result);

/// Free a `CppPredictHandle` returned via `CppLowessResult::predict_handle`.
///
/// # Safety
/// `ptr` must be a valid pointer returned via `CppLowessResult::predict_handle`, or null.
void cpp_predict_handle_free(fastlowess_CppPredictHandle *ptr);

/// Create a new Streaming Lowess model.
///
/// # Safety
/// Pointers must be valid null-terminated strings or null.
fastlowess_CppStreamingLowess *cpp_streaming_new(double fraction,
                                                 int iterations,
                                                 double delta,
                                                 const char *weight_function,
                                                 const char *robustness_method,
                                                 const char *scaling_method,
                                                 const char *boundary_policy,
                                                 int return_diagnostics,
                                                 int return_residuals,
                                                 int return_robustness_weights,
                                                 int return_derivative,
                                                 const char *zero_weight_fallback,
                                                 double auto_converge,
                                                 int parallel,
                                                 int chunk_size,
                                                 int overlap,
                                                 const char *merge_strategy,
                                                 const char *missing,
                                                 int return_se,
                                                 double confidence_intervals,
                                                 double prediction_intervals);

/// Process a chunk of data.
///
/// # Safety
/// `ptr` must be valid. `x_values` and `y_values` must be valid arrays of
/// length `n`.
fastlowess_CppLowessResult cpp_streaming_process(fastlowess_CppStreamingLowess *ptr,
                                                 const double *x_values,
                                                 const double *y_values,
                                                 unsigned long n);

/// Finalize the streaming process.
///
/// # Safety
/// `ptr` must be valid.
fastlowess_CppLowessResult cpp_streaming_finalize(fastlowess_CppStreamingLowess *ptr);

/// Free streaming model.
///
/// # Safety
/// `ptr` must be valid or null.
void cpp_streaming_free(fastlowess_CppStreamingLowess *ptr);

/// Create a new Online Lowess model.
///
/// # Safety
/// Pointers must be valid null-terminated strings or null.
fastlowess_CppOnlineLowess *cpp_online_new(double fraction,
                                           int iterations,
                                           double delta,
                                           const char *weight_function,
                                           const char *robustness_method,
                                           const char *scaling_method,
                                           const char *boundary_policy,
                                           int return_robustness_weights,
                                           int return_derivative,
                                           const char *zero_weight_fallback,
                                           double auto_converge,
                                           int window_capacity,
                                           int min_points,
                                           const char *update_mode,
                                           const char *missing,
                                           int return_se,
                                           double confidence_intervals,
                                           double prediction_intervals);

/// Add a single point to the model and return its smoothed value.
/// `has_value = 0` in the result means the window is still filling.
///
/// # Safety
/// `ptr` must be a valid `CppOnlineLowess` pointer.
fastlowess_CppOnlineOutput cpp_online_add_point(fastlowess_CppOnlineLowess *ptr,
                                                double x,
                                                double y);

/// Free the error string in a CppOnlineOutput (call only when error != NULL).
///
/// # Safety
/// `output` must be a valid pointer and `output->error` must have been allocated by Rust.
void cpp_online_free_output(fastlowess_CppOnlineOutput *output);

/// Free online model.
///
/// # Safety
/// `ptr` must be valid or null.
void cpp_online_free(fastlowess_CppOnlineLowess *ptr);

/// Free a CppLowessResult.
///
/// # Safety
/// `result` must be a valid pointer to a CppLowessResult struct.
void cpp_lowess_free_result(fastlowess_CppLowessResult *result);

}  // extern "C"

#endif  // FASTLOWESS_H

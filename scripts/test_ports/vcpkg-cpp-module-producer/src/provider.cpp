module provider;

int get_value() {
  return value;
}

bool is_debug_build() {
#ifdef NDEBUG
  return false;
#else
  return true;
#endif
}

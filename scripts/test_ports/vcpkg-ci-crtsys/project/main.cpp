#include <string>
#include <vector>

#include <ntl/driver>

ntl::status ntl::main(ntl::driver &driver,
                      const std::wstring &registry_path) {
  (void)registry_path;

  std::vector<int> values = {1, 2, 3};
  driver.on_unload([values]() { (void)values; });
  return ntl::status::ok();
}

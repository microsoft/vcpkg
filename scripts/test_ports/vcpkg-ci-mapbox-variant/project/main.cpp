#include <mapbox/variant.hpp>
#include <stdexcept>
struct check
{
    template <typename T>
    void operator()(T const& val) const
    {
        if (val != 0) throw std::runtime_error("invalid");
    }
};
int main()
{
    typedef mapbox::util::variant<bool, int, double> variant_type;
    variant_type v(0);
    mapbox::util::apply_visitor(check(), v);
    return 0;
}

#define DECIMAL_CALL_BY_REFERENCE 0
#define DECIMAL_GLOBAL_ROUNDING 1

#include <bid_conf.h>
#include <bid_functions.h>

int main()
{
    unsigned int flags = 0;
    BID_UINT128 x = bid128_from_string(const_cast<char*>("1.25673"), &flags);
    BID_UINT128 y = bid128_from_int32(5);
    auto result = bid128_add(x, y, &flags);
}

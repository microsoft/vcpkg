#include <bid_conf.h>
#include <bid_functions.h>

int main()
{
    unsigned int flags = 0;
    _IDEC_round round_mode = 0;
    BID_UINT128 x, y;
    bid128_from_string(const_cast<char*>("1.25673"), round_mode, &flags);
    bid128_from_int32(5);
    auto result = bid128_add(x, y, round_mode, &flags);
}

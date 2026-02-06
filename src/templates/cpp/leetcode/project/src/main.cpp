#include <Private/helpers.h>

enum class Algorithm
{
    Default
};
template <Algorithm A> class Problem;

template<> class Problem<Algorithm::Default>
{

public:

    static
    bool solution()
    {
        return true;
    }

};

bool Test(
    bool expected
)
{
    auto result = Problem<Algorithm::Default>::
        solution();

    if (result != expected)
        __debugbreak();

    return result == expected;
}

int main()
{
    helpers::print::print_bool(
        Test(true)
    );

    return helpers::prompt::wait();
}

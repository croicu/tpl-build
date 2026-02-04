#include <iostream>

#include "library.h"

int main()
{
    int expected = 1;
    int actual = library(expected);

    std::cout << "library() actual: " << actual << " expected: " << expected << std::endl;

    if (actual != expected)
    {
        std::cout << "Test failed!" << std::endl;

        return 1;
    }

    return 0;
}

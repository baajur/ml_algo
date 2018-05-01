//
// Implement the following scenario:
//
// coeffs = [0, 0, 0]
//
// [1, 2, 3] [7]
// [4, 5, 6] [8]
//
// iteration 1:
// eta = 2
//
// c_1 = c_1 - 2 * eta * x_1_1 * (7 - coeffs . x_1) = 0 - 2 * 2 * 1 * (7 - 0) = 0 - 4 * 7 = -28
// c_2 = c_2 - 2 * eta * x_1_2 * (7 - coeffs . x_1) = 0 - 2 * 2 * 2 * (7 - 0) = 0 - 8 * 7 = -56
// c_3 = c_3 - 2 * eta * x_1_3 * (7 - coeffs . x_1) = 0 - 2 * 2 * 3 * (7 - 0) = 0 - 12 * 7 = -84
//
// c_1 = c_1 - 2 * eta * x_2_1 * (8 - coeffs . x_2) = 0 - 2 * 2 * 4 * (8 - 0) = 0 - 16 * 8 = -128
// c_2 = c_2 - 2 * eta * x_2_2 * (8 - coeffs . x_2) = 0 - 2 * 2 * 5 * (8 - 0) = 0 - 20 * 8 = - 160
// c_3 = c_3 - 2 * eta * x_2_3 * (8 - coeffs . x_2) = 0 - 2 * 2 * 6 * (8 - 0) = 0 - 24 * 8 = -192
//
// coeffs = [-28, -56, -84] + [-128, -160, -192] = [-156, -216, -276]

void main() {

}
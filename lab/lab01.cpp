// Написать программу, реализующую метод Якоби решения СЛАУ x = b + ax
// в приращениях. Найти решение СЛАУ с заданной точностью ε (ε=10^(-3),
// 10^(-4), 10^(-5)). Для каждого значения точности вывести количество
// итераций. Критерий окончания итерационного процесса:
// ‖𝑥^(i+1) − 𝑥^i‖ < 𝜀1, 𝜀1 = (1−‖𝛼‖ / ‖𝛼‖) 𝜀
// ---
// Корректировать элементы матрицы А, постепенно уходя от
// диагонального преобладания. После каждой корректировки пересчитывать
// правую часть СЛАУ. Добиться, чтобы количество итераций было около 1000.
// В итоге будет получена СЛАУ
// А^∗ 𝑥 = 𝑓^∗.
// Для исходной СЛАУ и каждого варианта корректировки вычислить и
// сравнить абсолютную погрешность и оценку погрешности
// ∆= ‖𝑥^k − 𝑥‖ ≤ ‖𝛼‖^(𝑘+1) / (1−‖𝛼‖) ‖b‖.
// Сравнить нормы матриц А и А∗.
// ---
// Модифицировать программную реализацию итерационного процесса
// метода Якоби, чтобы получилась программная реализация итерационного
// процесса метода Зейделя решения СЛАУ в приращениях. Сколько
// итераций требуется для решения с заданной точностью ε
// СЛАУ A x = f и СЛАУ A^* x = f^* методом Зейделя?

#include <iostream>
#include <cmath>
#include <vector>
using namespace std;

const int n = 5;
const float EPS[] = {1e-3, 1e-4, 1e-5};
const int MAX_ITER = 10000;

// Функция вычисления бесконечной нормы вектора
float vector_norm(const vector<float>& vec) {
    float norm = 0;
    for (float v : vec) norm = max(norm, abs(v));
    return norm;
}

// Функция вычисления нормы матрицы (максимальная сумма строки)
float matrix_norm(const vector<vector<float>>& mat) {
    float norm = 0;
    for (const auto& row : mat) {
        float sum = 0;
        for (float val : row) sum += abs(val);
        norm = max(norm, sum);
    }
    return norm;
}

// Метод Якоби
void jacobi(const vector<vector<float>>& alpha, const vector<float>& beta, 
            float epsilon, vector<float>& x, int& iterations) {
    vector<float> x_prev(n, 0);
    x = beta; // Начальное приближение
    float alpha_norm = matrix_norm(alpha);
    float epsilon1 = (1 - alpha_norm) / alpha_norm * epsilon;

    iterations = 0;
    while (iterations < MAX_ITER) {
        x_prev = x;
        vector<float> delta(n, 0);
        
        for (int i = 0; i < n; ++i) {
            delta[i] = beta[i];
            for (int j = 0; j < n; ++j) {
                if (i != j) delta[i] -= alpha[i][j] * x_prev[j];
            }
            x[i] = x_prev[i] + delta[i];
        }
        
        // Проверка условия останова
        vector<float> diff(n);
        for (int i = 0; i < n; ++i) diff[i] = x[i] - x_prev[i];
        if (vector_norm(diff) < epsilon1) break;
        
        iterations++;
    }
}

// Метод Зейделя
void seidel(const vector<vector<float>>& alpha, const vector<float>& beta, 
           float epsilon, vector<float>& x, int& iterations) {
    vector<float> x_prev(n, 0);
    x = beta;
    float alpha_norm = matrix_norm(alpha);
    float epsilon1 = (1 - alpha_norm) / alpha_norm * epsilon;

    iterations = 0;
    while (iterations < MAX_ITER) {
        x_prev = x;
        
        for (int i = 0; i < n; ++i) {
            float delta = beta[i];
            for (int j = 0; j < n; ++j) {
                if (j < i) delta -= alpha[i][j] * x[j];
                else if (j > i) delta -= alpha[i][j] * x_prev[j];
            }
            x[i] = x_prev[i] + delta;
        }
        
        vector<float> diff(n);
        for (int i = 0; i < n; ++i) diff[i] = x[i] - x_prev[i];
        if (vector_norm(diff) < epsilon1) break;
        
        iterations++;
    }
}

int main() {
    // Исходная матрица A с диагональным преобладанием
    vector<vector<float>> A = {
        {10, 1, 1, 1, 1},
        {1, 10, 1, 1, 1},
        {1, 1, 10, 1, 1},
        {1, 1, 1, 10, 1},
        {1, 1, 1, 1, 10}
    };
    
    vector<float> x_true = {1, 2, 3, 4, 5}; // Истинное решение
    vector<float> f(n, 0);
    
    // Вычисление вектора f
    for (int i = 0; i < n; ++i)
        for (int j = 0; j < n; ++j)
            f[i] += A[i][j] * x_true[j];
    
    // Преобразование матрицы A и вектора f для итерационных методов
    vector<vector<float>> alpha(n, vector<float>(n, 0));
    vector<float> beta(n);
    for (int i = 0; i < n; ++i) {
        float aii = A[i][i];
        beta[i] = f[i] / aii;
        for (int j = 0; j < n; ++j) {
            if (i != j) alpha[i][j] = A[i][j] / aii;
        }
    }
    
    // Решение методом Якоби для разных точностей
    cout << "Метод Якоби:\n";
    for (float eps : EPS) {
        vector<float> x(n);
        int iter;
        jacobi(alpha, beta, eps, x, iter);
        cout << "Точность: " << eps << ", итераций: " << iter << endl;
    }
    
    // Корректировка матрицы A (пример: уменьшаем диагональные элементы)
    vector<vector<float>> A_star = A;
    for (int i = 0; i < n; ++i) {
        A_star[i][i] *= 0.9; // Уменьшаем диагональное преобладание
    }
    
    // Пересчет вектора f для A*
    vector<float> f_star(n, 0);
    for (int i = 0; i < n; ++i)
        for (int j = 0; j < n; ++j)
            f_star[i] += A_star[i][j] * x_true[j];
    
    // Преобразование для новой матрицы
    vector<vector<float>> alpha_star(n, vector<float>(n, 0));
    vector<float> beta_star(n);
    for (int i = 0; i < n; ++i) {
        float aii = A_star[i][i];
        beta_star[i] = f_star[i] / aii;
        for (int j = 0; j < n; ++j) {
            if (i != j) alpha_star[i][j] = A_star[i][j] / aii;
        }
    }
    
    // Решение скорректированной системы методом Якоби
    cout << "\nМетод Якоби для скорректированной матрицы:\n";
    vector<float> x_star(n);
    int iter_star;
    jacobi(alpha_star, beta_star, 1e-5, x_star, iter_star);
    cout << "Итераций: " << iter_star << endl;
    
    // Решение методом Зейделя
    cout << "\nМетод Зейделя для исходной системы:\n";
    vector<float> x_seidel(n);
    int iter_seidel;
    seidel(alpha, beta, 1e-5, x_seidel, iter_seidel);
    cout << "Итераций: " << iter_seidel << endl;
    
    cout << "\nМетод Зейделя для скорректированной системы:\n";
    vector<float> x_seidel_star(n);
    int iter_seidel_star;
    seidel(alpha_star, beta_star, 1e-5, x_seidel_star, iter_seidel_star);
    cout << "Итераций: " << iter_seidel_star << endl;
    
    return 0;
}
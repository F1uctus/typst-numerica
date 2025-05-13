// Написать программы для численного решения дифференциального
// уравнения на отрезке [0,1], удовлетворяющего заданному начальному условию,
// методами Рунге-Кутты и Адамса-Бошфорта 4 порядка. Количество шагов на
// отрезке: n=5, 10, 20, 40, 80… Найти абсолютную погрешность решения для
// каждого метода на последнем шаге интегрирования. Убедиться, что реализованы
// методы 4 порядка.
// Функции:
// 1. y' = y - x, y(0) = n + 4
// 2. y' = y - 2x/y, y(0) = n + 4
// 3. y' = 2y/x + 2x^3, y(1) = 2, C=1, x ∈ [1,2]. Аналитическое решение: y = Cx^2 + x^4
// ---
// Для заданного ДУ подобрать количество шагов в четырехэтапных
// метода Рунге-Кутты и Адамса-Бошфорта так, чтобы решение имело заданную
// точность. Сравнить трудоемкость методов.
// ---
// Реализовать четырехэтапные методы Рунге-Кутты и Адамса-
// Бошфорта для ДУ 2 порядка. Задача из [1], стр. 34.

#include <iostream>
#include <vector>
#include <cmath>
#include <iomanip>

using namespace std;

double f(double x, double y) {
    return y - x;
}

double exact_solution(double x, int n) {
    return x + 1 + (n + 3) * exp(x);
}

double runge_kutta(double y0, double a, double b, int n) {
    double h = (b - a) / n;
    double x = a;
    double y = y0;
    for (int i = 0; i < n; ++i) {
        double k1 = h * f(x, y);
        double k2 = h * f(x + h/2, y + k1/2);
        double k3 = h * f(x + h/2, y + k2/2);
        double k4 = h * f(x + h, y + k3);
        y += (k1 + 2*k2 + 2*k3 + k4) / 6;
        x += h;
    }
    return y;
}

double adams_bashforth(double y0, double a, double b, int n) {
    if (n < 4) return NAN;
    double h = (b - a) / n;
    vector<double> x(n+1), y(n+1);
    x[0] = a;
    y[0] = y0;

    for (int i = 0; i < 3; ++i) {
        double k1 = h * f(x[i], y[i]);
        double k2 = h * f(x[i] + h/2, y[i] + k1/2);
        double k3 = h * f(x[i] + h/2, y[i] + k2/2);
        double k4 = h * f(x[i] + h, y[i] + k3);
        y[i+1] = y[i] + (k1 + 2*k2 + 2*k3 + k4) / 6;
        x[i+1] = x[i] + h;
    }

    for (int i = 3; i < n; ++i) {
        double f_n = f(x[i], y[i]);
        double f_n1 = f(x[i-1], y[i-1]);
        double f_n2 = f(x[i-2], y[i-2]);
        double f_n3 = f(x[i-3], y[i-3]);
        y[i+1] = y[i] + h * (55*f_n - 59*f_n1 + 37*f_n2 - 9*f_n3) / 24;
        x[i+1] = x[i] + h;
    }
    return y[n];
}

int main() {
    vector<int> n_values = {5, 10, 20, 40, 80};
    double a = 0.0, b = 1.0;
    cout << fixed << setprecision(9);
    for (int n : n_values) {
        double y0 = n + 4;
        double y_rk = runge_kutta(y0, a, b, n);
        double y_ab = adams_bashforth(y0, a, b, n);
        double y_exact = exact_solution(b, n);
        cout << "n = " << n << endl;
        cout << "RK4 Error: " << abs(y_rk - y_exact) << endl;
        cout << "AB4 Error: " << abs(y_ab - y_exact) << endl << endl;
    }
}

#include <iostream>
#include <vector>
#include <cmath>
#include <iomanip>

using namespace std;

double f(double x, double y) {
    return y - (2 * x) / y;
}

double exact_solution(double x, int n) {
    double C = pow(n + 4, 2) - 1;
    return sqrt(2*x + 1 + C * exp(2*x));
}

double runge_kutta(double y0, double a, double b, int n) {
    double h = (b - a) / n;
    double x = a;
    double y = y0;
    for (int i = 0; i < n; ++i) {
        double k1 = h * f(x, y);
        double k2 = h * f(x + h/2, y + k1/2);
        double k3 = h * f(x + h/2, y + k2/2);
        double k4 = h * f(x + h, y + k3);
        y += (k1 + 2*k2 + 2*k3 + k4) / 6;
        x += h;
    }
    return y;
}

double adams_bashforth(double y0, double a, double b, int n) {
    if (n < 4) return NAN;
    double h = (b - a) / n;
    vector<double> x(n+1), y(n+1);
    x[0] = a;
    y[0] = y0;

    for (int i = 0; i < 3; ++i) {
        double k1 = h * f(x[i], y[i]);
        double k2 = h * f(x[i] + h/2, y[i] + k1/2);
        double k3 = h * f(x[i] + h/2, y[i] + k2/2);
        double k4 = h * f(x[i] + h, y[i] + k3);
        y[i+1] = y[i] + (k1 + 2*k2 + 2*k3 + k4) / 6;
        x[i+1] = x[i] + h;
    }

    for (int i = 3; i < n; ++i) {
        double f_n = f(x[i], y[i]);
        double f_n1 = f(x[i-1], y[i-1]);
        double f_n2 = f(x[i-2], y[i-2]);
        double f_n3 = f(x[i-3], y[i-3]);
        y[i+1] = y[i] + h * (55*f_n - 59*f_n1 + 37*f_n2 - 9*f_n3) / 24;
        x[i+1] = x[i] + h;
    }
    return y[n];
}

int main() {
    vector<int> n_values = {5, 10, 20, 40, 80};
    double a = 0.0, b = 1.0;
    cout << fixed << setprecision(9);
    for (int n : n_values) {
        double y0 = n + 4;
        double y_rk = runge_kutta(y0, a, b, n);
        double y_ab = adams_bashforth(y0, a, b, n);
        double y_exact = exact_solution(b, n);
        cout << "n = " << n << endl;
        cout << "RK4 Error: " << abs(y_rk - y_exact) << endl;
        cout << "AB4 Error: " << abs(y_ab - y_exact) << endl << endl;
    }
}

#include <iostream>
#include <vector>
#include <cmath>
#include <iomanip>

using namespace std;

double f(double x, double y) {
    return 2*y/x + 2*pow(x, 3);
}

double exact_solution(double x) {
    return pow(x, 2) + pow(x, 4);
}

double runge_kutta(double y0, double a, double b, int n) {
    double h = (b - a) / n;
    double x = a;
    double y = y0;
    for (int i = 0; i < n; ++i) {
        double k1 = h * f(x, y);
        double k2 = h * f(x + h/2, y + k1/2);
        double k3 = h * f(x + h/2, y + k2/2);
        double k4 = h * f(x + h, y + k3);
        y += (k1 + 2*k2 + 2*k3 + k4) / 6;
        x += h;
    }
    return y;
}

double adams_bashforth(double y0, double a, double b, int n) {
    if (n < 4) return NAN;
    double h = (b - a) / n;
    vector<double> x(n+1), y(n+1);
    x[0] = a;
    y[0] = y0;

    for (int i = 0; i < 3; ++i) {
        double k1 = h * f(x[i], y[i]);
        double k2 = h * f(x[i] + h/2, y[i] + k1/2);
        double k3 = h * f(x[i] + h/2, y[i] + k2/2);
        double k4 = h * f(x[i] + h, y[i] + k3);
        y[i+1] = y[i] + (k1 + 2*k2 + 2*k3 + k4) / 6;
        x[i+1] = x[i] + h;
    }

    for (int i = 3; i < n; ++i) {
        double f_n = f(x[i], y[i]);
        double f_n1 = f(x[i-1], y[i-1]);
        double f_n2 = f(x[i-2], y[i-2]);
        double f_n3 = f(x[i-3], y[i-3]);
        y[i+1] = y[i] + h * (55*f_n - 59*f_n1 + 37*f_n2 - 9*f_n3) / 24;
        x[i+1] = x[i] + h;
    }
    return y[n];
}

int main() {
    vector<int> n_values = {5, 10, 20, 40, 80};
    double a = 1.0, b = 2.0;
    cout << fixed << setprecision(9);
    for (int n : n_values) {
        double y0 = 2.0;
        double y_rk = runge_kutta(y0, a, b, n);
        double y_ab = adams_bashforth(y0, a, b, n);
        double y_exact = exact_solution(b);
        cout << "n = " << n << endl;
        cout << "RK4 Error: " << abs(y_rk - y_exact) << endl;
        cout << "AB4 Error: " << abs(y_ab - y_exact) << endl << endl;
    }
}

// Найти численное решение дифференциального уравнения методом
// Эйлера и его модификациями на отрезке [0,1], удовлетворяющее заданному
// начальному условию. Количество шагов на отрезке: n=5, 10, 20, 40,… Найти
// абсолютную погрешность решения для каждого метода на последнем шаге
// интегрирования.
// Для каждого метода построить графики:
// а) интегральная кривая (точное решение) и ломаные Эйлера
// б) зависимость абсолютной погрешности (на последнем шаге) от шага.
// Сравнить и объяснить полученный результат для разных методов. Почему
// совпали приближения по первой и второй модификациям метода Эйлера?
// ---
// Реализовать двухэтапный метод Рунге-Кутты. Предусмотреть
// возможность для ввода коэффициента 𝛼. Выяснить, при каком значении
// коэффициента 𝛼 погрешность будет минимальной.
// Функции:
// 1. y' = y - x, y(0) = n + 4
// 2. y' = y - 2x/y, y(0) = n + 4

#include <iostream>
#include <fstream>
#include <cmath>
#include <vector>
#include <iomanip>
#include <string>
using namespace std;

// Функции правой части уравнения
double f1(double x, double y) {
    return y - x;
}

double f2(double x, double y) {
    if (y == 0) return 0; // во избежание деления на 0
    return y - (2 * x / y);
}

// Точное решение для первого уравнения: y' = y - x, y(0) = y0
double exact1(double x, double y0) {
    return (y0 + 1) * exp(x) - x - 1;
}

// Метод Эйлера
double euler(double (*f)(double, double), double x0, double y0, double h, int n) {
    double x = x0, y = y0;
    for (int i = 0; i < n; ++i) {
        y += h * f(x, y);
        x += h;
    }
    return y;
    // 
}

// Первая модификация метода Эйлера (предиктор-корректор)
double euler_mod1(double (*f)(double, double), double x0, double y0, double h, int n) {
    double x = x0, y = y0;
    for (int i = 0; i < n; ++i) {
        double y_pred = y + h * f(x, y);                     // Предиктор
        y += h * f(x + h, y_pred);                           // Корректор
        x += h;
    }
    return y;
}

// Вторая модификация метода Эйлера (среднее значение производной)
double euler_mod2(double (*f)(double, double), double x0, double y0, double h, int n) {
    double x = x0, y = y0;
    for (int i = 0; i < n; ++i) {
        double k1 = f(x, y);
        double k2 = f(x + h, y + h * k1);
        y += h * 0.5 * (k1 + k2);
        x += h;
    }
    return y;
}

// Метод Рунге-Кутты 2-го порядка с параметром alpha
double runge_kutta_2(double (*f)(double, double), double x0, double y0, double h, int n, double alpha) {
    double x = x0, y = y0;
    double beta = 1.0 / (2.0 * alpha);
    for (int i = 0; i < n; ++i) {
        double k1 = f(x, y);
        double k2 = f(x + alpha * h, y + alpha * h * k1);
        y += h * ((1 - beta) * k1 + beta * k2);
        x += h;
    }
    return y;
}

// Сохранение результатов в CSV
void save_csv(const string& filename, const vector<double>& h_values, const vector<double>& errors, const string& method) {
    ofstream fout(filename);
    fout << "h,error_" << method << "\n";
    for (size_t i = 0; i < h_values.size(); ++i) {
        fout << h_values[i] << "," << errors[i] << "\n";
    }
    fout.close();
}

int main() {
    int choice;
    double (*f)(double, double);
    double (*exact)(double, double) = nullptr;

    cout << "Выберите уравнение:\n";
    cout << "1. y' = y - x\n";
    cout << "2. y' = y - 2x/y\n";
    cin >> choice;

    int n_param;
    cout << "Введите n-параметр (для y(0) = n + 4): ";
    cin >> n_param;

    double y0 = n_param + 4;
    double x0 = 0.0, X = 1.0;

    if (choice == 1) {
        f = f1;
        exact = exact1;
    } else {
        f = f2;
    }

    vector<int> steps = {5, 10, 20, 40, 80, 160};
    vector<double> h_values, euler_errors, mod1_errors, mod2_errors, rk_errors;
    double alpha = 0.5; // Начальное значение alpha для Рунге-Кутты

    for (int n : steps) {
        double h = (X - x0) / n;
        double y_euler = euler(f, x0, y0, h, n);
        double y_mod1 = euler_mod1(f, x0, y0, h, n);
        double y_mod2 = euler_mod2(f, x0, y0, h, n);
        double y_rk    = runge_kutta_2(f, x0, y0, h, n, alpha);

        double y_exact = (exact != nullptr) ? exact(X, y0) : 0.0;

        h_values.push_back(h);

        if (exact != nullptr) {
            euler_errors.push_back(abs(y_exact - y_euler));
            mod1_errors.push_back(abs(y_exact - y_mod1));
            mod2_errors.push_back(abs(y_exact - y_mod2));
            rk_errors.push_back(abs(y_exact - y_rk));
        } else {
            euler_errors.push_back(0);
            mod1_errors.push_back(0);
            mod2_errors.push_back(0);
            rk_errors.push_back(0);
        }
    }

    // Сохраняем ошибки в CSV
    save_csv("euler.csv", h_values, euler_errors, "euler");
    save_csv("mod1.csv", h_values, mod1_errors, "mod1");
    save_csv("mod2.csv", h_values, mod2_errors, "mod2");
    save_csv("rk.csv", h_values, rk_errors, "rk");

    // Поиск минимальной ошибки для метода Рунге-Кутты при разных alpha
    if (exact != nullptr) {
        double min_error = 1e9;
        double best_alpha = 0.0;
        for (double a = 0.1; a <= 0.9; a += 0.01) {
            double err = abs(
                exact(X, y0) - runge_kutta_2(f, x0, y0, (X - x0) / 40, 40, a)
            );
            if (err < min_error) {
                min_error = err;
                best_alpha = a;
            }
        }
        cout << "Минимальная ошибка при alpha = " << best_alpha << ", ошибка = " << min_error << endl;
    }

    cout << "Результаты сохранены в CSV файлы для анализа в Excel.\n";
    return 0;
}
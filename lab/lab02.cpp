// Уравнение: 𝑓(𝑥) = 0
// Функции:
// 1. 𝑓(𝑥) = 𝑥^3 − 𝑥
// 2. f(x) = x^3 - 3x^2 + 6x - 5 TODO
// 3. * 𝑓(𝑥) = 𝑥 − 𝑠𝑖𝑛𝑥 − 0.25
// 4. * 𝑓(𝑥) = 𝑥 − 𝑠𝑖𝑛(𝜋/2 𝑥) − 0.25
// 5. * 𝑓(𝑥) = 𝑥 − 𝑐o𝑠 𝑥
// 6. * 𝑓(𝑥) = 𝑥 − 𝑐o𝑠(𝜋/2 𝑥)
// Методы:
// 1. Метод половинного деления
// 2. Метод хорд
// 3. Метод простой итерации
// 4. Метод Ньютона
// функция 1 - найти корень на отрезке [0.5;2]
// как найти другие корни этого уравнения? найти их.
// функции 2-6 – локализовать и найти корень
// при решении методами 3 и 4 проверять (необходимые и) достаточные условия
// сходимости.
// Для каждого задания построить графики функций на заданном отрезке, нанести на них
// точки, соответствующие итерациям.
// Для каждого корня на одном рисунке построить 4 графика (для каждого метода)
// абсолютной погрешности от номера итерации. Какой метод сходится быстрее?

#include <iostream>
#include <cmath>
#include <vector>
#include <fstream>
#include <algorithm>

using namespace std;

// Определение функций уравнений
double f1(double x) { return x*x*x - x; }
double f2(double x) { return x*x*x - 3*x*x + 6*x - 5; }
double f3(double x) { return x - sin(x) - 0.25; }
double f4(double x) { return x - sin(M_PI_2 * x) - 0.25; }
double f5(double x) { return x - cos(x); }
double f6(double x) { return x - cos(M_PI_2 * x); }

// Производные для метода Ньютона
double df1(double x) { return 3*x*x - 1; }
double df2(double x) { return 3*x*x - 6*x + 6; }
double df3(double x) { return 1 - cos(x); }
double df4(double x) { return 1 - M_PI_2 * cos(M_PI_2 * x); }
double df5(double x) { return 1 + sin(x); }
double df6(double x) { return 1 + M_PI_2 * sin(M_PI_2 * x); }

// Функции phi(x) для метода простой итерации
double phi_f1(double x) { return cbrt(x); }
double phi_f2(double x) { return (-x*x*x + 3*x*x + 5) / 6; }
double phi_f3(double x) { return sin(x) + 0.25; }
double phi_f4(double x) { return sin(M_PI_2 * x) + 0.25; }
double phi_f5(double x) { return cos(x); }
double phi_f6(double x) { return cos(M_PI_2 * x); }

// Производные phi(x)
double dphi_f1(double x) { return 1.0 / (3.0 * pow(x, 2.0/3.0)); }
double dphi_f2(double x) { return (-2*x*x + 6*x) / 6; }
double dphi_f3(double x) { return cos(x); }
double dphi_f4(double x) { return M_PI_2 * cos(M_PI_2 * x); }
double dphi_f5(double x) { return -sin(x); }
double dphi_f6(double x) { return -M_PI_2 * sin(M_PI_2 * x); }

struct FunctionData {
    string name;
    vector<pair<double, double>> intervals;
    double (*f)(double);
    double (*df)(double);
    double (*phi)(double);
    double (*dphi)(double);
};

vector<FunctionData> functions = {
    {"x^3 - x", {{0.5, 2.0}, {-0.5, 0.5}, {-2.0, -0.5}}, f1, df1, phi_f1, dphi_f1},
    {"x^3 - 3x^2 + 6x - 5", {{0.5, 2.0}, {-0.5, 0.5}, {-2.0, -0.5}}, f2, df2, phi_f2, dphi_f2},
    {"x - sin(x) - 0.25", {{1.0, 1.5}}, f3, df3, phi_f3, dphi_f3},
    {"x - sin(pi/2 x) - 0.25", {{1.0, 1.5}}, f4, df4, phi_f4, dphi_f4},
    {"x - cos(x)", {{0.5, 1.5}}, f5, df5, phi_f5, dphi_f5},
    {"x - cos(pi/2 x)", {{0.5, 1.0}}, f6, df6, phi_f6, dphi_f6}
};

// Метод Ньютона для эталонного решения
double newton_ref(double (*f)(double), double (*df)(double), double x0, double eps, int max_iter) {
    double x = x0;
    for (int i = 0; i < max_iter; ++i) {
        double fx = f(x);
        double dfx = df(x);
        if (abs(dfx) < 1e-12) break;
        double delta = fx / dfx;
        x -= delta;
        if (abs(delta) < eps) break;
    }
    return x;
}

// Метод половинного деления с историей
vector<double> bisection(double a, double b, double (*f)(double), double eps, int max_iter) {
    vector<double> hist;
    if (f(a) * f(b) >= 0) return hist;
    for (int i = 0; i < max_iter; ++i) {
        double c = (a + b) / 2;
        hist.push_back(c);
        if (f(c) == 0 || (b - a) / 2 < eps) break;
        f(c)*f(a) < 0 ? b = c : a = c;
    }
    return hist;
}

// Метод хорд с историей
vector<double> chord(double a, double b, double (*f)(double), double eps, int max_iter) {
    vector<double> hist;
    for (int i = 0; i < max_iter; ++i) {
        double c = a - f(a) * (b - a) / (f(b) - f(a));
        hist.push_back(c);
        if (abs(f(c)) < eps) break;
        f(c)*f(a) < 0 ? b = c : a = c;
    }
    return hist;
}

// Метод простой итерации с историей
vector<double> simple_iter(double x0, double (*phi)(double), double eps, int max_iter, bool &converged) {
    vector<double> hist;
    converged = false;
    double x = x0;
    hist.push_back(x);
    for (int i = 0; i < max_iter; ++i) {
        x = phi(x);
        hist.push_back(x);
        if (abs(hist.back() - hist[hist.size()-2]) < eps) {
            converged = true;
            break;
        }
    }
    return hist;
}

// Метод Ньютона с историей
vector<double> newton(double x0, double (*f)(double), double (*df)(double), double eps, int max_iter) {
    vector<double> hist;
    double x = x0;
    hist.push_back(x);
    for (int i = 0; i < max_iter; ++i) {
        double dfx = df(x);
        if (abs(dfx) < 1e-12) break;
        double delta = f(x) / dfx;
        x -= delta;
        hist.push_back(x);
        if (abs(delta) < eps) break;
    }
    return hist;
}

// Проверка сходимости метода простой итерации
bool check_convergence(double (*dphi)(double), double a, double b) {
    const int steps = 10;
    double step = (b - a) / steps;
    for (int i = 0; i <= steps; ++i) {
        double x = a + i * step;
        if (abs(dphi(x)) >= 1.0) return false;
    }
    return true;
}

int main() {
    const double eps = 1e-6;
    const int max_iter = 100;

    for (const auto &func : functions) {
        for (const auto &interval : func.intervals) {
            double a = interval.first;
            double b = interval.second;
            double x_ref = newton_ref(func.f, func.df, (a + b)/2, 1e-10, 1000);

            vector<double> bisect_hist = bisection(a, b, func.f, eps, max_iter);
            vector<double> chord_hist = chord(a, b, func.f, eps, max_iter);

            bool converged_si = false;
            vector<double> si_hist;
            if (check_convergence(func.dphi, a, b)) {
                si_hist = simple_iter((a + b)/2, func.phi, eps, max_iter, converged_si);
            }

            vector<double> newton_hist = newton((a + b)/2, func.f, func.df, eps, max_iter);

            // Сохранение данных
            string filename = func.name + "_" + to_string(a) + "_" + to_string(b) + ".csv";
            ofstream file(filename);
            file << "Iteration,Bisection,Chord,SimpleIteration,Newton\n";

            size_t max_len = max({bisect_hist.size(), chord_hist.size(), si_hist.size(), newton_hist.size()});
            for (size_t i = 0; i < max_len; ++i) {
                file << i << ",";
                if (i < bisect_hist.size()) file << abs(bisect_hist[i] - x_ref);
                file << ",";
                if (i < chord_hist.size()) file << abs(chord_hist[i] - x_ref);
                file << ",";
                if (i < si_hist.size()) file << abs(si_hist[i] - x_ref);
                file << ",";
                if (i < newton_hist.size()) file << abs(newton_hist[i] - x_ref);
                file << "\n";
            }
            file.close();
        }
    }

    return 0;
}
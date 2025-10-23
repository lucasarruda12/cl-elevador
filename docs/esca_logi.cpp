#include <iostream>
#include <vector>

using namespace std;

enum class Movimento {
    SUBIR,
    DESCER,
    PARADO
};

string to_string(Movimento mov) {
    switch (mov) {
        case Movimento::SUBIR: return "Subir";
        case Movimento::DESCER: return "Descer";
        case Movimento::PARADO: return "Parado";
        default: return "Desconhecido";
    }
}

struct Chamada {
    int andar;
    Movimento movimento;
};

struct Elevador {
    int andar;
    Movimento estado;
    Movimento intencao;
};

struct Teste {
    vector<Elevador> elevadores;
    vector<Chamada> chamadas;
}

testes[] = {
    {
        { {0, Movimento::PARADO, Movimento::PARADO}, {5, Movimento::PARADO, Movimento::PARADO}, 
           {10, Movimento::SUBIR, Movimento::SUBIR} },
        { {3, Movimento::SUBIR}, {7, Movimento::SUBIR}, {11, Movimento::SUBIR}, {11, Movimento::DESCER} },
        // 1, 1, 3, 1
    },
    {
        { {5, Movimento::SUBIR, Movimento::DESCER}, {5, Movimento::DESCER, Movimento::SUBIR}, 
          {32, Movimento::DESCER, Movimento::DESCER} },
        { {3, Movimento::SUBIR}, {7, Movimento::DESCER}, {11, Movimento::SUBIR}, {11, Movimento::DESCER} },
    }
};

int escolher_elevador(const vector<Elevador>& elevadores, const Chamada& chamada) {
    vector<size_t> primeira_prioridade;
    vector<size_t> segunda_prioridade;
    vector<size_t> rejeitados; // Pode ser retirado, apenas para clareza

    for (int i = 0; i < elevadores.size(); ++i) {
        const auto& elevador = elevadores[i];

        if (elevador.estado == Movimento::PARADO or
            (elevador.andar <= chamada.andar and elevador.estado == Movimento::SUBIR and
                 elevador.intencao == Movimento::SUBIR and chamada.movimento == Movimento::SUBIR) or
            (elevador.andar >= chamada.andar and elevador.estado == Movimento::DESCER and
                elevador.intencao == Movimento::DESCER and chamada.movimento == Movimento::DESCER))
            primeira_prioridade.push_back(i);

        else if ((elevador.andar >= chamada.andar and elevador.estado == Movimento::DESCER and
                    elevador.intencao == Movimento::SUBIR and chamada.movimento == Movimento::SUBIR) or
                 (elevador.andar <= chamada.andar and elevador.estado == Movimento::SUBIR and 
                    elevador.intencao == Movimento::DESCER and chamada.movimento == Movimento::DESCER))
            segunda_prioridade.push_back(i);

        else rejeitados.push_back(i);
    }

    cout << "Primeira prioridade: ";
    for (const auto& idx : primeira_prioridade) cout << idx + 1 << " ";

    cout << "\nSegunda prioridade: ";
    for (const auto& idx : segunda_prioridade) cout << idx + 1 << " ";

    cout << "\nRejeitados: ";
    for (const auto& idx : rejeitados) cout << idx + 1 << " ";

    int melhor_idx = -1;

    if (!primeira_prioridade.empty()) {
        for (const auto& idx : primeira_prioridade) {
            if (melhor_idx == -1 or
                abs(elevadores[idx].andar - chamada.andar) < abs(elevadores[melhor_idx].andar - chamada.andar))
                melhor_idx = idx + 1;
        }
    }

    else if (!segunda_prioridade.empty()) {
        for (const auto& idx : segunda_prioridade) {
            if (melhor_idx == -1 or
                abs(elevadores[idx].andar - chamada.andar) < abs(elevadores[melhor_idx].andar - chamada.andar))
                melhor_idx = idx + 1;
        }
    }

    return melhor_idx;
}

int main () {

    for (const auto& teste : testes) {
        cout << "\nElevadores:" << endl;

        for (int i = 0; i < teste.elevadores.size(); ++i) {
            const auto& elevador = teste.elevadores[i];
            cout << "\tElevador " << i+1 << ":" << endl;
            cout << "\t\tAndar atual: " << elevador.andar << "." << endl
                 << "\t\tEstado: " << to_string(elevador.estado) << "." << endl
                 << "\t\tIntenção: " << to_string(elevador.intencao) << "." << endl;
        }

        cout << "-----------------------------------\n" << endl;

        for (const auto& chamada : teste.chamadas) {
            cout << "Chamada no andar " << chamada.andar << " com intenção de "
                << to_string(chamada.movimento) << ".\n" << endl;

            int escolhido = escolher_elevador(teste.elevadores, chamada);
            if (escolhido != -1)
                cout << "\nElevador escolhido: " << escolhido << ".\n\n" << endl;
            else
                cout << "\nNenhum elevador disponível para atender a chamada.\n\n" << endl;
        }
        cout << "===================================\n" << endl;
    }
    return 0;
}
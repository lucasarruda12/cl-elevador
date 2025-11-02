# Sistema de Controle de Elevadores (3 Elevadores) em VHDL
Este projeto implementa um sistema de controle para três elevadores utilizando VHDL (Very High Speed Integrated Circuit Hardware Description Language) e um design baseado em Máquinas de Estado Finito (FSMs).

O principal foco arquitetural é a divisão hierárquica das responsabilidades em dois níveis, garantindo modularidade, escalabilidade e gerenciamento eficiente de chamadas concorrentes.



## Arquitetura do Sistema 
A arquitetura do sistema segue um modelo de dois níveis, conforme detalhado no diagrama de blocos principal:

### Nível 2: Escalonador / Supervisor (`external_controller`)

Este módulo atua como o cérebro do sistema. Sua principal função é gerenciar todas as chamadas externas, alocando-as para o elevador mais adequado de acordo com a estratégia de escalonamento (demonstrada na simulação em C++ `external_controller_sim`).

#### Módulos-chave neste nível:

- `scheduler.vhd` : A FSM principal de nível superior.

- `call_catcher.vhd` : Gerencia e armazena as requisições de chamada.

- `call_dispatcher.vhd` : Atribui as chamadas aos elevadores.

- `score_calc.vhd` : Usado para determinar a melhor alocação.

### Nível 1: Controladores Internos (`internal_controller`)

Existem três instâncias deste controlador, uma para cada elevador. Cada controlador local é uma FSM responsável pela sequência de operações de um único elevador. Suas responsabilidades incluem:

- Mover o elevador (controlar o motor, contar andares).

- Gerenciar a abertura e fechamento de portas.

- Manter o status do elevador (andar atual, direção, intenção).

#### Módulos-chave neste nível:

- `in_controller.vhd` : A FSM principal de nível inferior.

- `Módulos auxiliares` : Responsáveis por organizar as chamadas.


### Módulo Top-Level (`top.vhd`)

Responsável por instanciar e interconectar o Escalonador com os três Controladores Internos, além de gerenciar todas as interfaces de E/S.
## Instruções de Compilação e Teste

O projeto utiliza GHDL para simulação e um makefile para automatizar o processo de build e teste.

### Pré-requisitos

- **GHDL** : Necessário para compilar e simular os arquivos VHDL.

- **make** : Para executar os comandos definidos no makefile.

- **Visualizador VCD** : É recomendável ter uma ferramenta como GTKWave (utilizada durante os testes) instalada para visualizar os arquivos de waveform gerados.
## Compilação e Testes

Para compilar todos os arquivos VHDL e criar o diretório de trabalho (work):
```bash
# Executa o teste simples
make test_simple

# Executa o teste concorrente
make test_concurrent

# Executa o teste de unidade do controlador interno
make test_in_controller
```

### Limpeza

Para remover o diretório de trabalho (`work`) e todos os arquivos gerados de simulação:

```bash
make clean
```

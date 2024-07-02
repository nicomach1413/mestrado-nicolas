using LinearAlgebra

include("pre.jl")
include("portico_3d.jl")
include("apoios.jl")
include("global.jl")
include("pos.jl")

#
# Portico 3D
#


function main()

    # Entrada de dados na mão!
    nnos = 2
    ne = 1

    coord = [0.0 0.0 0.0;
             0.0 0.0 1.0]
           
    conectividades = [1 2]

    # Módulo de elasticidade longitudinal
    VE = 2E11*ones(ne)

    # Módulo de cisalhamento
    Gc = 7.6923E10*ones(ne)

    # Seção circular com raio 
    r = 0.0127
    VA = (pi*r^2)*ones(ne)
    VI = (pi*r^4/4)*ones(ne)
    Dia = r*2

    # Polar moment of inertia of the cross section J=(PI()*D^4)/32
    Jp = ((pi)*((Dia^4)))/32

    # Pré-processamento
    VL,Lox,Mox,Nox = Pre_processa(ne,coord,conectividades)

    println(VL)
    
    # Apoios (cond. de contorno essenciais)
    #        no gl valor
    apoios = [1 1 0.0;
              1 2 0.0;
              1 3 0.0;
              1 4 0.0;
              1 5 0.0;
              1 6 0.0]

    # Forças (cond. de contorno naturais)
    #         no gl valor
    forcas = [2  2  5000]

    # Forças distribuídas nos elementos 
    # SISTEMA LOCAL EM CADA ELEMENTO
    #                     ele q1  q2
    forcas_distribuidas = []

    # Monta a matriz global do problema
    K = Global_portico_3d(ne,nnos,conectividades, VE, VA, VL, VI, Lox, Mox, Nox, Gc, Jp)

    # Monta o vetor de forças globais concentradas
    Fc = Forca_global_concentrada(nnos,forcas)

    # Monta o vetor de forças globais distribuídas
    Fq = Forca_global_distribuida(nnos,forcas_distribuidas,VL,conectividades)

    # O lado direito do sistema KU = F é dado por
    F = Fc .+ Fq

    # Modifica o sistema pela aplicação das condições de contorno
    # homogêneas
    # Aplica_CC_homo!(apoios,K,F)

    KA, FA = Aplica_CC_lagrange(nnos,apoios,K,F)


    # Soluciona o sistema de equações, obtendo os deslocamentos
    # KU = F
    UA = KA\FA

    # Só os deslocamentos que nos interessam
    U = UA[1:6*nnos]

    # Pos-processa os esforços internos
    N,V,M,Tor = Calcula_Esforcos_portico_3D(ne,conectividades,VE,VA,VL,VI,Lox,Mox,Nox,Gc,Jp,U,forcas_distribuidas)

    println(U)
    println(N)
    println(V)
    println(M)
    println(Tor)

    # Retorna 
    return U

    
    
end

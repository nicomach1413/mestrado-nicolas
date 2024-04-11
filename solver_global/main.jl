using LinearAlgebra

include("pre.jl")
include("barra.jl")
include("global.jl")

function main()

    # Entrada de dados na mão!
    ne = 5
    nnos = 4
    conectividades = [2 1 ;
                      2 3 ;
                      4 3 ;
                      1 4 ;
                      1 3]

    coord = [0.0 0.0 ;
             1.0 0.0 ;
             1.0 1.0 ;
             0.0 1.0]                  

    VE = 210E9*ones(ne)
    VA = 1E-4*ones(ne)

    # Pré-processamento
    VL,Vtheta = Pre_processa(ne,coord,conectividades)

    # Apoios (cond. de contorno essenciais)
    apoios = [1;2;4]

    # Forças (cond. de contorno naturais)
    forcas = [3  300.0 ;
              5  600.0 ;
              6 -500.0]

    # Monta a matriz global do problema
    K = Global(ne,nnos,conectividades, VE, VA, VL, Vtheta)

    # Montar o vetor de forças global
    F = zeros(2*nnos)

    # Para cada informação em forças 
    # posiciona a força no vetor de forças
    # globais do problema
    for i=1:size(forcas,1)
        # Garante que gl é um inteiro
        gl = Int(forcas[i,1])
        valor = forcas[i,2]
        F[gl] = valor
    end #i

    # Aplica as condições de contorno essenciais homogêneas
    for gl in apoios

        # Zera linha e coluna da rigidez
        K[gl,:] .= 0.0
        K[:,gl] .= 0.0

        # Zera o vetor de forças nesse gl
        F[gl] = 0.0

        # Coloca 1.0 na diagonal
        K[gl,gl] = 1.0

    end #gls

    # Soluciona o sistema de equações, obtendo os deslocamentos
    # KU = F
    U = K\F

end
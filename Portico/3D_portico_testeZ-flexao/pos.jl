#
# Calcula os esforços normais de cada elemento
#
function Calcula_Esforcos_portico_3D(ne,conectividades,VE,VA,VL,VI,Lox,Mox,Nox,Gc,Jp,U,forcas_distribuidas)

    # Aloca o vetor de esforços normais
    N = zeros(ne)
    Tor = zeros(ne)

    # Aloca um vetor de vetores
    V = []
    M = []

    # Loop pelos elementos
    for ele=1:ne

        # Recupera os nós do elemento
        no1 = conectividades[ele,1]
        no2 = conectividades[ele,2]

        # Vetor com os gls GLOBAIS do elemento
        gls = [ 6*(no1-1)+1 ; 6*(no1-1)+2; 6*(no1-1)+3; 6*(no1-1)+4 ; 6*(no1-1)+5 ; 6*(no1-1)+6 ;
                6*(no2-1)+1 ; 6*(no2-1)+2; 6*(no2-1)+3; 6*(no2-1)+4 ; 6*(no2-1)+5 ; 6*(no2-1)+6 ]

        # Vetor de deslocamentos nos nós do elemento e 
        # ainda no sistema global de referência 
        Uge = U[gls]

        # ângulo do sistema local em relação ao global
        Lox3 = Lox[ele]
        Mox3 = Mox[ele]
        Nox3 = Nox[ele]

        # Monta a matriz de transformação T
        T = Matriz_rotacao_portico_3d(Lox3, Mox3, Nox3)

        # Passa Uge para o sistema local de referência
        Ule = T*Uge

        # Recupera as informações do elemento
        Ee = VE[ele]
        Ie = VI[ele]
        Ae = VA[ele]
        Le = VL[ele]
        Gc2 = Gc[ele]
        Jp2 = Jp

        # Monta a matriz de rigidez do elemento no sistema local
        Kle = Rigidez_portico_3d(Ee,Ae,Ie,Le,Gc2,Jp2)

        # Calcula o vetor de forças nodais do elemento 
        # no sistema local
        Fle = Kle*Ule

        # Esforço normal interno do elemento é
        N[ele] = -Fle[1]

        # Esforço de torção da barra
        Tor[ele] = Fle[4]

        # Dados para gerar os gráficos dos elementos
        xe = range(start=0.0,stop=Le,length=10)

        # Procura se existe alguma informação sobre o elemento
        # em forcas_distribuidas
        q1 = q2 = 0.0
        for i=1:size(forcas_distribuidas,1)
            if Int(forcas_distribuidas[i,1])==ele
                q1 = forcas_distribuidas[i,2]
                q2 = forcas_distribuidas[i,3]
                break
            end
        end

        # Esforço cortante do elemento
        fc(x) = -(((q2-q1)*x^2+2*Le*q1*x+2*Fle[2]*Le)/(2*Le))
        ve = fc.(xe)
        append!(V, [ve])

        # Momento do elemento
        fm(x) = ((q2-q1)*x^3+3*Le*q1*x^2+6*Fle[2]*Le*x-6*Fle[3]*Le)/(6*Le)
        me =  fm.(xe)
        append!(M,[me])

    end

    # Retorna os esforços em cada elemento
    return N, V, M, Tor
    
end

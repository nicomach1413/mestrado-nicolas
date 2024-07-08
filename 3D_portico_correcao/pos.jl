#
# Calcula os esforços normais de cada elemento
#
function Calcula_Esforcos_portico_3D(ne,conectividades,VE,VA,VL,VI,Lox,Mox,Nox,Gc,Jp,U)

    # Aloca o vetor de esforços normais
    N = zeros(ne)
    Tor = zeros(ne)

    # Aloca um vetor de vetores
    Vy = []
    My = []

    Vz = []
    Mz = []

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

        @show Lox3
        @show Mox3
        @show Nox3

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
        Jp2 = Jp[ele]

        # Monta a matriz de rigidez do elemento no sistema local
        Kle = Rigidez_portico_3d(Ee,Ae,Ie,Le,Gc2,Jp2)

        println("Kle")
        println(Kle)

        # Calcula o vetor de forças nodais do elemento 
        # no sistema local
        Fle = Kle*Ule

        println(Fle)

        # Esforço normal interno do elemento é
        N[ele] = -Fle[1]

        # Esforço de torção da barra
        Tor[ele] = Fle[4]

        # Dados para gerar os gráficos dos elementos
        xe = range(start=0.0,stop=Le,length=10)

        q1 = q2 = 0.0

        # Esforço cortante do elemento - Direção Y
        fcy(x) = -(((q2-q1)*x^2+2*Le*q1*x+2*Fle[2]*Le)/(2*Le))
        vey = fcy.(xe)
        append!(Vy, [vey])

        # Momento do elemento - Momento em Y
        fmy(x) = ((q2-q1)*x^3+3*Le*q1*x^2+6*Fle[2]*Le*x-6*Fle[5]*Le)/(6*Le)
        mey =  fmy.(xe)
        append!(My,[mey])

        # Esforço cortante do elemento - Direção Z
        fcz(x) = -(((q2-q1)*x^2+2*Le*q1*x+2*Fle[3]*Le)/(2*Le))
        vez = fcz.(xe)
        append!(Vz, [vez])

        # Momento do elemento - Momento em Z
        fmz(x) = ((q2-q1)*x^3+3*Le*q1*x^2+6*Fle[3]*Le*x-6*Fle[6]*Le)/(6*Le)
        mez =  fmz.(xe)
        append!(Mz,[mez])

    end

    # Retorna os esforços em cada elemento
    return N, Vy, My, Vz, Mz, Tor
    
end

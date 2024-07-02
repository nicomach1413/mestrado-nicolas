#
# conectividades é uma matriz com ne linhas (número de elementos)
# e 2 colunas (nó inicial e nó final)
# VE, VA, VL e Vtheta são vetores de dimensão ne com 
# os E, A, L e theta de cada elemento
#
function Global_portico_3d(ne,nnos,conectividades, VE, VA, VL, VI, Lox, Mox, Nox, Gc, Jp)

    # Precisamos definir a matriz global
    K = zeros(6*nnos,6*nnos)

    #@show K

    # Loop nos elementos da malha
    for ele=1:ne

        # Recupera as informações do elemento
        Ee = VE[ele]
        Ae = VA[ele]
        Ie = VI[ele]
        Le = VL[ele]
        Lox1 = Lox[ele]
        Mox1 = Mox[ele]
        Nox1 = Nox[ele]
        Ge = Gc[ele]
        Je = Jp

        #@show Je

        # Monta a matriz de rigidez do elemento no sistema local
        Kl = Rigidez_portico_3d(Ee,Ae,Ie,Le,Ge,Je)

        #@show Kl

        # Monta a matriz de transformação T
        T = Matriz_rotacao_portico_3d(Lox1, Mox1, Nox1)
        @show T
        # Passa Kl para o sistema global
        Kg = transpose(T)*Kl*T
        @show size(Kg)
        # Agora precisamos posicionar Kg na matriz
        # global do problema

        # Recupera os nós do elemento
        no1 = conectividades[ele,1]
        no2 = conectividades[ele,2]

        # Vetor com os gls GLOBAIS do elemento
        gls = [ 6*(no1-1)+1 ; 6*(no1-1)+2; 6*(no1-1)+3; 6*(no1-1)+4 ; 6*(no1-1)+5 ; 6*(no1-1)+6 ;
                6*(no2-1)+1 ; 6*(no2-1)+2; 6*(no2-1)+3; 6*(no2-1)+4 ; 6*(no2-1)+5 ; 6*(no2-1)+6 ]

        #@show gls

        # Soma Kg nas posições gls em K
        K[gls,gls] .= K[gls,gls] .+ Kg

        #@show K

    end #ele
    @show size(K)
    # Retorna a matriz de rigidez do problema
    return K

end


#
# Monta o vetor de força global
#
function Forca_global_concentrada(nnos,forcas)

    # Montar o vetor de forças global
    F = zeros(6*nnos)

    # Para cada informação em forças 
    # posiciona a força no vetor de forças
    # globais do problema
    for i=1:size(forcas,1)
       
        # Recupera nó e gl local 
        no  = Int(forcas[i,1])
        gll = Int(forcas[i,2])

        # Recupera valor
        valor = forcas[i,3]

        # Adiciona ao valor da força
        F[6*(no-1)+gll] += valor

        @show F

    end #i

    return F

end


#
# Avalia, para os elementos com carregamento distribuído,
# o vetor de forças consistentes e sobrepoe no vetor 
# global Fq
#
function Forca_global_distribuida(nnos,forcas_distribuidas,VL,conectividades)

   # Aloca o vetor de forças globais distribuídas
   Fq = zeros(6*nnos)

   # Loop pelas informações em forcas_distribuidas
   for i=1:size(forcas_distribuidas,1)

       # Descobre o elemento
       ele = Int(forcas_distribuidas[i,1])

       # Recupera as informações q1, q2 e Le
       q1 = forcas_distribuidas[i,2]
       q2 = forcas_distribuidas[i,3]
       Le = VL[ele]
       
       # Monta o vetor local Fqe
       Fqle = Forca_distribuida_portico_plano(q1,q2,Le)

       # Monta a matriz de transformação T
       T = Matriz_rotacao_portico_plano(te)

       # Rotaciona do sistema local para o global
       # usa T transposto pois estamos passando 
       # do local para o global
       Fqge = T'*Fqle


       # Recupera os nós do elemento
       no1 = conectividades[ele,1]
       no2 = conectividades[ele,2]
 
       # Vetor com os gls GLOBAIS do elemento
       gls = [ 6*(no1-1)+1 ; 6*(no1-1)+2; 6*(no1-1)+3; 6*(no1-1)+4 ; 6*(no1-1)+5 ; 6*(no1-1)+6 ;
                6*(no2-1)+1 ; 6*(no2-1)+2; 6*(no2-1)+3; 6*(no2-1)+4 ; 6*(no2-1)+5 ; 6*(no2-1)+6 ]

       # Sobrepoe Fqge nas posições globais de Fq
       Fq[gls] .= Fq[gls] .+ Fqge

   end #i

   # Retorna o vetor Fq
   return Fq

end

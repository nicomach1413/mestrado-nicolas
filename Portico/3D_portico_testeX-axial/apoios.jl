#
# Aplica condições de contorno essenciais 
# homogêneas
#
function Aplica_CC_homo!(apoios,K,F)

    # Aplica as condições de contorno essenciais homogêneas
    for i=1:size(apoios,1) 

        # No e gl local do apoio
        no  = Int(apoios[i,1])
        gll = Int(apoios[i,2])

        # Testa se o usuário tem ideia do que
        # ele está fazendo
        if apoios[i,3]!=0 
            error("Sua anta")
        end

        # Gl global
        gl = 3*(no-1) + gll

        # Zera linha e coluna da rigidez
        K[gl,:] .= 0.0
        K[:,gl] .= 0.0

        # Zera o vetor de forças nesse gl
        F[gl] = 0.0

        # Coloca 1.0 na diagonal
        K[gl,gl] = 1.0

    end #gls

end


#
# Aplica cc essenciais por Multiplicadores de Lagrange
#
# Monta o sistema aumentado
# [K S' {U}= {F}
#  S 0] {L}  {Ub}
#
#
function Aplica_CC_lagrange(nnos,apoios,K,F)

    # Número de gls do problema original
    n = 6*nnos

    # Número de cc essenciais
    m = size(apoios,1)
    @show n
    @show m

    # Define o sistema aumentado de equações
    KA = zeros(n+m,n+m)
    FA = zeros(n+m)

    @show size(KA)
    @show size(FA)

    # Define a matriz S e o vetor Ub
    S  = zeros(m,n)
    Ub = zeros(m)

    # Aplica as condições de contorno essenciais
    for i=1:m 

        # No e gl local do apoio
        no  = Int(apoios[i,1])
        gll = Int(apoios[i,2])
        valor = apoios[i,3]

        # Gl global
        gl = 6*(no-1) + gll
        @show gl

        # Posiciona na linha da matriz S
        S[i,gl] = 1.0

        # Posiciona o valor em Ub
        Ub[i] = valor

    end

    @show Ub, KA

    @show size(KA)
    @show size(K)

    # Posiciona os blocos na matriz e no vetor aumentados
    KA[1:n,1:n]     .= K
    KA[1:n,n+1:end] .= S'
    KA[n+1:end,1:n] .= S

    FA[1:n]     .= F
    FA[n+1:end] .= Ub

    @show size(KA)

    return KA, FA
end
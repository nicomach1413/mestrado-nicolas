#
# Calcula os comprimentos e os ângulos de cada barra
#
function Pre_processa(ne,coord,conectividades)

    # Aloca os vetores VL e Vtheta
    VL     = zeros(ne)
    Vtheta = zeros(ne)

    # Loop pelos elementos
    for ele=1:ne

        # Nós do elemento
        no1 = conectividades[ele,1]
        no2 = conectividades[ele,2]

        # Coordenadas dos nós
        x1 = coord[no1,1]
        y1 = coord[no1,2]

        x2 = coord[no2,1]
        y2 = coord[no2,2]
        
        # Calcula dx e dy
        dx = x2-x1
        dy = y2-y1

        # Comprimento
        VL[ele] = sqrt( dx^2 + dy^2 )

        # ângulo
        Vtheta[ele] = atan(dy,dx)

    end #j

    # Retorna os vetores
    return VL,Vtheta
end
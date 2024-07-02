#
# Calcula os comprimentos e os ângulos de cada barra
#
function Pre_processa(ne,coord,conectividades)

    # Aloca os vetores VL, Lox, Mox e Nox
    VL     = zeros(ne)
    Lox = zeros(ne)
    Mox = zeros(ne)
    Nox = zeros(ne)

    # Loop pelos elementos
    for ele=1:ne

        # Nós do elemento
        no1 = conectividades[ele,1]
        no2 = conectividades[ele,2]

        # Coordenadas dos nós
        x1 = coord[no1,1]
        y1 = coord[no1,2]
        z1 = coord[no1,3]

        x2 = coord[no2,1]
        y2 = coord[no2,2]
        z2 = coord[no2,3]
        
        @show x1, x2
        @show y1, y2
        @show z1, z2

        # Calcula dx, dy e dz
        dx = x2-x1
        dy = y2-y1
        dz = z2-z1

        @show dx, dy, dz

        # Comprimento do elemento
        VL[ele] = sqrt( dx^2 + dy^2 + dz^2 )

        # Calcula Lox
        
        Lox[ele] = dx / VL[ele]
        @show Lox

        # Calcula Mox
        
        Mox[ele] = dy / VL[ele]
        @show Mox
 
        # Calcula Nox
    
        Nox[ele] = dz / VL[ele]
        @show Nox
        
    end #j

    # Retorna os vetores
    return VL,Lox,Mox,Nox
end
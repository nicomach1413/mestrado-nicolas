#
# Devolve a matriz de rigidez local
# de um elemento de barra
#
"""
  Função que calcula a matriz de rigidez local
   
  Entradas: E (módulo de elasticidade longitudinal)

            A (área da seção transversal)

            L (comprimento da barra)

   Saídas: Matriz de rigidez local (4x4)

"""
function Rigidez_barra(Ex,A,L)

    # Rigidez axial da barra
    cte = Ex*A/L

    # Matriz local
    Ke = cte* [ 1.0 0.0 -1.0 0.0 ;
                0.0 0.0  0.0 0.0 ;
               -1.0 0.0  1.0 0.0 ;
                0.0 0.0  0.0 0.0 ]

    return Ke

end

#
# Matriz de rotação da barra
#
function Matriz_rotacao(theta)

   # Calcula o seno e o cosseno 
   c = cos(theta)
   s = sin(theta) 

   # Monta os dois blocos da matriz T
   Z = zeros(2,2)
   R = [c s ;
       -s c]

   # Monta a matriz T    
   T = [R Z ; 
        Z R]    

   return T

end
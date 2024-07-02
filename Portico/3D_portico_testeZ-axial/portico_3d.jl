#
# Devolve a matriz de rigidez local
# de um elemento de barra
#
"""
  Função que calcula a matriz de rigidez local do 
  elemento de pórtico 3D
   
  Entradas: E (módulo de elasticidade longitudinal)

            A (área da seção transversal)

            I (momento de inércia da seção transversal)

            L (comprimento do elemento)

   Saídas: Matriz de rigidez local (12x12)

"""
function Rigidez_portico_3d(Ex,A,Iz,L,G,J)

    # Aloca a matriz local do elemento
    Ke = zeros(12,12)

    # Rigidez axial do elemento
    cte = Ex*A/L
    
    Ke[1,1] =  cte
    Ke[1,7] = -cte
    Ke[7,1] = -cte
    Ke[7,7] =  cte

    # Rigidez torcional do elemento 

   """

   Página 324 do Rao
   G is the shear modulus of the material.
   J - polar moment of inertia of the cross section.
   G*J/L is called the torsional stiffness of the frame element

   """

    cte = G*J/L
    
    Ke[4,4] =  cte
    Ke[4,10] = -cte
    Ke[10,4] = -cte
    Ke[10,10] = cte
 
    # Rigidez XY do elemento - Página 325 do Rao
    cte = Ex*Iz

    Ke[2,2] =  12*cte/L^3
    Ke[2,6] =  6*cte/L^2
    Ke[2,8] = -Ke[2,2]
    Ke[2,12] = Ke[2,6]

    Ke[6,2] =  Ke[2,6]
    Ke[6,6] =  4*cte/L
    Ke[6,8] = -Ke[2,6]
    Ke[6,12] =  2*cte/L

    Ke[8,2] =  Ke[2,8]
    Ke[8,6] =  Ke[6,8]
    Ke[8,8] =  Ke[2,2]
    Ke[8,12] = -Ke[2,6]

    Ke[12,2] = Ke[2,6]
    Ke[12,6] = Ke[6,12]
    Ke[12,8] = Ke[8,12]
    Ke[12,12] = Ke[6,6]

    # Rigidez XZ do elemento
    cte = Ex*Iz

    Ke[3,3] =  12*cte/L^3
    Ke[3,5] =  6*cte/L^2
    Ke[3,9] = -Ke[3,3]
    Ke[3,11] =  Ke[3,5]

    Ke[5,3] =  Ke[3,5]
    Ke[5,5] =  4*cte/L
    Ke[5,9] = -Ke[3,5]
    Ke[5,11] =  2*cte/L

    Ke[9,3] = -Ke[3,3]
    Ke[9,5] =  Ke[5,9]
    Ke[9,9] =  Ke[3,3]
    Ke[9,11] = -Ke[3,5]

    Ke[11,3] = Ke[3,5]
    Ke[11,5] = Ke[5,11]
    Ke[11,9] = Ke[9,11]
    Ke[11,11] = Ke[5,5]

    return Ke

end

#
# Retorna o vetor LOCAL Fq
#
function Forca_distribuida_portico_3d(q1,q2,L)

   # As posições 1 e 4 tem que ser zero (barra)

   return [ 0.0 ; (3*L*q2+7*L*q1)/20; (2*L^2*q2+3*L^2*q1)/60; 
            0.0 ; (7*L*q2+3*L*q1)/20; -((3*L^2*q2+2*L^2*q1)/60)];

end
#
# Matriz de rotação para o pórtico 3D
#
function Matriz_rotacao_portico_3d(Lox2, Mox2, Nox2)

   Lambda1 = zeros(3,3)
   Lambda2 = zeros(3,3)

   # Calcula De

   De = sqrt(Lox2^2 + Nox2^2)

   @show De

   # Calcula Lambda1 - Página 329 do Rao
   Lambda1[1,1] = Lox2
   Lambda1[1,2] = Mox2
   Lambda1[1,3] = Nox2

   Lambda1[2,1] = (-(Lox2*Mox2)/De)
   Lambda1[2,2] = ((Lox2^2 + Nox2^2)/De)
   Lambda1[2,3] = (-(Mox2*Nox2)/De)

   Lambda1[3,1] = (-Nox2/De)
   Lambda1[3,2] = 0.0
   Lambda1[3,3] = (Lox2/De)
   @show Lambda1
   # Calcula Lambda2 - Página 331 do Rao -Ângulo 0 devido a não haver rotação do elemento
   Lambda2[1,1] = 1.0
   Lambda2[1,2] = 0.0
   Lambda2[1,3] = 0.0

   Lambda2[2,1] = 0.0
   Lambda2[2,2] = cos(0.0)
   Lambda2[2,3] = sin(0.0)

   Lambda2[3,1] = 0.0
   Lambda2[3,2] = -sin(0.0)
   Lambda2[3,3] = cos(0.0)
   @show Lambda2
   """
   Lambda1 = [Lox2 Mox2 Nox2;
              (-(Lox2*Mox2)/De) ((Lox2^2 + Nox2^2)/De) (-(Mox2*Nox2)/De);
              (-Nox2/De) 0.0 (Lox2/De)]
   @show Lambda1
   # Calcula Lambda2 - Página 331 do Rao

   Lambda2 = [0.0 Mox2 0.0]
             (-Mox2*cos(TeXY2)) 0.0 (Mox2*sin(TeXY2));
             sin(TeXY2) 0.0 cos(TeXY2)]
   @show Lambda2
   """

   Lambda = Lambda2*Lambda1
   @show Lambda

   if De==0.0
       Lambda[1,1] = 0.0
       Lambda[1,2] = Mox2
       Lambda[1,3] = 0.0
       Lambda[2,1] = -Mox2*cos(0.0)
       Lambda[2,2] = 0.0
       Lambda[2,3] = Mox2*sin(0.0)
       Lambda[3,1] = sin(0.0)
       Lambda[3,2] = 0.0
       Lambda[3,3] = cos(0.0)
   end  

   @show Lambda

   T = zeros(12,12)
   T[1,1] = Lambda[1,1]
   T[1,2] = Lambda[1,2]
   T[1,3] = Lambda[1,3]
   T[2,1] = Lambda[2,1]
   T[2,2] = Lambda[2,2]
   T[2,3] = Lambda[2,3]
   T[3,1] = Lambda[3,1]
   T[3,2] = Lambda[3,2]
   T[3,3] = Lambda[3,3]

   T[4,4] = Lambda[1,1]
   T[4,5] = Lambda[1,2]
   T[4,6] = Lambda[1,3]
   T[5,4] = Lambda[2,1]
   T[5,5] = Lambda[2,2]
   T[5,6] = Lambda[2,3]
   T[6,4] = Lambda[3,1]
   T[6,5] = Lambda[3,2]
   T[6,6] = Lambda[3,3]

   T[7,7] = Lambda[1,1]
   T[7,8] = Lambda[1,2]
   T[7,9] = Lambda[1,3]
   T[8,7] = Lambda[2,1]
   T[8,8] = Lambda[2,2]
   T[8,9] = Lambda[2,3]
   T[9,7] = Lambda[3,1]
   T[9,8] = Lambda[3,2]
   T[9,9] = Lambda[3,3]

   T[10,10] = Lambda[1,1]
   T[10,11] = Lambda[1,2]
   T[10,12] = Lambda[1,3]
   T[11,10] = Lambda[2,1]
   T[11,11] = Lambda[2,2]
   T[11,12] = Lambda[2,3]
   T[12,10] = Lambda[3,1]
   T[12,11] = Lambda[3,2]
   T[12,12] = Lambda[3,3]

   #@show T
   return T

end
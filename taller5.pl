% Hechos (Base de conocimiento)
% Personajes (Nombre, Nivel, Vida)
personaje('Elara', 5, 100).
personaje('Kael', 3, 80).
personaje('Rin', 7, 120).

personaje('Ann', 4, 100).
personaje('Makoto', 10, 250).
personaje('Okabe', 8, 180).

mision(m1, 'Bosque de Sombras', 2, 50).
mision(m2, 'Cueva del Dragón', 5, 120).
mision(m3, 'Torre Arcana', 7, 200).

inventario('Elara', [espada, escudo, pocion]).
inventario('Kael', [arco, flechas]).
inventario('Rin', [varita, grimorio, pocion, amuleto]).

requiere(m2, escudo).
requiere(m2, pocion).
requiere(m3, grimorio).
requiere(m3, pocion).

% Enemigos (Nombre, nivel, vida)
enemigo('Esqueleto', 2, 50).    % Facil
enemigo('Duende', 3, 75).       % Facil
enemigo('Soldado', 5, 200).     % Medio
enemigo('Dragon', 8, 450).      % Dificil (Jefe)

% Reglas aritmeticas y recursivas
% 1. Verificacion de nivel (Operador relacional >=)
puede_aceptar(Personaje, ID_Mision):-
    personaje(Personaje, Nivel, _),
    mision(ID_Mision, _, Dificultad, _),
    Nivel >= Dificultad.

% 2. Calculo recursivo de XP acumulada (Patron factorial de 2.1)
% Caso base: 0 misiones = 0 XP
xp_acumulada(0, 0).
% Paso recursivo: XP(N) = XP(N-1) + (30 * N)
xp_acumulada(N, Total):-
    N > 0,
    N1 is N - 1,                    % Instanciacion obligatoria antes de recursion
    xp_acumulada(N1, Prev),
    Total is Prev + (30 * N).       % Precedencia: * antes de +

% Verificacion de inventario con member/2
tiene_requerido(Personaje, Objeto):-
    inventario(Personaje, Lista),
    member(Objeto, Lista).          % Funcion built-in (2.3)

% REGLAS DE UNIFICACION Y COMPARACION
% 1. Detectar personajes del mismo nivel exacto (vs unificacion)
mismo_nivel(P1, P2):-
    personaje(P1, N, _),
    personaje(P2, N, _),
    P1 \== P2.

% 2. Validar balance aritmetio estricto
es_balanceado(Personaje):-
    personaje(Personaje, _, Vida),
    Vida =:= 100.


% PROCESAMIENTO DE LISTAS Y NLP
% 1. Fusionar inventarios de dos personajes usando append/3 (2.3)
fusionar_equipo(P1, P2, EquipoFusionado):-
    inventario(P1, L1),
    inventario(P2, L2),
    append(L1, L2, EquipoFusionado).

% 2. Base de conjugacion (Adaptacion directa de conjugar_verbo/5 en 2.3)
tiempo(presente).
tiempo(pasado).
tiempo(futuro).

persona(primera).
persona(segunda).
persona(tercera).

numero(singular).
numero(plural).

% Verbo ser
ser(presente, tercera, singular, "es").
ser(pasado, tercera, singular, "fué").
ser(futuro, tercera, singular, "será").
ser(presente, primera, singular, "soy").
ser(presente, primera, plural, "somos").

ser(presente, tercera, plural, "son").
ser(pasado,   tercera, plural, "fueron").
ser(futuro,   tercera, plural, "serán").

% Verbo atacar
atacar(pasado, tercera, singular, "atacó").
atacar(pasado, tercera, plural, "atacaron").

% Verbo derrotar
derrotar(pasado, tercera, singular, "derrotó").
derrotar(pasado, tercera, plural, "derrotaron").

% Verbo usar
usar(pasado, tercera, singular, "usó").
usar(pasado, tercera, plural, "usaron").

% Verbo sobrevivir
sobrevivir(pasado, tercera, singular, "sobrevivió").

% Verbo quedar
quedar(pasado, tercera, singular, "quedó").

% Verbo morir
morir(pasado, tercera, singular, "murió").

% 3. Regla de inferencia con estructura condicional (2.3)
conjugar_accion(Verbo, Tiempo, Persona, Numero, Conjugacion):-
    tiempo(Tiempo),
    persona(Persona),
    numero(Numero),
    ( Verbo = "ser" ->
        ser(Tiempo, Persona, Numero, Conjugacion)
    ; Verbo = "atacar" ->
        atacar(Tiempo, Persona, Numero, Conjugacion)
    ; Verbo = "derrotar" ->
        derrotar(Tiempo, Persona, Numero, Conjugacion)
    ; Verbo = "usar" ->
        usar(Tiempo, Persona, Numero, Conjugacion)
    ; Verbo = "sobrevivir" ->
        sobrevivir(Tiempo, Persona, Numero, Conjugacion)
    ; Verbo = "quedar" ->
        quedar(Tiempo, Persona, Numero, Conjugacion)
    ; Verbo = "morir" ->
        morir(Tiempo, Persona, Numero, Conjugacion)
    ;
        Conjugacion = Verbo
    ).

% 4. Generacion de reporte narrativo
generar_reporte(Personaje, MisionID, Mensaje):-
    puede_aceptar(Personaje, MisionID),
    mision(MisionID, Nombre, _, XP),
    conjugar_accion("ser", presente, tercera, singular, FormaVerbal),
    atomic_list_concat([Personaje, FormaVerbal, "capaz de completar", Nombre, "por", XP, "XP"], ' ', Mensaje).

% 4.1 Generacion de reporte narrativo grupales
% ENFOQUE 1 (PRINCIPAL)
xp_personaje(Personaje, XP) :-
    personaje(Personaje, Nivel, _),
    xp_acumulada(Nivel, XP).

xp_total_grupo(Grupo, Total) :-
    xp_total_grupo(Grupo, 0, Total).
xp_total_grupo([], Acc, Acc).
xp_total_grupo([Cabeza|Cola], Acc, Total) :-
    xp_personaje(Cabeza, XP_Cabeza),
    NuevoAcc is Acc + XP_Cabeza,
    xp_total_grupo(Cola, NuevoAcc, Total).

xp_requerida_mision(MisionID, XP_Requerida) :-
    mision(MisionID, _, Dificultad, _),
    xp_acumulada(Dificultad, XP_Requerida).

grupo_puede_por_xp(Grupo, MisionID) :-
    xp_total_grupo(Grupo, XP_Total),
    xp_requerida_mision(MisionID, XP_Requerida),
    XP_Total >= XP_Requerida.

generar_reporte_grupo(Grupo, MisionID, Mensaje) :-
    grupo_puede_por_xp(Grupo, MisionID),
    mision(MisionID, NombreMision, _, XP_Premio),
    xp_total_grupo(Grupo, XP_Total),
    xp_requerida_mision(MisionID, XP_Requerida),
    conjugar_accion("ser", presente, tercera, plural, FormaVerbal),
    atomic_list_concat(Grupo, ', ', NombresGrupo),
    atomic_list_concat(
        [NombresGrupo, FormaVerbal, "capaces de completar", NombreMision,
         "| XP del grupo:", XP_Total, "/ XP requerida:", XP_Requerida,
         "| Premio:", XP_Premio, "XP"],
        ' ', Mensaje).

% ENFOQUE 2 (SECUNDARIA)
alguno_puede([], _) :- fail.

alguno_puede([Cabeza|_], MisionID) :-
    puede_aceptar(Cabeza, MisionID), !.

alguno_puede([_|Cola], MisionID) :-
    alguno_puede(Cola, MisionID).

todos_pueden([], _).
todos_pueden([Cabeza|Cola], MisionID) :-
    puede_aceptar(Cabeza, MisionID),
    todos_pueden(Cola, MisionID).

generar_reporte_grupo_v1(Grupo, MisionID, Modo, Mensaje) :-
    ( Modo = alguno -> alguno_puede(Grupo, MisionID)
    ; Modo = todos  -> todos_pueden(Grupo, MisionID)
    ),
    mision(MisionID, NombreMision, _, XP),
    conjugar_accion("ser", presente, tercera, plural, FormaVerbal),
    atomic_list_concat(Grupo, ', ', NombresGrupo),
    atomic_list_concat(
        [NombresGrupo, FormaVerbal, "capaces de completar",
         NombreMision, "por", XP, "XP"],
        ' ', Mensaje).


% Armas (Nombre, Poder, Cantidad de golpes)
% El daño total del arma es: Poder * Cantidad de golpes
arma(espada, 80, 1).
arma(lanza, 90, 1).
arma(mazo, 150, 1).
arma(varita, 110, 1).
arma(mandoble, 220, 1).
arma(arco, 25, 3).

% Arma equipada por cada jugador
arma_equipada('Elara', espada).
arma_equipada('Kael', arco).
arma_equipada('Rin', varita).
arma_equipada('Ann', lanza).
arma_equipada('Makoto', mandoble).
arma_equipada('Okabe', mazo).

% Calcula el daño que hace un jugador con su arma equipada.
danio_jugador(Personaje, Danio, Detalle):-
    arma_equipada(Personaje, Arma),
    arma(Arma, Poder, Golpes),
    Danio is Poder * Golpes,
    conjugar_accion("usar", pasado, tercera, singular, VerboUsar),
    atomic_list_concat(
        [Personaje, VerboUsar, Arma, "con", Golpes, "golpe(s), causando", Danio, "de daño"],
        ' ',
        Detalle
    ).

% Calcula el daño total de una party.
% Recorre la lista de jugadores y suma el daño de cada uno.
danio_total_party([], 0, []).

danio_total_party([Personaje|RestoParty], DanioTotal, [DetalleAtaque|DetallesAtaques]):-
    danio_jugador(Personaje, DanioPersonaje, DetalleAtaque),
    danio_total_party(RestoParty, DanioRestoParty, DetallesAtaques),
    DanioTotal is DanioPersonaje + DanioRestoParty.

% Ejecucion de ataque individual.
% Recibe un solo jugador y un solo enemigo.
ejecutar_ataque(Personaje, Enemigo, Mensaje):-
    ejecutar_ataque_grupal([Personaje], Enemigo, Mensaje).

% Ejecucion de ataque grupal.
% Recibe una lista de jugadores y un solo enemigo.
% Solo se calcula el daño que la party le hace al enemigo.
ejecutar_ataque_grupal(Party, Enemigo, Mensaje):-
    enemigo(Enemigo, _, VidaEnemigo),

    danio_total_party(Party, DanioTotal, DetallesAtaques),
    VidaRestante is VidaEnemigo - DanioTotal,

    atomic_list_concat(Party, ' y ', NombresParty),
    atomic_list_concat(DetallesAtaques, ' | ', TextoAtaques),

    length(Party, CantidadIntegrantes),

    ( CantidadIntegrantes =:= 1 ->
        Numero = singular
    ;
        Numero = plural
    ),

    conjugar_accion("atacar", pasado, tercera, Numero, VerboAtacar),
    conjugar_accion("derrotar", pasado, tercera, Numero, VerboDerrotar),
    conjugar_accion("morir", pasado, tercera, singular, VerboMorir),
    conjugar_accion("sobrevivir", pasado, tercera, singular, VerboSobrevivir),
    conjugar_accion("quedar", pasado, tercera, singular, VerboQuedar),

    ( DanioTotal >= VidaEnemigo ->
        atomic_list_concat(
            [NombresParty, VerboAtacar, "al enemigo de tipo", Enemigo,
             "|", TextoAtaques,
             "| Daño total:", DanioTotal,
             "| Resultado: el enemigo", VerboMorir,
             "y", NombresParty, VerboDerrotar, "al enemigo."],
            ' ',
            Mensaje
        )
    ;
        atomic_list_concat(
            [NombresParty, VerboAtacar, "al enemigo de tipo", Enemigo,
             "|", TextoAtaques,
             "| Daño total:", DanioTotal,
             "| Resultado: el enemigo", VerboSobrevivir,
             "y", VerboQuedar, "con", VidaRestante, "de vida."],
            ' ',
            Mensaje
        )
    ).
CREATE OR ALTER PROC CADASTRA_TIME
AS
BEGIN
    INSERT [TIME]
        (
        ID
        ,NOME
        ,APELIDO
        ,DATA_CRIACAO
        )
    VALUES
        (1, 'PESTANA-FC', 'PESTE', '1986/10/04')
    ,
        (2, 'PAPINI-FC', 'PAPS', '1979/10/06')
    ,
        (3, 'VISICATTO-FC', 'VTTO', '1989/04/05')
    ,
        (4, 'GALHO-FC', 'GLH', '1979/10/06')
    ,
        (5, 'MACHADO-FC', 'MCD', '1979/10/06')
END;
GO

CREATE OR ALTER PROC CRIA_CAMPEONATO
AS
BEGIN
    INSERT [CAMPEONATO]
        (
        ID_CAMPEONATO
        ,ANO
        ,NOME
        )
    VALUES
        (
            001, 2023, 'INTER-5BY5'
)
END;
GO

CREATE OR ALTER PROC JOGAR_JOGOS
AS
BEGIN
    INSERT [JOGO]
        (
        ID_JOGO
        ,TIME_CASA_ID
        ,TIME_VISITANTE_ID
        ,GOL_CASA
        ,GOL_VISITANTE
        )
    VALUES
        ( 1, 1, 2, 1, 2)
        ,
        ( 2, 1, 3, 0, 1)
        ,
        ( 3, 1, 4, 3, 1)
        ,
        ( 4, 1, 5, 1, 1)

        ,
        ( 5, 2, 1, 0, 0)
        ,
        ( 6, 2, 3, 0, 1)
        ,
        ( 7, 2, 4, 1, 1)
        ,
        ( 8, 2, 5, 3, 5)

        ,
        ( 9, 3, 1, 2, 0)
        ,
        (10, 3, 2, 0, 0)
        ,
        (11, 3, 4, 0, 0)
        ,
        (12, 3, 5, 3, 4)

        ,
        (13, 4, 1, 2, 2)
        ,
        (14, 4, 2, 2, 1)
        ,
        (15, 4, 3, 0, 0)
        ,
        (16, 4, 5, 1, 2)

        ,
        (17, 5, 1, 0, 1)
        ,
        (18, 5, 2, 1, 1)
        ,
        (19, 5, 3, 3, 2)
        ,
        (20, 5, 4, 2, 1)

END;
GO

CREATE OR ALTER PROCEDURE PREENCHE_GOLS_TIME
AS
BEGIN
    -- Insere todos os times registrados na tabela TIME com gols marcados e sofridos zerados
    INSERT INTO [GOLS_TIME]
        (TIME_ID)
    SELECT ID
    FROM [TIME];

    -- Atualiza a tabela GOLS_TIME com os gols marcados e sofridos por cada time em todos os jogos
    UPDATE [GOLS_TIME]
    SET
         GOLS_MARCADOS = COALESCE(GM.GOLS_MARCADOS, 0) -- coalesce retorna 0 se estiver nulo
        ,GOLS_SOFRIDOS = COALESCE(GS.GOLS_SOFRIDOS, 0)
    FROM [GOLS_TIME] G
        LEFT JOIN (
        SELECT TIME_CASA_ID, SUM(GOL_CASA) AS GOLS_MARCADOS
        FROM [JOGO]
        GROUP BY TIME_CASA_ID
    ) GM ON G.TIME_ID = GM.TIME_CASA_ID
        LEFT JOIN (
        SELECT TIME_VISITANTE_ID, SUM(GOL_VISITANTE) AS GOLS_SOFRIDOS
        FROM [JOGO]
        GROUP BY TIME_VISITANTE_ID
    ) GS ON G.TIME_ID = GS.TIME_VISITANTE_ID;

    -- Atualiza a pontuação dos times na tabela GOLS_TIME com base nos resultados dos jogos
    UPDATE G
    SET G.PONTUACAO =
        (CASE
            -- Se o time venceu o jogo, adiciona 3 pontos (ou 5 pontos se jogou em casa)
            WHEN J.GOL_CASA > J.GOL_VISITANTE THEN
                (CASE
                    WHEN J.TIME_CASA_ID = G.TIME_ID THEN 5
                    ELSE 3
                END)
            WHEN J.GOL_CASA < J.GOL_VISITANTE THEN
                (CASE
                    WHEN J.TIME_VISITANTE_ID = G.TIME_ID THEN 5
                    ELSE 3
                END)
            -- Se o jogo foi empate, adiciona 1 ponto
            ELSE 1
        END) + G.PONTUACAO
    FROM [GOLS_TIME] G
        JOIN [JOGO] J ON J.TIME_CASA_ID = G.TIME_ID OR J.TIME_VISITANTE_ID = G.TIME_ID;

END;
GO


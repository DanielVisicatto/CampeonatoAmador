CREATE OR ALTER TRIGGER SOMA_GOLS_JOGO
ON [JOGO] AFTER INSERT
AS
BEGIN
    UPDATE [JOGO]
    SET GOLS_JOGO = (GOL_CASA + GOL_VISITANTE)
END;
GO
DROP TRIGGER cat_cant_contain_self_trigger ON tem_outra;
DROP TRIGGER replaced_cant_exceed_plan_trigger ON evento_reposicao;
DROP TRIGGER cant_replace_where_no_cat_trigger ON evento_reposicao;

--  RI-1
CREATE OR REPLACE FUNCTION cat_cant_contain_self_proc()
RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.super_categoria = NEW.categoria THEN
        RAISE EXCEPTION 'Uma Categoria nao pode estar contida em si propria';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cat_cant_contain_self_trigger
BEFORE UPDATE OR INSERT ON tem_outra
FOR EACH ROW EXECUTE PROCEDURE cat_cant_contain_self_proc();


--  RI-4
CREATE OR REPLACE FUNCTION replaced_cant_exceed_plan_proc()
RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.unidades > (SELECT unidades FROM planograma WHERE NEW.ean = planograma.ean 
                                                    AND NEW.nro = planograma.nro 
                                                    AND NEW.num_serie = planograma.num_serie 
                                                    AND NEW.fabricante = planograma.fabricante) 
        THEN
        RAISE EXCEPTION 'O numero de unidades repostas num Evento de Reposicao nao pode exceder o numero de unidades especificadas no Planograma';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER replaced_cant_exceed_plan_trigger
BEFORE UPDATE OR INSERT ON evento_reposicao
FOR EACH ROW EXECUTE PROCEDURE replaced_cant_exceed_plan_proc();


--  RI-5
CREATE OR REPLACE FUNCTION cant_replace_where_no_cat_proc()
RETURNS TRIGGER AS
$$
BEGIN
    IF 
            (SELECT nome FROM prateleira WHERE NEW.nro = prateleira.nro 
                                AND NEW.num_serie = prateleira.num_serie 
                                AND NEW.fabricante = prateleira.fabricante) 
            NOT IN 
            (SELECT nome FROM tem_categoria WHERE tem_categoria.ean = NEW.ean) 
        THEN
        RAISE EXCEPTION 'Um produto so pode ser reposto numa Prateleira que apresente, pelo menos uma das categorias desse Produto';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cant_replace_where_no_cat_trigger
BEFORE UPDATE OR INSERT ON evento_reposicao
FOR EACH ROW EXECUTE PROCEDURE cant_replace_where_no_cat_proc();

/*==============================================================================================================================*\
                TRIGGER PARA A ELIMINAÇÃO DE RETALHISTA
\*==============================================================================================================================*/

CREATE OR REPLACE FUNCTION delete_ret_proc()
RETURNS TRIGGER AS
$$
BEGIN
    DELETE FROM evento_reposicao WHERE tin = OLD.tin;
    DELETE FROM responsavel_por WHERE tin = OLD.tin;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_ret_trigger
before DELETE ON retalhista
FOR EACH ROW EXECUTE PROCEDURE delete_ret_proc();

/*==============================================================================================================================*\
                TRIGGERS PARA A ELIMINAÇÃO DE CATEGORIA
\*==============================================================================================================================*/

CREATE OR REPLACE FUNCTION delete_cat_proc()
RETURNS TRIGGER AS
$$
BEGIN

DELETE FROM responsavel_por WHERE nome_cat = OLD.nome;

DELETE FROM planograma WHERE num_serie IN (SELECT num_serie FROM prateleira WHERE nome = OLD.nome)
                                    AND nro IN (SELECT nro FROM prateleira WHERE nome = OLD.nome)
                                    AND fabricante IN (SELECT fabricante FROM prateleira WHERE nome = OLD.nome)
                                    AND ean IN (SELECT ean FROM produto WHERE cat = OLD.nome);
DELETE FROM prateleira WHERE nome = OLD.nome;
DELETE FROM tem_categoria WHERE nome = OLD.nome;
DELETE FROM produto WHERE cat = OLD.nome;
DELETE FROM tem_outra WHERE super_categoria = OLD.nome OR categoria = OLD.nome;
DELETE FROM categoria_simples WHERE nome = OLD.nome;
DELETE FROM super_categoria WHERE nome = OLD.nome;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_cat_trigger
before DELETE ON categoria
FOR EACH ROW EXECUTE PROCEDURE delete_cat_proc();


CREATE OR REPLACE FUNCTION delete_plan_proc()
RETURNS TRIGGER AS
$$
BEGIN
    DELETE FROM evento_reposicao WHERE ean = OLD.ean AND nro = OLD.nro AND num_serie = OLD.num_serie AND fabricante = OLD.fabricante;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_plan_trigger
before DELETE ON planograma
FOR EACH ROW EXECUTE PROCEDURE delete_plan_proc();

/*==============================================================================================================================*\
                TRIGGERS PARA SE UMA SUPER CATEGORIA FICOU SEM FILHOS
\*==============================================================================================================================*/

CREATE OR REPLACE FUNCTION cat_may_need_proc()
RETURNS TRIGGER AS
$$
DECLARE
old_cat VARCHAR(80) = OLD.super_categoria;
BEGIN
    IF (old_cat NOT IN (SELECT super_categoria FROM tem_outra))
        THEN
        DELETE FROM super_categoria WHERE nome = old_cat;
        DELETE FROM categoria_simples WHERE nome = old_cat;
        INSERT INTO categoria_simples Values (old_cat);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cat_may_need_trigger
AFTER DELETE ON tem_outra
FOR EACH ROW EXECUTE PROCEDURE cat_may_need_proc();
drop table categoria cascade;
drop table categoria_simples cascade;
drop table super_categoria cascade;
drop table tem_outra cascade;
drop table produto cascade;
drop table tem_categoria cascade;
drop table IVM cascade;
drop table ponto_de_retalho cascade;
drop table instalada_em cascade;
drop table prateleira cascade;
drop table planograma cascade;
drop table retalhista cascade;
drop table responsavel_por cascade;
drop table evento_reposicao cascade;



/*------------------------------------------------------------------------------------------------------------------------------*\
|                                                                                                                                |
|       Categoria                                                                                                                |
|                                                                                                                                |
\*------------------------------------------------------------------------------------------------------------------------------*/

create table categoria
    (nome varchar(80),
     constraint pk_categoria primary key(nome));

create table categoria_simples
    (nome varchar(80),
     constraint pk_categoria_simples primary key(nome),
     constraint fk_categoria_simples_categoria foreign key(nome) references categoria(nome));

create table super_categoria
    (nome varchar(80),
     constraint pk_super_categoria primary key(nome),
     constraint fk_super_categoria_categoria foreign key(nome) references categoria(nome));

create table tem_outra
    (super_categoria varchar(80) not null,
     categoria varchar(80),
     constraint pk_tem_outra primary key(categoria),
     constraint fk_tem_outra_super_categoria foreign key(super_categoria) references super_categoria(nome),
     constraint fk_tem_outra_categoria foreign key(categoria) references categoria(nome));


/*------------------------------------------------------------------------------------------------------------------------------*\
|                                                                                                                                |
|       Produto                                                                                                                  |
|                                                                                                                                |
\*------------------------------------------------------------------------------------------------------------------------------*/

create table produto
    (ean numeric(13),
     cat varchar(80) not null,
     descr varchar(80) not null,
     constraint pk_produto primary key(ean),
     constraint fk_produto_categoria foreign key(cat) references categoria(nome));

create table tem_categoria
    (ean numeric(13) not null,
     nome varchar(80) not null,
     constraint fk_tem_categoria_produto foreign key(ean) references produto(ean),
     constraint fk_tem_categoria_categoria foreign key(nome) references categoria(nome));


/*------------------------------------------------------------------------------------------------------------------------------*\
|                                                                                                                                |
|       IVM                                                                                                                      |
|                                                                                                                                |
\*------------------------------------------------------------------------------------------------------------------------------*/

create table IVM
    (num_serie numeric(20),
     fabricante varchar(80),
     constraint pk_IVM primary key(num_serie, fabricante));

create table ponto_de_retalho
    (nome varchar(80),
     distrito varchar(80) not null,
     concelho varchar(80) not null,
     constraint pk_ponto_de_retalho primary key(nome));

create table instalada_em
    (num_serie numeric(20),
     fabricante varchar(80),
     local_ponto_de_retalho varchar(80) not null,
     constraint pk_instalada_em primary key(num_serie, fabricante),
     constraint fk_instalada_em_IVM foreign key(num_serie, fabricante) references IVM(num_serie, fabricante),
     constraint fk_instalada_em_ponto_de_retalho foreign key(local_ponto_de_retalho) references ponto_de_retalho(nome));

create table prateleira
    (nro numeric(20),
     num_serie numeric(20),
     fabricante varchar(80),
     altura numeric(3,1) not null,
     nome varchar(80) not null,
     constraint pk_prateleira primary key(nro, num_serie, fabricante),
     constraint fk_prateleira_IVM foreign key(num_serie, fabricante) references IVM(num_serie, fabricante),
     constraint fk_prateleira_categoria foreign key(nome) references categoria(nome));

create table planograma
    (ean numeric(13),
     nro numeric(20),
     num_serie numeric(20),
     fabricante varchar(80),
     faces numeric(20) not null,
     unidades numeric(50) not null,
     loc numeric(20) not null,
     constraint pk_planograma primary key(ean, nro, num_serie, fabricante),
     constraint fk_planograma_produto foreign key(ean) references produto(ean),
     constraint fk_planogram_prateleira foreign key(nro, num_serie, fabricante) references prateleira(nro, num_serie, fabricante));

create table retalhista
    (tin numeric(10),
     nome varchar(80) not null unique,
     constraint pk_retalhista primary key(tin));

create table responsavel_por
    (nome_cat varchar(80) not null,
     tin numeric(10) not null,
     num_serie numeric(20),
     fabricante varchar(80),
     constraint pk_responsavel_por primary key(num_serie, fabricante),
     constraint fk_responsavel_por_IVM foreign key(num_serie, fabricante) references IVM(num_serie, fabricante),
     constraint fk_responsavel_por_retalhista foreign key(tin) references retalhista(tin),
     constraint fk_responsavel_por_categoria foreign key(nome_cat) references categoria(nome));

create table evento_reposicao
    (ean numeric(13),
     nro numeric(20),
     num_serie numeric(20),
     fabricante varchar(80),
     instante date,
     unidades numeric(4) not null,
     tin numeric(10) not null,
     constraint pk_evento_reposicao primary key(ean, nro, num_serie, fabricante, instante),
     constraint fk_evento_reposicao_planograma foreign key(ean, nro, num_serie, fabricante) references planograma(ean, nro, num_serie, fabricante),
     constraint fk_evento_reposicao_retalhista foreign key(tin) references retalhista(tin));


/*==============================================================================================================================*\
                INSERTS
\*==============================================================================================================================*/

insert into categoria values ('Congelados');
insert into categoria values ('Peixe-Congelado');
insert into categoria values ('Carne-Congelado');
insert into categoria values ('Legumes-Congelado');
insert into super_categoria values ('Congelados');
insert into categoria_simples values ('Peixe-Congelado');
insert into categoria_simples values ('Carne-Congelado');
insert into categoria_simples values ('Legumes-Congelado');
insert into tem_outra values ('Congelados', 'Peixe-Congelado');
insert into tem_outra values ('Congelados', 'Carne-Congelado');
insert into tem_outra values ('Congelados', 'Legumes-Congelado');

insert into categoria values('Produtos-de-Limpeza');
insert into categoria values('Lixivias');
insert into categoria values('Lixivias-Limpeza');
insert into categoria values('Lixivias-Roupa');
insert into super_categoria values ('Produtos-de-Limpeza');
insert into super_categoria values ('Lixivias');
insert into categoria_simples values ('Lixivias-Limpeza');
insert into categoria_simples values ('Lixivias-Roupa');
insert into tem_outra values ('Lixivias', 'Lixivias-Limpeza');
insert into tem_outra values ('Lixivias', 'Lixivias-Roupa');

---------------------------------

insert into produto values(0000000000001, 'Peixe-Congelado', 'Pescada Congelada Pescanova');
insert into tem_categoria values(0000000000001, 'Peixe-Congelado');
insert into produto values(0000000000002, 'Peixe-Congelado', 'Pescada Congelada Ribeiralves');
insert into tem_categoria values(0000000000002, 'Peixe-Congelado');
insert into produto values(0000000000003, 'Carne-Congelado', 'Peito de Pato Congelado Marinhave');
insert into tem_categoria values(0000000000003, 'Carne-Congelado');
insert into produto values(0000000000004, 'Carne-Congelado', 'Perna de Pato Congelado Marinhave');
insert into tem_categoria values(0000000000004, 'Carne-Congelado');
insert into produto values(0000000000005, 'Carne-Congelado', 'Espetadas de Pato Congelado Marinhave');
insert into tem_categoria values(0000000000005, 'Carne-Congelado');
insert into produto values(0000000000006, 'Legumes-Congelado', 'Ervilhas Iglo');
insert into tem_categoria values(0000000000006, 'Legumes-Congelado');
insert into produto values(0000000000007, 'Legumes-Congelado', 'Ervilhas e Cenoura Iglo');
insert into tem_categoria values(0000000000007, 'Legumes-Congelado');

insert into produto values(0000000000008, 'Lixivias', 'Lixivia Tradicional Lysol');
insert into tem_categoria values(0000000000008, 'Lixivias');
insert into produto values(0000000000009, 'Lixivias', 'Lixivia Tradicional NeoBlanc');
insert into tem_categoria values(0000000000009, 'Lixivias');
insert into produto values(0000000000010, 'Lixivias-Limpeza', 'Lixivia Perfumada Frescura do Campo NeoBlanc');
insert into tem_categoria values(0000000000010, 'Lixivias-Limpeza');
insert into produto values(0000000000011, 'Lixivias-Limpeza', 'Lixivia Perfumada Harmonia Floral NeoBlanc');
insert into tem_categoria values(0000000000011, 'Lixivias-Limpeza');
insert into produto values(0000000000012, 'Lixivias-Limpeza', 'Lixivia Desengordurante NeoBlanc');
insert into tem_categoria values(0000000000012, 'Lixivias-Limpeza');
insert into produto values(0000000000013, 'Lixivias-Limpeza', 'Lixivia Desengordurante Lysol');
insert into tem_categoria values(0000000000013, 'Lixivias-Limpeza');
insert into produto values(0000000000014, 'Lixivias-Roupa', 'Lixivia Gentil NeoBlanc');
insert into tem_categoria values(0000000000014, 'Lixivias-Roupa');
insert into produto values(0000000000015, 'Lixivias-Roupa', 'Lixivia Gentil Gel NeoBlanc');
insert into tem_categoria values(0000000000015, 'Lixivias-Roupa');

---------------------------------

insert into IVM values (5318008, 'Sonae');
insert into IVM values (6221209, 'Sonae');
insert into IVM values (123987, 'QAB-Vending');

insert into ponto_de_retalho values ('Estacao-Autocarros-Sete-Rios', 'Lisboa', 'Lisboa');
insert into ponto_de_retalho values ('Oeiras-Parque', 'Lisboa', 'Oeiras');
insert into ponto_de_retalho values ('Cascais-Shopping', 'Lisboa', 'Cascais');

insert into instalada_em values (5318008, 'Sonae', 'Estacao-Autocarros-Sete-Rios');
insert into instalada_em values (6221209, 'Sonae', 'Oeiras-Parque');
insert into instalada_em values (123987, 'QAB-Vending','Cascais-Shopping');

---------------------------------

insert into prateleira values (001, 5318008, 'Sonae', 33.2, 'Peixe-Congelado');
insert into prateleira values (002, 5318008, 'Sonae', 33.2, 'Peixe-Congelado');
insert into prateleira values (003, 5318008, 'Sonae', 22.2, 'Carne-Congelado');
insert into prateleira values (004, 5318008, 'Sonae', 41.2, 'Legumes-Congelado');
insert into planograma values (0000000000001, 001, 5318008, 'Sonae', 3, 20, 1);
insert into planograma values (0000000000002, 002, 5318008, 'Sonae', 4, 20, 2);
insert into planograma values (0000000000003, 003, 5318008, 'Sonae', 4, 20, 3);
insert into planograma values (0000000000006, 004, 5318008, 'Sonae', 2, 10, 4);
insert into planograma values (0000000000007, 004, 5318008, 'Sonae', 2, 10, 5);

insert into prateleira values (001, 6221209, 'Sonae', 35.2, 'Carne-Congelado');
insert into prateleira values (002, 6221209, 'Sonae', 35.2, 'Carne-Congelado');
insert into prateleira values (003, 6221209, 'Sonae', 20.2, 'Legumes-Congelado');
insert into prateleira values (004, 6221209, 'Sonae', 37.2, 'Peixe-Congelado');
insert into planograma values (0000000000004, 001, 6221209, 'Sonae', 2, 10, 1);
insert into planograma values (0000000000005, 001, 6221209, 'Sonae', 2, 10, 2);
insert into planograma values (0000000000003, 002, 6221209, 'Sonae', 4, 20, 3);
insert into planograma values (0000000000006, 003, 6221209, 'Sonae', 2, 10, 4);
insert into planograma values (0000000000007, 003, 6221209, 'Sonae', 2, 10, 5);
insert into planograma values (0000000000001, 004, 6221209, 'Sonae', 1, 5, 6);
insert into planograma values (0000000000002, 004, 6221209, 'Sonae', 3, 15, 7);

insert into prateleira values (001, 123987, 'QAB-Vending', 21.2, 'Lixivias');
insert into prateleira values (002, 123987, 'QAB-Vending', 21.2, 'Lixivias-Limpeza');
insert into prateleira values (003, 123987, 'QAB-Vending', 21.2, 'Lixivias-Limpeza');
insert into prateleira values (004, 123987, 'QAB-Vending', 21.2, 'Lixivias-Roupa');
insert into prateleira values (005, 123987, 'QAB-Vending', 21.2, 'Lixivias-Roupa');
insert into planograma values (0000000000008, 001, 123987, 'QAB-Vending', 3, 12, 1);
insert into planograma values (0000000000009, 001, 123987, 'QAB-Vending', 2, 8, 2);
insert into planograma values (0000000000010, 002, 123987, 'QAB-Vending', 2, 8, 3);
insert into planograma values (0000000000011, 002, 123987, 'QAB-Vending', 3, 12, 4);
insert into planograma values (0000000000012, 003, 123987, 'QAB-Vending', 3, 12, 5);
insert into planograma values (0000000000013, 003, 123987, 'QAB-Vending', 2, 8, 6);
insert into planograma values (0000000000015, 004, 123987, 'QAB-Vending', 5, 20, 7);
insert into planograma values (0000000000014, 005, 123987, 'QAB-Vending', 5, 20, 8);

---------------------------------

insert into retalhista values (1234567890, 'Conglomerado1');
insert into retalhista values (0987654321, 'Conglomerado2');
insert into retalhista values (1122334455, 'Conglomerado3');
insert into retalhista values (9988776655, 'Conglomerado4');
insert into retalhista values (1199228855, 'Useless');

insert into responsavel_por values ('Peixe-Congelado', 1234567890, 5318008, 'Sonae');
insert into responsavel_por values ('Legumes-Congelado', 1234567890, 6221209, 'Sonae');

insert into responsavel_por values ('Lixivias', 1122334455, 123987, 'QAB-Vending');

---------------------------------

insert into evento_reposicao values (0000000000001, 001, 5318008, 'Sonae', '05/01/2022', 10, 1234567890);
insert into evento_reposicao values (0000000000002, 002, 5318008, 'Sonae', '05/01/2022', 7, 1234567890);
insert into evento_reposicao values (0000000000003, 003, 5318008, 'Sonae', '03/01/2022', 3, 0987654321);

insert into evento_reposicao values (0000000000003, 002, 6221209, 'Sonae', '04/01/2022', 2, 0987654321);
insert into evento_reposicao values (0000000000006, 003, 6221209, 'Sonae', '07/01/2022', 5, 1122334455);
insert into evento_reposicao values (0000000000007, 003, 6221209, 'Sonae', '07/01/2022', 4, 1122334455);
insert into evento_reposicao values (0000000000001, 004, 6221209, 'Sonae', '07/01/2022', 1, 1122334455);

insert into evento_reposicao values (0000000000008, 001, 123987, 'QAB-Vending', '06/01/2022', 2, 1122334455);
insert into evento_reposicao values (0000000000009, 001, 123987, 'QAB-Vending', '06/01/2022',  1, 1122334455);
insert into evento_reposicao values (0000000000012, 003, 123987, 'QAB-Vending', '09/01/2022',  4, 9988776655);
insert into evento_reposicao values (0000000000013, 003, 123987, 'QAB-Vending', '09/01/2022',  5, 9988776655);
insert into evento_reposicao values (0000000000015, 004, 123987, 'QAB-Vending', '09/01/2022',  6, 9988776655);
insert into evento_reposicao values (0000000000014, 005, 123987, 'QAB-Vending', '09/01/2022',  3, 9988776655);
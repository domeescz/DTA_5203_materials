

select * from payment; -- zobraz mi všechny platby (všechna data z tabulky payment)

-- vyber mi pouze sloupec - id platby, výše platby, datum platby a id zákazníka
select
    payment_id as id_platby,
    amount as castka,
    payment_date as datum_platby,
    customer_id as id_zakaznika
from payment;

-- Z tabulky plateb zobrazíme pouze platby pro zákazníka s id = 1
select *
from payment
where customer_id = 1; -- rovná se je operátor, těch máme více, např. opetátor IN

-- Z tabulky plateb zobrazíme pouze platby pro zákazníky s id = 1 a 2
select *
from payment
where customer_id in (1, 2);

-- Zobrazte platby zákazníka s id 1, ve kterých zaplatil více než 10 dolarů
-- krok č. 1 - zobrazit platby
-- krok č. 2 - zobrazit platby pro zákazníka s id 1
-- krok č. 3 - zobrazit pouze platby nad 10 dolarů
select *
from payment
where customer_id = 1 -- krok č. 2
and amount > 10;   -- krok č. 3

-- zobrazte všechny výpujčky
select *
from rental;

-- filtrování přes datum
-- zobraz výpujčky, které byly vráceny 26. května 2005
-- rok-měsíc-den , yyyy-mm-dd

select *
from rental
where cast(return_date as date) = '2005-05-26'; -- přetypování na datum
-- 2005-05-25 22:04:30 -> 2005-05-25

-- Zobrazte všechny výpujčky vráceny v roce 2005
select *
from rental
where year(return_date) = 2005;

-- zobraz výpujčky, které byly vráceny po 26. května 2005
select *
from rental
where cast(return_date as date) > '2005-05-26';

-- Vytvoříme si tabulku student se sloupci: id, jmeno, prijmeni, kurz

create table if not exists student_ds (
    id        int          primary key,
    jmeno     varchar(50)  not null,
    prijmeni  text         not null,
    kurz      text         not null
);

-- vložit své údaje do tabulky student
insert into student (id, jmeno, prijmeni, kurz) values
                        (1, 'Dominik', 'Šmída', 'Datová analytika'),
                        (2, 'Alžběta', 'Celá', 'Python');

-- úprava již existující tabulky -> vložení nového sloupce
alter table student add column start_date date default null;

select *
from student;

-- aktualizace již existujícího záznamu v tabulce
update student set start_date = CURDATE()       -- '2025-09-20'
where id in (1, 2);
-- where id = 1;

select *
from customer;

-- Zobrazit všechny aktivní zákazníky (tabulka customers)
select *
from customer
where active = 1;

select *
from payment;

-- Zobrazte platby, které byly provedeny po 1. 6. 2005
select *
from payment
where cast(payment_date as date) > '2005-06-01';


-- Zobrazte filmy, které trvají déle, než 2 hodiny a zároveň byly vydány v roce 2006
select *
from film
where length > 120
and release_year = 2006;

-- Seřadit platby od nejvyšší částky po nejnižší
select *
from payment
order by amount desc; -- asc = vzestupně, je použito implicitně, desc = sestupně
-- ORDER BY = klauzule pro řazení dat

-- Omezení výsledku - např. zobrazení pouze prvních 5 záznamů
select *
from payment
order by amount desc
limit 5;

-- Vyhledávání v textovém řetězci - pouze přes část textu
-- operace s textovým řetězcem

-- Zobrazit zákazníky, kteří mají emailovou doménu @sakilacustomer.org
select *
from customer
where email like '%sakilacustomer.org'; -- hledané slovo je vždy na konci a za ním nic není

select *
from customer
where email like 'sakilacustomer.org%'; -- hledané slovo je vždy na začátku a za ním je cokoliv

select *
from customer
where email like '%sakilacustomer.org%'; -- hledané slovo je kdekoliv
    -- negace = NOT LIKE

-- Najdi film, který má v popisku slovo Dog
select *
from film
where description like '%Dog%'; -- like není case-sensitive

-- Zobrazte všechny neaktivní zákazníky se store_id = 1 (tabulka customers)
select *
from customer
where active = 0
and store_id = 1;

-- Získej všechny výpujčky, které doposud nebyly vráceny (return_date je prázdný)
select *
from rental
where return_date is null;

-- Získej všechny výpujčky, které již byly vráceny (return_date není prázdný)
select *
from rental
where return_date is not null;

-- Zobraz počet výpujček, které doposud nebyly vráceny
select count(*) as pocet_zaznamu
from rental
where return_date is null;

-- ZObraz platby, které jsou menší než 2 dolary anebo větší, než 5 dolarů
select *
from payment
where amount < 2 or amount > 5;

-- Zobrazte všechny aktivní zákazníky anebo ty zákazníky, kteří mají křestní jméno ANDRE (tab. customer)
select first_name,
       active
from customer
where active = 1
or first_name = 'ANDRE'
order by first_name;

-- Zobrazte počet plateb, jejíž částka je vyšší, než 10 dolarů a byly provedeny v roce 2005
select count(*) as pocet_plateb
from payment
where amount > 10
and year(payment_date) = 2005;

-- Zobrazte počet nevrácených výpujček pro zákazníka s id 19
select count(*) as pocet_nevracenych_vypujcek
from rental
where return_date is null
and customer_id = 19;

-- Zobrazte počet vrácených výpujček pro zákazníka s id 19

select count(*) as pocet_nevracenych_vypujcek
from rental
where return_date is not null
and customer_id = 19;


-- Zobrazte všechny filmy, které začínají písmenem A, trvají déle, než 1.5 hodiny
-- a v popisu filmu se vyskytuje slovo dog.
-- Výsledná data seřaďte podle doby trvání filmu sestupně.
select *
from film
where title like 'A%'
and length > 90
and description like '%dog%'
order by length desc;

select amount as castka
from payment
where castka > 10; -- nejde, protoze where se preklada driv, nez select

-- V klauzuli where nemůžu používat alias, v klauzuli order by ano (kvůli order execution)
select year(payment_date) as rok
from payment
where year(payment_date) > 2005
order by rok desc;

-- mazání záznamů z tabulky
-- smazat studentku alžbetu
delete from student where id=2;

select *
from student;

-- smaž všechny záznamy v tabulce student
delete from student;

-- vymaž obsah celé tabulky student
truncate table student;

-- vymaž celou tabulku i s jejím obsahem
drop table student;

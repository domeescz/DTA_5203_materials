
-- Kolik bylo celkem vytvořeno objednávek?
select count(*) as pocet_objednavek
from orders;

-- Zjistit všechny možné stavy objednávek (status)
select distinct status
from orders;

-- Zobrazit pouze objednávky, které jsou ve stavu odesláno (Shipped)
select *
from orders
where status = 'Shipped';

-- Zobrazit pouze objednávky, které jsou ve stavu odesláno (Shipped) nebo v proces (In Process)
select *
from orders
where status = 'Shipped'
or status = 'In Process';

select *
from orders
where status in ('Shipped', 'In Process')
order by status;

-- Zjistěte, kolik objednávek se nachází v každém z dostupných stavů
select
    status,
    count(*) as pocet
from orders
group by status;

-- Zjistěte, který zákazník má nejvíce objednávek. Zobrazte jméno a příjmení zákazníka
select
    o.customerNumber,
    c.customerName,
    count(*) as pocet_objednavek
from orders o
join customers c on o.customerNumber = c.customerNumber
group by o.customerNumber, c.customerName
order by pocet_objednavek desc;

-- View / pohled
create or replace view zakaznici_pocet_objednavek_vw as
    select
        o.customerNumber,
        c.customerName,
        count(*) as pocet_objednavek
    from orders o
    join customers c on o.customerNumber = c.customerNumber
    group by o.customerNumber, c.customerName
    order by pocet_objednavek desc;

select * from zakaznici_pocet_objednavek_vw
where pocet_objednavek > 10;

-- Dočasná tabulka / temporary table / tempovka
create temporary table temp_zakaznik_pocet_objednavek as
select
        o.customerNumber,
        c.customerName,
        count(*) as pocet_objednavek
from orders o
join customers c on o.customerNumber = c.customerNumber
group by o.customerNumber, c.customerName
order by pocet_objednavek desc;

-- temp
select * from temp_zakaznik_pocet_objednavek
where pocet_objednavek > 5;
-- vw
select * from zakaznici_pocet_objednavek_vw
where pocet_objednavek > 10;

-- Vytvořte view zamestnanci_san_francisco_vw, které bude zobrazovat zaměstnance, kteří mají kancelář v San Franciscu
create or replace view zamestnanci_san_francisco_vw as
select
    employeeNumber,
    concat(e.firstName, ' ', e.lastName) as jmeno_zamestnance,
    e.email,
    o.city as umisteni_kancelare
from employees e
join offices o on e.officeCode = o.officeCode
where o.city = 'San Francisco';

select * from zamestnanci_san_francisco_vw;

select
    od.orderNumber as cislo_objednavky,
    od.productCode,
    p.productName,
    od.quantityOrdered as pocet_objednanych_kusu
from orderdetails od
join orders o on od.orderNumber = o.orderNumber
join products p on od.productCode = p.productCode;

-- Zjistěte/spočtěte celkovou cenu jednotlivých objednávek - uložte tento seznam do view
create or replace view objednavky_cena_celkem_vw as
select
    orderNumber,
    sum(quantityOrdered * priceEach) as celkova_cena,
    count(distinct productCode) as pocet_produktu
from orderdetails
group by orderNumber
order by celkova_cena desc;

select *
from objednavky_cena_celkem_vw;

-- Zjistit průměrnou dobu zpracování objednávky (od jejího přijmutí/vytvoření po její odeslání)
select orderNumber,
       orderDate as datum_prijeti,
       shippedDate as datum_odeslani,
       datediff(shippedDate, orderDate) as doba_zpracovani
from orders;

select avg(datediff(shippedDate, orderDate)) as prumerna_doba_zpracovani
from orders;

-- Zjistit průměrnou dobu zpracování objednávky v každém měsíci
create or replace view prumerna_doba_zpracovani_vw as
select month(shippedDate) as mesic_odeslani,
       avg(datediff(shippedDate, orderDate)) as prumerna_doba_zpracovani,
       count(orderNumber) as pocet_objednavek
from orders
group by month(shippedDate)
order by mesic_odeslani desc;

select * from prumerna_doba_zpracovani_vw
where prumerna_doba_zpracovani > 3.8;

-- Zjistěte meziměšíční růst/pokles v průměrné době zpracování objednávek a identifikujte ty měsíce,
-- ve kterých tato průměrná doba vzrostla
select mesic_odeslani,
       prumerna_doba_zpracovani,
       lag(prumerna_doba_zpracovani) over (order by mesic_odeslani) as prumerna_doba_zpracovani_predesly_mesic,
       prumerna_doba_zpracovani - lag(prumerna_doba_zpracovani) over (order by mesic_odeslani) as rozdil,
       case
           when prumerna_doba_zpracovani > lag(prumerna_doba_zpracovani) over (order by mesic_odeslani) then 'narust'
           else 'pokles'
       end as mezimesicni_rust_pokles
from prumerna_doba_zpracovani_vw
order by mesic_odeslani;

-- CASE expression
select orderNumber,
       status,
       case
           when status = 'Shipped' then true
           else false
       end as is_shipped_order
from orders
order by is_shipped_order desc;

select customerNumber,
       customerName,
       creditLimit,
       case
           when creditLimit < 30000 then 'pod 30k'
           when creditLimit < 50000 then 'pod 50k'
           when creditLimit < 100000 then 'pod 100k'
           else 'nad 100k'
       end as vyse_limitu
from customers;

create temporary table produkt_kategorie as
select productCode,
       productName,
       productLine,
       buyPrice,
       case
           when buyPrice < 50 then 'levne'
           when buyPrice < 100 then 'stredni'
           else 'drahe'
       end as kategorie_ceny
from products;

select kategorie_ceny,
       count(*) as pocet_produktu
from produkt_kategorie
group by kategorie_ceny;

-- Vytvorit novou kategorii (sloupec na tabulce payments), ktery bude obsahovat hodnotu velka platba, pokud platba presahla 30000
-- pokud ne, priradime hodnotu ok
select *,
       case
           when amount > 30000 then 'velka platba'
           else 'ok'
        end as kategorie_platby
from payments;

-- Příklad č. 1:
-- Zjistěte jméno zákazníka s nejvíce objednávkami
select
    customerName,
    count(orderNumber) as pocet_objednavek
from orders o
join customers c on o.customerNumber = c.customerNumber
group by customerName
order by pocet_objednavek desc
limit 1;

-- Příklad č. 2
-- Zjistěte výši průměrné platby pro každého zákazníka
select
    customerName,
    avg(amount) as prumerna_platba
from payments p
join customers c on p.customerNumber = c.customerNumber
group by customerName
order by prumerna_platba desc;

-- Příklad č. 3
-- Kolik bylo provedeno objednávek od 2.1.2003
select
    count(orderNumber) as pocet_objednavek
from orders
where orderDate >= '2003-01-02';

-- Příklad č. 3
-- Zjistěte měsíc, ve kterém bylo provedeno nejvíce objednávek
select
    month(orderDate) as mesic,
    count(orderNumber) as pocet_objednavek
from orders
group by month(orderDate)
order by pocet_objednavek desc;

-- Příklad č. 4
-- Zjistěte průměrnou cenu každé objednávky, výsledek seřaďte vzestupně (orderdetails)
select
    orderNumber,
    avg(priceEach * quantityOrdered) as prumerna_cena
from orderdetails
group by orderNumber
order by prumerna_cena;

select productCode,
       productName,
       productLine,
       quantityInStock
from products;

-- Zjistit průměrnou dostupnost jednotlivých kategorií produktů
-- Vytvorte novy sloupec, ve kterém budete hlídat dostupnost jednotlivých kategorií.
-- Pokud je průměrná dostupnost nižší, než 3000, pak vyplňte LOW CAPACITY, jinak OK CAPACITY
select
    avg(quantityInStock) as prumerna_dostupnost,
    productLine,
    case
        when avg(quantityInStock) < 3000 then 'LOW CAPACITY'
        else 'OK CAPACITY'
    end as kapacita
from products
group by productLine;

select *,
       sum(amount) over (partition by customerNumber) as suma_plateb,
       avg(amount) over (partition by customerNumber) as prumerna_platba
       -- amount - avg(amount) over (partition by customerNumber) as rozdil_oproti_prumerne_platbe
from payments;

-- Ocislovani plateb pres celou tabulku
select *,
       dense_rank() over (order by amount desc) as poradi
from payments

-- Ocislovani plateb pres jednotlive zakazniky
select *,
       dense_rank() over (partition by customerNumber order by amount desc) as poradi_dense_rank,
       rank() over (partition by customerNumber order by amount desc) as poradi_rank,
       row_number() over (partition by customerNumber order by amount desc) as poradi_row
from payments;

update payments set amount = '120166.58' where checkNumber = 'ID10962';


-- najděte nejvyšší platbu
select *
from payments
order by amount desc
limit 1;

create temporary table platby_poradi as
select
    *,
    dense_rank() over (order by amount desc) as poradi
from payments;

select * from platby_poradi
where poradi = 1;

-- Zkuste očíslovat (vytvořit pořadí)
-- produktů podle dostupnosti (1 = produkt s nejvyšší dostupností)
select
    productCode,
    productName,
    productLine,
    quantityInStock,
    dense_rank() over (partition by productLine order by quantityInStock desc) as poradi
from products
order by productLine;

delimiter //
create procedure report_plateb(in amountFrom int)
begin
    select *
    from payments
    where amount >= amountFrom;
end //

call report_plateb(30000);

-- smazani procedury
drop procedure report_plateb;

-- Vytvořte proceduru vracející produkty, které mají míň kusů na skladě, než definuje uživatel při volání procedury
delimiter //
create procedure produkty_dostupnost(in pocetKusu int)
    begin
        select *
        from products
        where quantityInStock < pocetKusu;
    end //

call produkty_dostupnost(5000);

-- Vytvořte proceduru, která generuje report (počet) vzniklých objednávek za dané období
delimiter //
create procedure report_objednavek(in datumOd date, in datumDo date)
begin
    select count(*) as pocet_objednavek
    from orders
    where orderDate between datumOd and datumDo;
end //

call report_objednavek('2003-01-01', '2003-01-14');


-- Vytvořte proceduru report_objednavek_stav , který bude zobrazovat počet objednávek, které se nachází v daném stavu
-- Stav objednávky zadává uživatel při volání procedury
delimiter //
create procedure report_objednavek_stav(in stav varchar(20))
begin
    select count(*) as pocet_objednavek
    from orders
    where status = stav;
end //

call report_objednavek_stav('Cancelled')

-- Vytvořte proceduru report_zakaznika. Výsledek by měl obsahovat tyto údaje:
-- jméno a příjmení zákazníka, celkový počet plateb, suma všech plateb, průměrná výše plateb a celkový počet objednávek.
-- Procedura bude umožňovat uživateli získat data dle jména zákazníka (customerName) -> vstupní parametr
delimiter //
create procedure report_zakaznika(in jmenoZakaznika text)
begin
    select
        customerName,
        count(*) as pocet_plateb,
        sum(amount) as suma_plateb,
        avg(amount) as prumerna_platba,
        count(o.orderNumber) as pocet_objednavek
    from payments p
    join customers c on p.customerNumber = c.customerNumber
    join orders o on c.customerNumber = o.customerNumber
    where customerName = jmenoZakaznika
    group by customerName;
end //

call report_zakaznika('Atelier graphique');


create table zamestnanci (
    id int primary key auto_increment,
    jmeno text not null ,
    prijmeni text not null ,
    adresa text null,
    oddeleni text not null,
    mzda int not null
);

insert into zamestnanci (jmeno, prijmeni, adresa, oddeleni, mzda) values
    ('Aleš', 'Pán', 'Praha', 'IT', 66666),
    ('Alena', 'Pánová', 'Praha', 'HR', 55555),
    ('Olaf', 'Švarc', 'Brno', 'IT', 77777),
    ('Andrej', 'Oslzlý', 'Ostrava', 'HR', 88888),
    ('Arnélie', 'Žraloková', 'Svitavy', 'HR', 44444);

-- Zjistěte druhý nejvyšší plat z každého oddělení
with cte_plat_poradi as (
    select *,
         dense_rank() over (partition by oddeleni order by mzda desc) as poradi
    from zamestnanci
)
select
    *
from cte_plat_poradi
where poradi = 2;

-- Zobrazte platby, jejichž výše přesahuje průměrnou výši platby
-- V CTE vypočítám průměrnou výši platby
-- Ve finálním selectu zobrazím pouze ty záznamy, které mají částku vyšší, než je průměrná částka
with cte_prumerna_platba as (
    select avg(amount) as prumerna_platba
    from payments
)
select *
from payments
where amount > (select prumerna_platba from cte_prumerna_platba);

-- Porovnejte meziroční tržby plateb
with cte_seskupene_platby as (
    select
        year(paymentDate) as rok,
        sum(amount) as trzby
    from payments
    group by year(paymentDate)
)
select *,
       lag(trzby) over (order by rok) as trzby_predesly_rok,
       case
           when trzby > lag(trzby) over (order by rok) then 'mezirocni rust'
           when lag(trzby) over (order by rok) is null then '-'
           else 'mezirocni pokles'
       end as trend_trzeb,
       (trzby - lag(trzby) over (order by rok)) / lag(trzby) over (order by rok) * 100 as procentualni_trend
from cte_seskupene_platby;


-- K platbám zobrazte jméno zákazníka - jméno zákazníka, datum platby, částka
select
    customerName,
    paymentDate,
    amount as castka
from payments p
join customers on p.customerNumber = customers.customerNumber;
-- Vytvořte view, které bude zobrazovat všechny odeslané objednávky
create or replace view odeslane_objednavky_vw as
select *
from orders
where status = 'Shipped';

select * from odeslane_objednavky_vw;

-- Vytvořte proceduru, která bude zobrazovat platby pouze z požadovaného (zadaného) roku
delimiter //
create procedure if not exists platby(in rok int)
    begin
        select *
        from payments
        where year(paymentDate) = rok;
    end //

call platby(2003);



-- Zobrazit průměrnou výši platby pro každého zákazníka
select
    customer_id,
    avg(amount) as prumerna_platba,
    count(amount) as pocet_plateb,
    sum(amount) as suma_plateb,
    min(amount) as minimalni_platba,
    max(amount) as maximalni_platba
from payment
group by customer_id;

-- Zobrazit průměrnou výši platby pro každého zákazníka v roce 2005
select
    customer_id,
    avg(amount) as prumerna_platba
from payment
where year(payment_date) = 2005
group by customer_id;

-- Zobrazit průměrnou výši platby pro každého zákazníka v každém roce
select
    customer_id,
    year(payment_date) as rok,
    avg(amount) as prumerna_platba
from payment
group by customer_id, year(payment_date)
order by customer_id, rok;

-- Zjistěte počet plateb, které provedli jednotliví zaměstnanci (z tabulky payment)
select
    staff_id,
    count(payment_id) as pocet_plateb
from payment
group by staff_id;


-- Zobrazte počet výpujček pro každého zákazníka (rental)
select
    customer_id,
    count(rental_id) as pocet_vypujcek
from rental
group by customer_id;

-- Zobrazte počet nedokončených výpujček pro každého zákazníka
select
    customer_id,
    count(rental_id) as pocet_vypujcek
from rental
where return_date is null
group by customer_id
order by pocet_vypujcek desc;

-- Zjistěte rok, ve kterém byl zaznamenán nejvyšší obrat plateb
select
    year(payment_date) as rok,
    sum(amount) as obrat
from payment
group by year(payment_date)
order by obrat desc
limit 1;

-- Z tabulky film_analytics najít film, který má největší obsazení herců
select
    *
from film_analytics
where actors = (
    select
        max(actors)
    from film_analytics
    );

-- Zjistěte, který zákazník provedl nejvyšší platbu
select
    *
from payment
where amount = (
    select
        max(amount)
    from payment
    );

 -- to stejné pomocí agregace
select
    customer_id,
    max(amount) as maximalni_platba
from payment
group by customer_id
order by maximalni_platba desc;

-- Zjistěte, pod který okres spadá nejvíce adres (tabulka address)
select
    district,
    count(address_id) as pocet_adres
from address
group by district
order by pocet_adres desc;

-- Zjistěte, u kolika adres chybí poštovní směrovací číslo
select count(*) as pocet_adres_bez_psc
from address
where postal_code = ''      -- v datech nejsou null hodnoty, ale prazdne znaky
or postal_code is null;

-- Zjistěte průměrnou výši tržeb a průměrný počet výpujček pro každý rating
select
    rating,
    avg(payments) as prumerna_trzba,
    avg(rentals) as prumerny_pocet_vypujcek
from film_analytics
group by rating
order by prumerna_trzba desc, prumerny_pocet_vypujcek desc;

-- Jaký je průměrná tržba filmů, které začínají na písmeno A
select
    avg(payments) as prumerna_trzba
from film_analytics
where title like 'A%';

-- Zjistěte, jestli se některé z jmen vyskytuje u herců vícekrát
select
    first_name,
    count(actor_id) as pocet_vyskytu
from actor
group by first_name
having count(actor_id) > 1; -- having umožňuje filtrování NAD SESKUPENÝMI daty (agreg. funkce)

-- Zjistěte ratingy, které mají průměrnou tržbu je vyšší, než 70 dolarů
select
    rating,
    avg(payments) as prumerna_trzba
from film_analytics
group by rating
having prumerna_trzba > 70;


-- JOINY

select
    payment.payment_date,
    payment.amount as castka,
    customer.first_name as krestni_jmeno,
    customer.last_name as prijmeni
from payment
inner join customer on payment.customer_id = customer.customer_id;

-- Ke každé výpujčce zobrazit username zaměstnance
select
    rental_id,
    rental_date,
    return_date,
    staff.username as username_zamestnance
from rental
join staff on rental.staff_id = staff.staff_id;

-- Ke každému filmu zobrazte, v jakém jazyce byl natočen
select
    film.title,
    language.name as jazyk
from film
join language on film.language_id = language.language_id
where language.name = 'English';

-- Ke každé platbě zobrazte také datum výpujčky
select
    payment_id,
    amount,
    payment_date,
    rental_date
from payment
join rental on payment.rental_id = rental.rental_id;

-- Zobrazte pouze platby, které nemají datum platby shodné s datumem výpujčky
select
    payment_id,
    amount,
    payment_date,
    rental_date
from payment
join rental on payment.rental_id = rental.rental_id
where payment.payment_date != rental.rental_date;


-- Na tabulku platby chci napojit tabulku zákazníka, zaměstnanců a výpujček
-- CHci zobrazit jméno + příjmení zákazníka, jméno + příjmení zaměstnance a datum výpujčky
select
    payment_id,
    payment.amount as castka_platby,
    customer.first_name as jmeno_zakaznika,
    customer.last_name as prijmeni_zakaznika,
    staff.first_name as jmeno_zamestnance,
    staff.last_name as prijmeni_zamestnance,
    rental.rental_date as datum_vypujcky
from payment
join customer on payment.customer_id = customer.customer_id
join rental on payment.rental_id = rental.rental_id
join staff on payment.staff_id = staff.staff_id;

-- left join -> prace s null hodnotami v leve tabulce (chceme zobrazit)
select
    *
from payment
left join rental on payment.rental_id = rental.rental_id
-- where payment.rental_id is null;

-- right join
select
    *
from rental
right join payment on rental.rental_id = payment.rental_id;

-- payment_id,
-- rental_id,
-- amount,
-- rental_date,
-- payment_date.

select
    payment_id,
    r.rental_id,
    amount as castka,
    rental_date as rentalDate,
    payment_date as paymentDate
from payment p
join rental r on p.rental_id = r.rental_id;

select
    r.inventory_id,
    r.rental_id,
    i.film_id
from rental r
join inventory i on r.inventory_id = i.inventory_id;

-- inventory_id, film_id, title, description, release_year.
select
    i.inventory_id,
    f.film_id,
    f.title,
    f.description,
    f.release_year
from film f
join inventory i on f.film_id = i.film_id;

-- Zjistit průměrnou platbu pro každé zákazníka (vypsat jeho jméno)
select
    concat(first_name, ' ', last_name) as cele_jmeno,
    avg(amount) as prumerna_platba
from payment p
join customer c on p.customer_id = c.customer_id
group by first_name, last_name;

-- spojení dvou sloupců do jednoho
select
    first_name,
    last_name,
    concat(first_name, ' ', last_name) as cele_jmeno
from customer;

-- Zobrazte pouze jméno a příjmení těch zákazníků, kteří NEMAJÍ dokončenou výpujčku
select
    concat(c.first_name, ' ', c.last_name) as jmeno_zakaznika
from rental r
join customer c on r.customer_id = c.customer_id
where return_date is null;

-- Zobrazte pouze id výpujčky, jméno a příjmení těch zákazníků, kteří NEMAJÍ dokončenou výpujčku.
-- Zobrazte i výši platby, která byla za tuto konkrétní výpujčku provedena
select
    r.rental_id,
    concat(c.first_name, ' ', c.last_name) as jmeno_zakaznika,
    p.amount as vyse_platby
from rental r
join customer c on r.customer_id = c.customer_id
join payment p on r.rental_id = p.rental_id
where return_date is null;

-- Zobrazte unikátní jméno a příjmení těch zákazníků, kteří NEMAJÍ dokončenou výpujčku
select
     distinct concat(c.first_name, ' ', c.last_name) as jmeno_zakaznika
from rental r
join customer c on r.customer_id = c.customer_id
where return_date is null
order by jmeno_zakaznika;
-- DISTINCT mi zajišťuje deduplikaci hodnot ve sloupci

-- Zjistěte jméno a příjmení zákazníka, který provedl historicky nejvíce plateb
select
    concat(c.first_name, ' ', c.last_name) as jmeno_zakaznika,
    count(payment_id) as pocet_plateb
from payment p
join customer c on p.customer_id = c.customer_id
group by c.first_name, c.last_name
order by pocet_plateb desc
limit 116;


-- rental id,
-- film id,
-- film title,film description,film rating,rental rating,rental date, payment date, payment amount.
select
    r.rental_id as id_vypujcky,
    f.film_id as id_filmu,
    f.title as nazev_filmu,
    f.description as popis_filmu,
    f.rating as hodnoceni,
    f.rental_rate as hodnoceni_vypujcky,
    r.rental_date as datum_vypujcky,
    p.payment_date as datum_platby,
    p.amount as castka_platby
from payment p
left join rental r on p.rental_id = r.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film f on i.film_id = f.film_id
where year(r.rental_date) = 2005
order by castka_platby desc;


-- Výpujčky, které nemají žádnou platbu
select *
from rental r
left join payment p on r.rental_id = p.rental_id
where p.rental_id is null;

-- vložení nové výpujčky bez platby - pro ukázku
insert into rental (rental_date, inventory_id, customer_id, return_date, staff_id) VALUES
                (CURDATE(), 1070, 1, null, 1);

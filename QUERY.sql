/*le prime 5 sanzioni maggiormente utilizzate alla prima infrazione*/  
SELECT  sanction,count(sanction) as num_scuole
from sanctions
where offense='1st'
group by sanction
order by num_scuole desc
limit 5;


/*sanzione maggioromente utlizzata per 1°,2°,3°,4°,5° e qualsiasi infrazione*/
/* questa query non mi torna invece di restituirmi la sanzione piu usata per ogni num infrazione 
mi restituisce la prima per gruppo(offense) che trova*/
with tab as(
select offense,sanction,count(sanction) as num
from sanctions
group by offense,sanction
order by offense )
select offense,sanction
from tab
where num in (select max(num) over(partition by offense) from tab )
group by offense


/*numero scuole che vietano questa parte del corpo ai ragazzi*/
SELECT COUNT(bodyparts) AS num_scuole from body_by_school 
WHERE bodyparts like '%midriff%' AND prohibited='male';


/*stati e scuole con sanzione più severa alla prima infrazione*/
SELECT schoolname,state,sanction,offense as numero_infrazione
from sanctions 
where sanction='detention'and offense='1st';


/*indumenti e parti del corpo vietati agli studenti raggruppati per scuole e categoria e genere proibito*/
with temp as
(select schoolname,item,banned_items.type,prohibited
from banned_items
where banned_items.prohibited in('female','male','none','boys')
order by schoolname)
select temp.schoolname,group_concat(temp.item order by temp.item asc separator ',') as indumenti,count(temp.item)as num_item,
temp.type,case temp.prohibited 
when 'female' then 'FEMALE'
when 'male' then 'MALE'
when 'boys' then 'MALE'
when 'none' then 'f & m' end as prohibited
from temp 
group by temp.type,temp.schoolname,temp.prohibited
order by schoolname;


/*abbigliamento vietato esplicitamente a maschi e femmine per ogni scuola */
SELECT banned_items.schoolname ,clothesdetails.slug,banned_items.prohibited
from banned_items INNER JOIN clothesdetails on banned_items.item = clothesdetails.item
where banned_items.prohibited in('male','female')
order by banned_items.schoolname,banned_items.prohibited;


/*i 5 indumenti maggiormente vietati ai ragazzi*/
SELECT slug,count(slug) as num_scuole
from banned_items join clothesdetails on banned_items.item=clothesdetails.item 
where prohibited='male'
group by slug order by num_scuole DESC
limit 5;


/*indumento maggiormente vietato esplicitamente alle ragazze*/
with tab1 as
(select clothesdetails.slug,count(banned_items.prohibited) as numero
from banned_items join clothesdetails on banned_items.item=clothesdetails.item and banned_items.type=clothesdetails.type
where banned_items.prohibited in('female')
group by clothesdetails.slug
order by numero desc)
select slug from tab1 where numero=(SELECT max(numero) from tab1);


/*principi che devono rispettare gli indumenti indossati dagli studenti per ogni stato*/  
with tab as(
select banned_items.state,case words_percentages.display
when 'Distract or Disrupt' then 'NO Distract or Disrupt' 
when 'Interfere with Learning' then 'NO Interfere with Learning' 
else words_percentages.display end as principi
from banned_items join words_percentages
on banned_items.item=words_percentages.item
order by banned_items.state)
select tab.state,group_concat(distinct tab.principi order by tab.principi asc separator ',') as regole
from tab
group by tab.state;


/*scuola e stato che proibiscono la visibilità delle spalle alle ragazze*/
select schoolname,state
from banned_items
where item like '%shoulders%' and prohibited='female'


/* prime 10 scuole con numero maggiori di sanzioni*/
select schoolname,count(sanction) as num_sanzioni
from sanctions
group by schoolname
order by num_sanzioni desc
limit 10


/*classifica zona per indumenti vietati*/
select body_by_school.localegroup,count(item) as numero_indumenti_vietati
from body_by_school join banned_items
on body_by_school.schoolname=banned_items.schoolname
where banned_items.prohibited='female' and banned_items.type in (select distinct type from clothesdetails)
group by localegroup
order by numero_indumenti_vietati desc



/*scuola più permissiva con le ragazze ;un solo indumento vietato*/
select schoolname,count(item)as num
from banned_items
where type in(select distinct type from clothesdetails) and prohibited='female'
group by schoolname
order by num asc
limit 1

select * from [dbo].[Data1]

select count rows from data1

select * from [dbo].[Data2]

-- no. of rows in our dataset


select count(*) from Data1
select count(*) from Data2

--Dataset for jharkhand and bihar

select * from Data1 where State in ('Jharkhand','Bihar')

--Population of India

select sum(population) as Population from [Census Project]..Data2

--Avg Growth of India

select AVG(growth)*100 avg_growth from Data1

--Avg growth by each state

select state,avg(growth)*100 
as avg_growth from Data1
group by (state)

--avg sex ratio of each state

select state, round(avg(sex_ratio),0) avg_sex_ratio_state
from Data1
group by (state)

--sorting the data

select state, round(avg(sex_ratio),0) avg_sex_ratio_state
from Data1
group by (state)
order by avg_sex_ratio_state  desc;

--avg literacy rate of each state

select state, round(avg(literacy),0) avg_literacy_rate
from Data1
group by state 
order by avg_literacy_rate desc;

--avg literacy rate of each state having literact more that 70

select state, round(avg(literacy),0) avg_literacy_rate
from Data1
group by state 
having round(avg(literacy),0)>90 
order by avg_literacy_rate desc;

--Top 3 state showing highest growth ratio

select top 3 state, avg(growth)*100 
as avg_growth from Data1
group by (state)
order by avg_growth desc;

--bottom 3 state showing lowest sex ratio


select top 3 state, round(avg(sex_ratio),0) avg_sex_ratio_state
from Data1
group by (state)
order by avg_sex_ratio_state  asc;

--creating new table and then inserting data----> to visualise the top 3 as well as bottom 3 states in literacy

drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
topstate float
)

insert into #topstates
select state, round(avg(literacy),0) avg_literacy_rate
from Data1
group by state 
order by avg_literacy_rate desc

select top 3 * from #topstates order by #topstates.topstate desc

--bottom literacy rate

drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
bottomstate float
)

insert into #bottomstates
select state, round(avg(literacy),0) avg_literacy_rate
from Data1
group by state 
order by avg_literacy_rate desc

select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;

--union operator----> to combine to two sets of output.

select * from (
select top 3 * from #topstates order by #topstates.topstate desc) a 

union

select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b

--states starting with letter a

select distinct(state) from Data1 where lower(state) like 'a%'


select distinct(state) from Data1 where lower(state) like 'a%' or lower(state) like 'b%'


select distinct(state) from Data1 where lower(state) like 'a%' or lower(state) like '%b'

--joining both the tables.

--total males and females

select  d.state, sum(d.males) total_males,
sum(d.females) total_females from
(select c.district, c.state,
round(c.population/(c.sex_ratio +1),0) males,
round((c.population*c.sex_ratio)/(c.sex_ratio -1),0) females from

(select a.district, a.State, a.sex_ratio/100 sex_ratio, b.population 
from Data1 as a inner join Data2 as b 
on a.District = b.District)c) d
group by d.state

--total literacy rates

select e.state, sum(e.literate_people)total_literate_people, sum(e.illeterate_peoples) total_illeterate_people from

(select state, d.district, round(d.literacy_ratio*d.population,0) literate_people, round((1-d.literacy_ratio)*d.population,0) illeterate_peoples from
(select a.district, a.State, a.literacy/100 literacy_ratio, b.population 
from Data1 as a inner join Data2 as b 
on a.District = b.District) d)e
group by e.state;

--population in previous census


select sum(m.previous_census_population) total_previous_census_population, sum(m.present_census_population)total_present_census_population from

(select  e.state , sum(e.previous_census_population) previous_census_population, 
sum(e.population) present_census_population from

(select d.district , d.state, round(d.population/(1+d.growth),0) previous_census_population , d.population from 
(select a.district, a.State, a.growth, b.population 
from Data1 as a inner join Data2 as b 
on a.District = b.District)d) e
group by e.state) m

--population vs area

select (g.total_area/ g.total_previous_census_population) as previous_census_population_vs_area, (g.total_area/ g.total_present_census_population) as present_census_population_vs_area from
(select q.*,r.total_area from (

select '1' as keyy, n.* from
(select sum(m.previous_census_population) total_previous_census_population, sum(m.present_census_population)total_present_census_population from

(select  e.state , sum(e.previous_census_population) previous_census_population, 
sum(e.population) present_census_population from

(select d.district , d.state, round(d.population/(1+d.growth),0) previous_census_population , d.population from 
(select a.district, a.State, a.growth, b.population from Data1 as a inner join Data2 as b 
on a.District = b.District)d) e group by e.state) m)n)q inner join (

select '1' as keyy, z.* from (select sum(area_km2) total_area from data2)z)r  on q.keyy = r.keyy)g

--window function
--output - top 3 districts from each state with highest literacy rate.

select a.* from
(select district, state, literacy, rank() over(partition by state order by literacy desc) rnk from data1)a
where a.rnk in (1,2,3) order by state;
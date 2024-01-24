
create table ipl_matches 
(
    id int primary key,
	city varchar,
	date varchar,
	player_of_match varchar,
	venue varchar,
	neutral_venue varchar,
	team1 varchar,
	team2 varchar,
	toss_winner varchar,
	toss_decision varchar,
	winner varchar,
	result varchar,
	result_margin varchar,
	eliminator varchar,
	method varchar,
	umpire1 varchar,
	umpire2 varchar);
	
create table ipl_ball 
(
	id int ,
					   inning varchar,
					   over varchar,
					   ball int,
					   batsman varchar,
					   non_striker varchar,
					   bowler varchar,
					   batsman_runs int,
					   extra_runs varchar,
					   total_runs int,
					   is_wicket int,
					   dismissal_kind varchar,
					   player_dismissed varchar,
					   fielder varchar,
					   extras_type varchar,
					   batting_team varchar,
					   bowling_team varchar);
					   
					   drop table ipl_ball;
	
	
copy ipl_matches from 'C:\Program Files\PostgreSQL\14\data\data copy\ipl_matches.csv' CSV header;	
	
copy ipl_ball from 'C:\Program Files\PostgreSQL\14\data\data copy\ipl_ball.csv' CSV header;	

select * from ipl_ball;



select batsman ,sum(total_runs)as total from ipl_ball  group by batsman order by total desc ;

select batsman ,sum(ball)as total from ipl_ball  group by batsman order by total desc ;

.1

/* Batsman with Highest strike rate*/

with BatsmanStats as (select batsman,SUM(batsman_runs) AS TotalRuns,
    count(*) AS Balls_Faced
    from deliveries_v02
    group by batsman
    having count(*)> 500)
select batsman,TotalRuns,Balls_Faced,
    (TotalRuns * 100.0 / Balls_Faced) AS StrikeRate
from BatsmanStats
order BY StrikeRate DESC;

.2

/*
Hard-hitting players who have scored most runs in boundaries
*/

select batsman, sum(batsman_runs) AS total_boundary_runs
from ipl_ball where
    batsman_runs in ('4', '6')  
group by batsman order by
    total_boundary_runs DESC;  

.3

/*
bowlers with good economy rate
*/

select bowler,
    sum(total_runs) AS total_runs_conceded,sum(balls_faced) AS total_balls_bowled,
    (SUM(total_runs) / count(balls_faced)) * 6 AS economy_rate from deliveries_v02
group by bowler having sum(balls_faced) > 500
order by economy_rate; 

4.

/*
bowlers with the best strike rate 
*/

select bowler,
    sum(is_wicket) AS total_wickets,
    sum(balls_faced) AS total_balls_bowled,
    (sum(balls_faced) / nullif(sum(is_wicket), 0)) AS strike_rate
	from deliveries_v02
group by bowler having sum(balls_faced) >= 500
order by strike_rate; 

5.

/*
Count of cities that have hosted an IPL match
*/

SELECT COUNT(DISTINCT city) AS city_count
FROM ipl_matches;

6.

/*
Create table deliveries_v02 with all the columns of the table ‘deliveries’ and an additional
column ball_result containing values boundary, dot or other depending on the total_run
(boundary for >= 4, dot for 0 and other for any other number)
*/

create table deliveries_v02 AS
select *, case
           when total_runs >= 4 then 'boundary'
           when total_runs = 0 then 'dot'
           when total_runs = 1 Then 'Single run'
		   when total_runs = 2 then 'Double run'		 
		   when total_runs = 3 then 'tripple run' else 'other'
end as ball_result from ipl_ball;

7.

/*
Write a query to fetch the total number of boundaries and dot balls from the
deliveries_v02 table.
*/

select
  sum(case when batsman_runs in (4,6) then 1 else 0 end) as total_boundaries,
  sum(case when batsman_runs = 0 then 1 else 0 end) as total_dot_balls
from deliveries_v02;

8.

/*
Write a query to fetch the total number of boundaries scored by each team from the
deliveries_v02 table and order it in descending order of the number of boundaries
scored.
*/

select batting_team, 
       count(case when ball_result = 'boundary' then 1 end) AS total_boundaries
from deliveries_v02
group by batting_team
order by total_boundaries DESC;

9.

/*
Write a query to fetch the total number of dot balls bowled by each team and order it in
descending order of the total number of dot balls bowled.
*/

select bowling_team, count(*) AS dot_balls
from deliveries_v02
where total_runs = 0
group by bowling_team
order by dot_balls DESC;

10.

/*
Write a query to fetch the total number of dismissals by dismissal kinds where dismissal
kind is not NA
*/

select dismissal_kind, count(*) as total_dismissals
from ipl_ball
where dismissal_kind is not null and dismissal_kind != 'NA'
group BY dismissal_kind;


11.

/*
Write a query to get the top 5 bowlers who conceded maximum extra runs from the
deliveries table
*/

select bowler, SUM(extra_runs::int) AS total_extra_runs
from deliveries_v02
group by bowler
order by total_extra_runs DESC
limit 10;

12.

/*
Write a query to create a table named deliveries_v03 with all the columns of
deliveries_v02 table and two additional column (named venue and match_date) of venue
and date from table matches
*/

create table deliveries_v03 as select d.*, m.venue, m.date AS match_date
FROM deliveries_v02 d
inner join ipl_matches m on d.id = m.id;

select * from deliveries_v03;

13.

/* Year-wise total runs scored at Eden Gardens. */

select extract(year from to_DATE(M.date, 'DD-MM-YYYY')), sum(r.total_runs) as total_runss
from ipl_matches m
join ipl_ball r on m.id = r.id
where m.venue='Eden Gardens'
group by m.date
order by total_runss DESC;

select extract(year from to_DATE(date, 'DD-MM-YYYY')) AS extracted_year
from ipl_matches;

14.

/* Total runs scored for each venue. */

select m.venue, sum(r.total_runs) AS total_runs_scored
from ipl_matches m
join ipl_ball r On m.id = r.id
group by m.venue
order by total_runs_scored DESC;

-----------******-----------....-----------******-----------....-----------******------------

drop table deliveries_v02;

select batsman,sum(is_wicket)as out from ipl_ball where is_wicket=1 group by batsman order by out desc;

select * from deliveries_v02;
select batsman,count(ball) as balls_faced from deliveries_v02 group by batsman order by balls_faced desc;

alter table deliveries_v02 add column balls_faced int;
update deliveries_v02 set balls_faced=1;

select * from deliveries_v02;



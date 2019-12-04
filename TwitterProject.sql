SET NOCOUNT ON
GO

USE master
GO
if exists (select * from sysdatabases where name='TwitterProject')
		drop database TwitterProject
GO

CREATE DATABASE TwitterProject;
GO

use TwitterProject
GO

DROP TABLE HASHTAGS;
DROP TABLE TWEETS;
DROP TABLE USERS;
DROP TABLE SEARCHES;
DROP TABLE RESEARCHERS;

CREATE TABLE RESEARCHERS (
    id    INT,
    full_name  VARCHAR(60) NOT NULL,
    profile    TEXT,
    PRIMARY KEY(id)
);

INSERT INTO RESEARCHERS VALUES (1, 'Carolina Obregon B',
                  'Student at Tec');
INSERT INTO RESEARCHERS VALUES (2, 'Patricio Salazar',
                  'Student at Tec');
INSERT INTO RESEARCHERS VALUES (3, 'Francisco Salgado',
                  'Student at Tec');

CREATE TABLE SEARCHES (
    id            INT,
    description   TEXT,
    researcher_id INT,
    PRIMARY KEY(id),
    FOREIGN KEY(researcher_id) references RESEARCHERS(id)
);

INSERT INTO SEARCHES VALUES(1, 'Search tweets containing presidential candidates names', 1);
INSERT INTO SEARCHES VALUES(2, 'Search tweets containing words related to Frozen', 3);
INSERT INTO SEARCHES VALUES(3, 'Search tweets containing Hong Kong', 2);


CREATE TABLE USERS (
    id              BIGINT,
    verified        BIT,
    followers_count BIGINT,
    PRIMARY KEY(id)
);

CREATE TABLE TWEETS (
    id                BIGINT,
    tweet_text        TEXT,
    "user"            BIGINT,
    favorite_count    BIGINT,
    search_id         INT,
    location          VARCHAR(280),
    PRIMARY KEY(id),
    FOREIGN KEY("user") references USERS(id),
    FOREIGN KEY(search_id) references SEARCHES(id)
);

CREATE TABLE HASHTAGS (
    tweet_id    BIGINT,
    hashtag     VARCHAR(280),
    PRIMARY KEY(tweet_id, hashtag),
    FOREIGN KEY(tweet_id) references TWEETS(id),
);

 
/* by location */
select count(*) as ' # of HK Tweets'
from tweets, users
where users.id = tweets.[user] and tweets.search_id = '2'
group by location having location = 'Hong Kong'
select count(*) as '# of US Tweets'
from tweets, users
where users.id = tweets.[user] and tweets.search_id = '2'
group by location having location = 'United States';
select count(*) as '# of UK Tweets'
from tweets, users
where users.id = tweets.[user] and tweets.search_id = '2'
group by location having location = 'United Kingdom';

/* by follower count */
select tweet_text
from tweets, users
where users.id = tweets.[user] and users.verified = 1 
and tweets.search_id = '2'
/* check verified followers */
select avg(followers_count) as 'Average follower count'
from users
where users.verified = 1;

/* HASHTAGS OF PPL */
select hashtag
from hashtags, tweets
where tweets.id = hashtags.tweet_id and 
tweets.search_id = '2';

/* check verified followers */

select avg(followers_count) as 'Average follower count'
from users
where users.verified = 1;

select hashtag as 'California Hashtags'
from hashtags
where hashtags.tweet_id in (
    select tweets.id
    from users, tweets
    where users.id = tweets.[user] and (tweets.search_id = '1') and (users.location = 'San Francisco' or users.location = 'California, USA' or users.location ='Los Angeles, CA' or users.location = 'California' or users.location = 'Calif.' or users.location = 'Mountain View, CA'));

select hashtag as 'New York hashtags'
from hashtags
where hashtags.tweet_id in (
    select tweets.id
    from users, tweets
    where users.id = tweets.[user] and (tweets.search_id = '1')and (users.location = 'New York City' or users.location = 'Oceanside, NY' or users.location = 'New York' or users.location = 'New York, NY' or users.location = 'New Jersey, USA' or users.location = 'New York, USA' or users.location = 'Bronx, NY' or users.location = 'NYC'));

select avg(followers_count) as 'Avg of followers of ppl with hashtags'
from USERS
where users.id in (
    select tweets.[user]
    from tweets
    where tweets.id in(
        select tweet_id from HASHTAGS));

select avg(followers_count) as 'Avg of followers of ppl with no hashtags'
from USERS
where users.id not in (
    select tweets.[user]
    from tweets
    where tweets.id in(
        select tweet_id from HASHTAGS));

select name
from users, tweets
where users.id = tweets.[user] and followers_count > 10000 and tweets.search_id = '1';

select max(followers_count) as 'Max followers'

SELECT name AS 'Users with more than a 10000 followers'
FROM users
WHERE verified = 0 AND followers_count > 10000;

SELECT COUNT(verified) AS 'Users in Los Angeles'
FROM users
where location = 'Los Angeles' OR location = 'Los Angeles, CA' OR location = 'LOS ANGELES' OR location = 'Los Angeles, California';

SELECT COUNT(tweet_id) AS 'Tweets with #Frozen2'
FROM hashtags
where hashtag = 'Frozen2' OR hashtag = 'Disney';

SELECT name as 'Verified users'
FROM users
WHERE verified = 1 AND users.id IN (
    SELECT user
    FROM tweets
    WHERE tweets.id IN (
        SELECT tweet_id
        FROM hashtags
        WHERE hashtags.hashtag = 'Frozen2' OR hashtags.hashtag = 'Disney'));



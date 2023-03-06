USE ig_clone; 


##############################################################################################################################################
#  1)Create an ER diagram or draw a schema for the given database.
# ERR Diagram 1



# 2)We want to reward the user who has been around the longest, Find the 5 oldest users.
SELECT * FROM users;     ##  id, username, created_at 

SELECT * FROM users 
ORDER BY created_at LIMIT 5;

## ORDER BY is used sort the result set either in ascending or in descending order
## limit : The LIMIT clause is used to specify the number of records to return.


select *from users where created_at 
order by created_at desc limit 5;

# 3)To understand when to run the ad campaign, figure out the day of the week most users register on? 
SELECT * FROM users;        ## id, username, created_at 

SELECT  DAYNAME(created_at) as day, count(*) as total
FROM users
GROUP BY day
ORDER BY total desc;

select dayofweek(created_at) as day,count(*) as total from users
group by day order by total asc;


SELECT DAYNAME(created_at) as day,count(*) as total
FROM users
GROUP BY day
ORDER BY total DESC limit 2;


# 4)To target inactive users in an email ad campaign, find the users who have never posted a photo.
select * from users;    ## id, username, created_at
select * from photos;   ## id, image_url, user_id, created_id

SELECT username FROM users 
left join photos on users.id=photos.user_id
WHERE photos.id is null;


SELECT username, IFNULL(image_url,0) as count FROM users
left join photos on users.id = photos.user_id
WHERE photos.image_url is  NULL;


# 5)Suppose you are running a contest to find out who got the most likes on a photo. Find out who won?
select * from users;     ## id, username, created_at
select * from photos;    ## id, image_url, user_id, created_at
select * from likes;     ## user_id, photo_id, created_at

select username, photos.id, photos.image_url, count(*) as total from likes
join photos on photos.id=likes.photo_id
join users on users.id=likes.photo_id
group by photos.id
order by total desc limit 5;


select username, photos.id,image_url from likes
join photos on photos.id=likes.photo_id
join users on users.id=likes.photo_id
group by photos.id order by username
desc limit 5;



SELECT  users.username, photos.id,photos.image_url,count(*) as total_likes
FROM likes
join photos on photos.id=likes.photo_id
join users on users.id=likes.photo_id
GROUP BY photos.id
ORDER BY total_likes DESC limit 5;


SELECT username, photos.id,photos.image_url,COUNT(*) as total FROM likes
INNER JOIN photos ON likes.photo_id = photos.id
INNER JOIN users ON likes.user_id = users.id
GROUP BY likes.photo_id
ORDER BY total DESC LIMIT 5;

# 6)The investors want to know how many times does the average user post.

## SELECT ROUND((SELECT COUNT(*)FROM photos)/(SELECT COUNT(*) FROM users),2);

#### total number of photos / total number of user


SELECT * FROM users;    ## id, username, created_at 
SELECT * FROM photos;   ## id, image_url, user_id, created_at

SELECT count(photos.image_url)/ count(DISTINCT users.id) as avg
FROM users 
inner join photos on users.id = photos.user_id;


select count(image_url) / count(distinct users.id) as avg from users 
left join photos on users.id=photos.user_id;

SELECT COUNT(photos.image_url)/COUNT(DISTINCT users.id) as avg_photos
FROM users 
left join photos on users.id = photos.user_id;


# 7)A brand wants to know which hashtag to use on a post, and find the top 5 most used hashtags.

SELECT * FROM tags;    ## id, tag_name, created_at 
SELECT * FROM photo_tags;   ## photo_id, tag_id

SELECT tags.tag_name, count (tag_id) as total FROM photo_tags
JOIN tags on photo_tags.tag_id = tags.id
GROUP BY tags.id
ORDER BY total DESC LIMIT 5;

SELECT tag_name,tag_id as total FROM photo_tags
inner join tags on photo_tags.tag_id = tags.id
GROUP BY tags.id
ORDER BY total DESC LIMIT 5;



# 8)To find out if there are bots, find users who have liked every single photo on the site.
select * from users;    ## id, username, created_at 
select * from photos;   ## id, image_url, user_id, created_at
select * from likes;    ## user_id, photo_id, created_at

SELECT users.username,COUNT(*) as liked FROM users
INNER JOIN likes on likes.user_id = users.id
GROUP BY likes.user_id 
HAVING liked in (SELECT COUNT(*) FROM photos);


SELECT username, count(id) as liked FROM users
inner join likes on likes.user_id = users.id
GROUP BY likes.user_id 
order by liked desc;

# 9)To know who the celebrities are, find users who have never commented on a photo.
select * from users;       ## id,user_name,created_at
select * from comments;    ## id,comment_text, photo_id,user_id, created_at
select * from photos;      ## id, image_url, user_id, created_at

###  /*We also have a problem with celebrities
### Find users who have never commented on a photo*/


SELECT username,comment_text FROM users
left join comments on users.id = comments.user_id
GROUP BY users.id 
HAVING comment_text is null;

SELECT username,comment_text FROM users
     join comments on users.id = comments.user_id
GROUP BY users.id 
HAVING comment_text is null;

SELECT username,comment_text FROM users
LEFT JOIN comments ON users.id = comments.user_id
GROUP BY users.id
HAVING comment_text IS NOT NULL;

# 10)Now it's time to find both of them together, find the users who have never commented on any photo or have commented on every photo

SELECT tableA.total_A AS 'Number Of Users who never commented',
		(tableA.total_A/(SELECT COUNT(*) FROM users))*100 AS '%',
		tableB.total_B AS 'Number of Users who commented on photos',
		(tableB.total_B/(SELECT COUNT(*) FROM users))*100 AS '%'
FROM( SELECT COUNT(*) AS total_A FROM
	(SELECT username,comment_text FROM users
	LEFT JOIN comments ON users.id = comments.user_id
	GROUP BY users.id
	HAVING comment_text IS NULL) AS total_number_of_users_without_comments) AS tableA
	JOIN(   SELECT COUNT(*) AS total_B FROM
			(SELECT username,comment_text FROM users
				LEFT JOIN comments ON users.id = comments.user_id
				GROUP BY users.id
				HAVING comment_text IS NOT NULL) AS total_number_users_with_comments)AS tableB
    
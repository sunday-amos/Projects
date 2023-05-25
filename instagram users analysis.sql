-- Find the 5 oldest users
SELECT
    id,
    username,
    created_at
FROM
    users
ORDER BY
    created_at
LIMIT 5;

-- What day of the week do most users register on? We need to figure out when to schedule an ad campgain

SELECT  DAYNAME(created_at) day_of_the_week, count(username) total_registration
from users
group by day_of_the_week
ORDER by total_registration DESC;

-- We want to target our inactive users with an email campaign. Find the users who have never posted a photo.

select users.username
from users left join photos
on users.id = photos.user_id
where image_url is Null;

-- We're running a new contest to see who can get the most likes on a single photo. WHO WON?

SELECT "Arely_Bogan63" as username, photo_id, image_url, count(*) as total_likes
from likes join photos
on likes.photo_id = photos.id
Join users on photos.user_id = users.id
group by username, photo_id,image_url
order by total_likes DESC
limit 1;

-- Our Investors want to know...How many times does the average user post? (total number of photos/total number of users)
SELECT
    ROUND(
        (
    SELECT
        COUNT(*)
    FROM
        photos
    ) /(
SELECT
    COUNT(*)
FROM
    users
),
2
    );
    -- user ranking by postings higher to lower
SELECT
    username,
    COUNT(photos.image_url)
FROM
    users
JOIN photos ON users.id = photos.user_id
GROUP BY
    username
ORDER BY
    COUNT(photos.image_url)
DESC
    ;
    
 -- We have a small problem with bots on our site. Find users who have liked every single photo on the site
SELECT
    users.id,
    users.username,
    COUNT(likes.photo_id) AS total_likes_by_user
FROM
    users
JOIN likes ON likes.user_id = users.id
WHERE
    users.username = 0
GROUP BY
    users.username, users.id
HAVING
    COUNT(DISTINCT likes.photo_id) =(
SELECT
    COUNT(*)
FROM
    photos
)
ORDER BY
    total_likes_by_user;
    
    -- Total Posts by users (longer version of SELECT COUNT(*)FROM photos)
SELECT
    COUNT(
        user_posts.total_posts_per_user
    )
FROM
    (
    SELECT
        username,
        photos.id AS total_posts_per_user
    FROM
        users
    JOIN photos ON users.id = photos.user_id
) user_posts;

-- Total numbers of users who have posted at least one time
SELECT
    COUNT(DISTINCT(user_id)) AS total_users_with_posts
FROM
    photos;

-- A brand wants to know which hashtags to use in a post. What are the top 5 most commonly used hashtags?
SELECT
    tag.tag_name,
    COUNT(*) AS tag_count
FROM
    photo_tags AS pt
JOIN tags AS tag
ON
    pt.tag_id = tag.id
WHERE
    tag.tag_name IS NOT NULL AND tag.tag_name != ''
GROUP BY
    tag.tag_name
ORDER BY
    tag_count
DESC
    ;

    -- We also have a problem with celebrities. Find users who have never commented on a photo
SELECT
    users.username,
    comments.comment_text
FROM
    users
LEFT JOIN comments ON users.id = comments.user_id
WHERE
    comments.id IS NULL;
    
    -- Are we overrun with bots and celebrity accounts? Find the percentage of our users who have either never commented on a photo or have commented on every photo
SELECT
    tableA.total_A AS 'Number Of Users who never commented',
    (
        tableA.total_A /(
    SELECT
        COUNT(*)
    FROM
        users
    )
    ) * 100 AS '%',
    tableB.total_B AS 'Number of Users who likes every photos',
    (
        tableB.total_B /(
    SELECT
        COUNT(*)
    FROM
        users
    )
    ) * 100 AS '%'
FROM
    (
    SELECT
        COUNT(*) AS total_A
    FROM
        (
        SELECT
            username,
            comment_text
        FROM
            users
        LEFT JOIN comments ON users.id = comments.user_id
        GROUP BY
            users.id, username, comment_text
        HAVING
            comment_text IS NULL
    ) AS total_number_of_users_without_comments
) AS tableA
JOIN(
    SELECT COUNT(*) AS total_B
    FROM
        (
        SELECT
            users.id,
            username,
            COUNT(users.id) AS total_likes_by_user
        FROM
            users
        JOIN likes ON users.id = likes.user_id
        GROUP BY
            users.id, username
        HAVING
            total_likes_by_user =(
        SELECT
            COUNT(*)
        FROM
            photos
        )
    ) AS total_number_users_likes_every_photos
) AS tableB;
-- Find users who have ever commented on a photo
SELECT
    username,
    comment_text
FROM
    users
LEFT JOIN comments ON users.id = comments.user_id
GROUP BY
    users.id, username, comment_text
HAVING
    comment_text IS NOT NULL;

-- Are we overrun with bots and celebrity accounts? Find the percentage of our users who have either never commented on a photo or have commented on photos before.
SELECT
    COUNT(
        DISTINCT CASE WHEN comments.id IS NULL THEN users.id
    END
) AS users_without_comments,
COUNT(
    DISTINCT CASE WHEN comments.id IS NOT NULL THEN users.id
END
) AS users_with_comments,
ROUND(
    COUNT(
        DISTINCT CASE WHEN comments.id IS NOT NULL THEN users.id
    END
) / COUNT(DISTINCT users.id) * 100,
4
) AS percentage_of_users_with_comments
FROM
    users
LEFT JOIN comments ON users.id = comments.user_id;
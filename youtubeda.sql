--top 5 Which keywords are associated with the highest-performing videos?--
SELECT 
    vs.Keyword,
    SUM(c.Likes) AS total_comment_likes
FROM videos_stats vs
JOIN comments c ON vs.Video_id = c.Video_id
GROUP BY vs.Keyword
ORDER BY total_comment_likes DESC
LIMIT 5;

--top 5 keywords by views--
SELECT 
    vs.Video_id,
    vs.Keyword,
    vs.Views,
    vs.Likes
FROM videos_stats vs
ORDER BY vs.Views DESC
LIMIT 5;

--query for average sentiment--
SELECT 
    vs.Video_id,
    vs.Keyword,
    vs.Views,
    vs.Likes,
    vs.Comments,
    AVG(c.Sentiment) AS avg_sentiment
FROM videos_stats vs
JOIN comments c ON vs.Video_id = c.Video_id
GROUP BY vs.Video_id, vs.Keyword, vs.Views, vs.Likes, vs.Comments
ORDER BY vs.Views DESC;

--classifying and counting sentiments per video --
SELECT 
    vs.Video_id,
    vs.Views,
    vs.Likes,
    vs.Comments AS video_comment_count,
    COUNT(c.Comment) AS actual_comments,
    SUM(CASE WHEN c.Sentiment = 0 THEN 1 ELSE 0 END) AS negative_comments,
    SUM(CASE WHEN c.Sentiment = 1 THEN 1 ELSE 0 END) AS neutral_comments,
    SUM(CASE WHEN c.Sentiment = 2 THEN 1 ELSE 0 END) AS positive_comments
FROM videos_stats vs
JOIN comments c ON vs.Video_id = c.Video_id
GROUP BY vs.Video_id
ORDER BY actual_comments DESC;

--Which videos have the most liked comments, and what is the sentiment of those top comments?--
SELECT 
    c.Video_id,
    c.Comment,
    c.Likes AS comment_likes,
    c.Sentiment,
    vs.Views,
    vs.Likes AS video_likes,
    vs.Comments AS video_comment_count,
    vs.Keyword
FROM comments c
JOIN (
    -- Subquery to find max comment likes per video
    SELECT Video_id, MAX(Likes) AS max_likes
    FROM comments
    GROUP BY Video_id
) top_comments
ON c.Video_id = top_comments.Video_id AND c.Likes = top_comments.max_likes
JOIN videos_stats vs
ON c.Video_id = vs.Video_id
ORDER BY comment_likes DESC;

-- What proportion of videos have disabled comments or hidden like counts?--
SELECT 
  COUNT(*) AS total_videos,
  SUM(CASE WHEN Comments = 0 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS pct_comments_disabled,
  SUM(CASE WHEN Likes = 0 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS pct_likes_hidden
FROM videos_stats;

-- Are there keywords that consistently result in higher comment sentiment or more liked comments?--
SELECT 
    vs.Keyword,
    COUNT(DISTINCT c.Video_id) AS video_count,
    AVG(c.Sentiment) AS avg_sentiment,
    AVG(c.Likes) AS avg_comment_likes
FROM videos_stats vs
JOIN comments c ON vs.Video_id = c.Video_id
GROUP BY vs.Keyword
HAVING video_count >= 3 
ORDER BY avg_sentiment DESC;

-- How does the publication date relate to performance? -- 
SELECT 
    SUBSTR(Published_at, 1, 7) AS publish_month,  
    COUNT(*) AS video_count,
    AVG(Views) AS avg_views,
    AVG(Likes) AS avg_likes,
    AVG(Comments) AS avg_comments
FROM videos_stats
GROUP BY publish_month
ORDER BY publish_month;









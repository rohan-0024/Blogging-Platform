-- Step 1: Create Database
SET SQL_SAFE_UPDATES = 1;
SET SQL_SAFE_UPDATES = 0;


CREATE DATABASE BloggingPlatform;
USE BloggingPlatform;    

-- Step 2: Create Tables

-- Admin Table

CREATE TABLE Admin (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email LIKE '%@%.%'),
    role ENUM('Super Admin', 'Moderator', 'Editor') NOT NULL
);
INSERT INTO Admin (email, role) VALUES 
('admin1@blog.com', 'Super Admin'),
('admin2@blog.com', 'Moderator');
insert into Admin (email,role) VALUES ('admin3@blog.com', 'Editor');
INSERT INTO Admin (email, role) VALUES 
('admin4@blog.com', 'Super Admin'),
('admin5@blog.com', 'Moderator');

delete from Admin where role = 'Editor';
select * from Admin;

-- Members Table
CREATE TABLE Members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    member_name VARCHAR(255) NOT NULL ,
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email LIKE '%@%.%'),
    doj DATE NOT NULL
);

DELIMITER //

CREATE TRIGGER check_doj_before_insert
BEFORE INSERT ON Members
FOR EACH ROW
BEGIN
    IF NEW.doj > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Date of Joining cannot be in the future';
    END IF;
END;
//

DELIMITER ;

INSERT INTO Members (member_name, email, doj) VALUES 
('Alice Johnson', 'alice@example.com', '2023-01-15'),
('Bob Smith', 'bob@example.com', '2025-02-20'),
('Jake Smith', 'jake2345@example.com', '2020-06-21');
INSERT INTO Members (member_name, email, doj) VALUES 
('Will Smith', 'wil1256@example.com', '2021-08-29');
INSERT INTO Members (member_name, email, doj) VALUES 
('Charlie Brown', 'charlie@example.com', '2022-07-19');

SELECT *from Members;


-- Blogs Table
CREATE TABLE Blog (
    blog_id INT PRIMARY KEY AUTO_INCREMENT,
    author_id INT,
    title VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES Members(member_id) ON DELETE CASCADE
);
DELIMITER //

CREATE TRIGGER check_title_lengths
BEFORE INSERT ON Blog
FOR EACH ROW
BEGIN
    IF CHAR_LENGTH(NEW.title) < 5 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Title must be at least 5 characters long';
    END IF;
END;

//

DELIMITER ;


INSERT INTO Blog (author_id, title) VALUES 
(12, 'The Future of AI'),
(13, 'Exploring Quantum Computing');
INSERT INTO Blog (author_id, title) VALUES 
(14, 'The Evolution of Cybersecurity'),
(15, 'Blockchain Beyond Cryptocurrency'),
(15, 'The Rise of Quantum Computing');


INSERT INTO Blog (author_id, title) VALUES (16, 'xyz');
delete from Blog where title = 'xyz';
SELECT *from Blog;


-- Categories Table
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);
INSERT INTO Categories (name) VALUES 
('Technology'),
('Science'),
('Lifestyle');
INSERT INTO Categories (name) VALUES 
('Education'),
('Finance');
SELECT *from Categories;

-- Drafts Table
CREATE TABLE Drafts (
    draft_id INT PRIMARY KEY AUTO_INCREMENT,
    author_id INT,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES Members(member_id) ON DELETE CASCADE
);
INSERT INTO Drafts (author_id) VALUES 
(12), 
(13);
INSERT INTO Drafts (author_id) VALUES 
(14);
SELECT *from Drafts;

-- Views Table
CREATE TABLE Views (
    view_id INT PRIMARY KEY AUTO_INCREMENT,
    blog_id INT,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (blog_id) REFERENCES Blogs(blog_id) ON DELETE CASCADE
);
INSERT INTO Views (blog_id) VALUES 
(6), 
(7);
SELECT *from Views;

-- Feedback Table
CREATE TABLE Feedback (
    feedback_id INT PRIMARY KEY AUTO_INCREMENT,
    blog_id INT,
    member_id INT,
    FOREIGN KEY (blog_id) REFERENCES Blogs(blog_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE
);
INSERT INTO Feedback (blog_id, member_id) VALUES 
(6, 12), 
(7, 13);
delete from Feedback;
SELECT *from Feedback;

-- Reactions Table
CREATE TABLE Reactions (
    reaction_id INT PRIMARY KEY AUTO_INCREMENT,
    blog_id INT,
    member_id INT,
    FOREIGN KEY (blog_id) REFERENCES Blogs(blog_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE
);
INSERT INTO Reactions (blog_id, member_id) VALUES 
(6, 12), 
(7, 13);
delete from Feedback;
SELECT *from Reactions;

-- Reports Table
CREATE TABLE Reports (
    report_id INT PRIMARY KEY AUTO_INCREMENT,
    blog_id INT,
    reason TEXT NOT NULL check (CHAR_LENGTH(reason) >= 10),
    status ENUM('Pending', 'Resolved') DEFAULT 'Pending',
    FOREIGN KEY (blog_id) REFERENCES Blogs(blog_id) ON DELETE CASCADE
);
INSERT INTO Reports (blog_id, reason, status) 
VALUES (6, 'This blog contains misleading information.', 'Pending');
INSERT INTO Reports (blog_id, reason, status) 
VALUES (7, 'The blog violates community guidelines.', 'Pending');

select *from Reports;

-- Announcements Table
CREATE TABLE Announcements (
    announcement_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    expires_at DATE CHECK (expires_at >= CURDATE()) ,
    created_by INT,
    FOREIGN KEY (created_by) REFERENCES Admin(admin_id) ON DELETE SET NULL
);
INSERT INTO Announcements (title, expires_at, created_by) VALUES 
('Platform Maintenance', '2025-05-01', 1);
INSERT INTO Announcements (title, expires_at, created_by) VALUES 
('Policy Change', '2024-02-21', 2);

SELECT *from Announcements;


-- Media Table
CREATE TABLE Media (
    blog_id INT,
    media_type ENUM('Image', 'Video', 'Audio') NOT NULL,
    FOREIGN KEY (blog_id) REFERENCES Blogs(blog_id) ON DELETE CASCADE
);
INSERT INTO Media (blog_id, media_type) VALUES 
(6, 'Image'), 
(7, 'Video');
select * from Media;

-- Themes Table
CREATE TABLE Theme (
	blog_id INT,
    name VARCHAR(20),
    FOREIGN KEY (blog_id) REFERENCES Blogs(blog_id) ON DELETE CASCADE
);

INSERT INTO Theme (blog_id, name) VALUES 
(6, 'Futuristic'), 
(7, 'Innovative');
select *from Theme;

-- Polls Table
CREATE TABLE Polls (
    blog_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at DATE NOT NULL,
    FOREIGN KEY (blog_id) REFERENCES Blogs(blog_id) ON DELETE CASCADE
);
INSERT INTO Polls (blog_id, expires_at) VALUES 
(6, '2025-06-10');
select * from Polls;

-- Labels Table
CREATE TABLE Labels (
    label_id INT PRIMARY KEY AUTO_INCREMENT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO Labels () VALUES 
(), 
();
select * from Labels;

-- Bookmarks Table
CREATE TABLE Bookmarks (
    bookmark_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    blog_id INT,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (blog_id) REFERENCES Blogs(blog_id) ON DELETE CASCADE
);
INSERT INTO Bookmarks (member_id, blog_id) VALUES 
(12, 6), 
(13, 7);
SELECT * FROM Bookmarks;

-- Step 3: Create Relationship Tables

-- Relationship: Members <-> Categories (Members can choose multiple categories)
CREATE TABLE Choice (
    member_id INT,
    category_id INT,
    assigned_date DATE NOT NULL,  -- Non-primary key column
    PRIMARY KEY (member_id, category_id),
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE CASCADE
);

INSERT INTO Choice (member_id, category_id,assigned_date) VALUES 
(12, 1,'2023-02-13'), 
(13, 2,'2021-01-28');
SELECT *from Choice;


-- Relationship: Blogs <-> Categories (A blog can belong to multiple categories)
CREATE TABLE BlogCategories (
    blog_id INT,
    category_id INT,
    assigned_by VARCHAR(100) NOT NULL,  -- non-primary key column
    PRIMARY KEY (blog_id, category_id),
    FOREIGN KEY (blog_id) REFERENCES Blogs(blog_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE CASCADE
);

INSERT INTO BlogCategories (blog_id, category_id,assigned_by) 
VALUES (6, 1, 'Admin');
INSERT INTO BlogCategories (blog_id, category_id,assigned_by) 
VALUES (7, 2,'Editor');
select * from BlogCategories;

-- Blogs <-> Themes (Each blog can have multiple themes)
CREATE TABLE Design (
    blog_id INT,
    theme_name VARCHAR(100),
    applied_date DATE NOT NULL,  -- Non-primary key column
    PRIMARY KEY (blog_id, theme_name),
    FOREIGN KEY (blog_id) REFERENCES Blogs(blog_id) ON DELETE CASCADE
);

INSERT INTO Design (blog_id, theme_name, applied_date) 
VALUES (6, 'Futuristic', '2021-05-06');
INSERT INTO Design (blog_id, theme_name, applied_date) 
VALUES (7, 'Innovative', '2024-03-07');

select *from Design;



-- Relationship: Admin <-> Reports (Admin resolves reports)
CREATE TABLE Resolve (
    admin_id INT,
    report_id INT,
    resolved_date DATE NOT NULL,  -- Non-primary key column
    PRIMARY KEY (admin_id, report_id),
    FOREIGN KEY (admin_id) REFERENCES Admin(admin_id) ON DELETE CASCADE,
    FOREIGN KEY (report_id) REFERENCES Reports(report_id) ON DELETE CASCADE
);

INSERT INTO Resolve (admin_id, report_id, resolved_date) 
VALUES (1, 2, '2024-05-06');
INSERT INTO Resolve (admin_id, report_id, resolved_date) 
VALUES (2, 3, '2024-11-18');
select * from Resolve;




-- Relationship: Admin <-> Announcements (Admin makes announcements)
CREATE TABLE Announces (
    admin_id INT,
    announcement_id INT,
    announcement_type VARCHAR(50) NOT NULL,  -- non-primary key column
    PRIMARY KEY (admin_id, announcement_id),
    FOREIGN KEY (admin_id) REFERENCES Admin(admin_id) ON DELETE CASCADE,
    FOREIGN KEY (announcement_id) REFERENCES Announcements(announcement_id) ON DELETE CASCADE
);
INSERT INTO Announces (admin_id, announcement_id,announcement_type) 
VALUES (1, 1,'System Update');
INSERT INTO Announces (admin_id, announcement_id,announcement_type) 
VALUES (2, 2,'Policy Change');
select *from Announces;

create table Student ( 
	student_id varchar(20) PRIMARY KEY); 
insert into Student (student_id)
values ('RA1005'),('1234');
SELECT * from Student;

-- Get blog statistics with author information and engagement metrics
SELECT 
    b.blog_id,
    b.title,
    m.member_name AS author,
    COUNT(DISTINCT v.view_id) AS view_count,
    COUNT(DISTINCT r.reaction_id) AS reaction_count,
    COUNT(DISTINCT f.feedback_id) AS feedback_count,
    GROUP_CONCAT(DISTINCT c.name SEPARATOR ', ') AS categories
FROM 
    Blog b
JOIN 
    Members m ON b.author_id = m.member_id
LEFT JOIN 
    Views v ON b.blog_id = v.blog_id
LEFT JOIN 
    Reactions r ON b.blog_id = r.blog_id
LEFT JOIN 
    Feedback f ON b.blog_id = f.blog_id
LEFT JOIN 
    BlogCategories bc ON b.blog_id = bc.blog_id
LEFT JOIN 
    Categories c ON bc.category_id = c.category_id
GROUP BY 
    b.blog_id, b.title, m.member_name
ORDER BY 
    view_count DESC;

-- Find members who have both created blogs and bookmarked other blogs    
SELECT 
    m.member_id,
    m.member_name,
    m.email,
    COUNT(DISTINCT b.blog_id) AS blogs_created,
    COUNT(DISTINCT bk.blog_id) AS blogs_bookmarked
FROM 
    Members m
JOIN 
    Blog b ON m.member_id = b.author_id
JOIN 
    Bookmarks bk ON m.member_id = bk.member_id
WHERE 
    b.blog_id NOT IN (
        SELECT blog_id 
        FROM Bookmarks 
        WHERE member_id = m.member_id
    )
GROUP BY 
    m.member_id, m.member_name, m.email
HAVING 
    COUNT(DISTINCT b.blog_id) > 0 
    AND COUNT(DISTINCT bk.blog_id) > 0;
    
-- Create a comprehensive blog analytics view    
CREATE VIEW Blog_Analytics AS
SELECT 
    b.blog_id,
    b.title,
    m.member_name AS author,
    b.created_at,
    (SELECT COUNT(*) FROM Views v WHERE v.blog_id = b.blog_id) AS views,
    (SELECT COUNT(*) FROM Reactions r WHERE r.blog_id = b.blog_id) AS reactions,
    (SELECT COUNT(*) FROM Feedback f WHERE f.blog_id = b.blog_id) AS feedbacks,
    (SELECT COUNT(*) FROM Reports rep WHERE rep.blog_id = b.blog_id AND rep.status = 'Pending') AS pending_reports,
    (SELECT GROUP_CONCAT(c.name SEPARATOR ', ') 
     FROM BlogCategories bc 
     JOIN Categories c ON bc.category_id = c.category_id 
     WHERE bc.blog_id = b.blog_id) AS categories,
    (SELECT GROUP_CONCAT(t.name SEPARATOR ', ') 
     FROM Theme t 
     WHERE t.blog_id = b.blog_id) AS themes
FROM 
    Blog b
JOIN 
    Members m ON b.author_id = m.member_id;

SELECT * from Blog_Analytics;

-- Trigger to prevent deletion of popular blogs (with more than 100 views)
DELIMITER //
CREATE TRIGGER prevent_popular_blog_deletion
BEFORE DELETE ON Blog
FOR EACH ROW
BEGIN
    DECLARE view_count INT;
    
    SELECT COUNT(*) INTO view_count
    FROM Views
    WHERE blog_id = OLD.blog_id;
    
    IF view_count > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete blog with more than 100 views';
    END IF;
END//
DELIMITER ;

-- Stored procedure using cursor to expire old announcements
DELIMITER //
CREATE PROCEDURE expire_old_announcements()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE a_id INT;
    DECLARE a_title VARCHAR(255);
    DECLARE a_expires DATE;
    
    DECLARE announcement_cursor CURSOR FOR
        SELECT announcement_id, title, expires_at
        FROM Announcements
        WHERE expires_at < CURDATE();
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN announcement_cursor;
	read_loop: LOOP
        FETCH announcement_cursor INTO a_id, a_title, a_expires;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Log expired announcements
        INSERT INTO ExpiredAnnouncementsLog 
        (announcement_id, title, original_expiry, expired_on)
        VALUES (a_id, a_title, a_expires, CURDATE());
        
        -- Delete expired announcement
        DELETE FROM Announcements WHERE announcement_id = a_id;
    END LOOP;
    
    CLOSE announcement_cursor;
END//
DELIMITER ;

-- Find blogs that violate content guidelines (using CASE for complex condition)
SELECT 
    b.blog_id,
    b.title,
    m.member_name AS author,
    CASE 
        WHEN (SELECT COUNT(*) FROM Reports r WHERE r.blog_id = b.blog_id) > 3 THEN 'Multiple Reports'
        WHEN (SELECT COUNT(*) FROM Feedback f WHERE f.blog_id = b.blog_id) = 0 THEN 'No Engagement'
        WHEN (SELECT COUNT(*) FROM Views v WHERE v.blog_id = b.blog_id) < 
             (SELECT AVG(view_count) FROM (SELECT COUNT(*) AS view_count FROM Views GROUP BY blog_id) AS vc) THEN 'Low Visibility'
        ELSE 'OK'
    END AS status
FROM 
    Blog b
JOIN 
    Members m ON b.author_id = m.member_id
WHERE 
    CASE 
        WHEN (SELECT COUNT(*) FROM Reports r WHERE r.blog_id = b.blog_id) > 3 THEN 1
        WHEN (SELECT COUNT(*) FROM Feedback f WHERE f.blog_id = b.blog_id) = 0 THEN 1
        WHEN (SELECT COUNT(*) FROM Views v WHERE v.blog_id = b.blog_id) < 
             (SELECT AVG(view_count) FROM (SELECT COUNT(*) AS view_count FROM Views GROUP BY blog_id) AS vc) THEN 1
        ELSE 0
    END = 1;
    
-- Find members with invalid future join dates (violating the DOJ constraint)
SELECT member_id, member_name, email, doj
FROM Members
WHERE doj > CURDATE();

-- Find blogs with titles that are too short (violating title length constraint)
SELECT blog_id, title, CHAR_LENGTH(title) AS title_length
FROM Blog
WHERE CHAR_LENGTH(title) < 5;

-- Find reports with reasons shorter than 10 characters (violating reason length constraint)
SELECT r.report_id, r.reason, CHAR_LENGTH(r.reason) AS reason_length, b.title
FROM Reports r
JOIN Blog b ON r.blog_id = b.blog_id
WHERE CHAR_LENGTH(r.reason) < 10;

CREATE TABLE blog_audit_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    blog_id INT NOT NULL,
    old_title VARCHAR(255),
    new_title VARCHAR(255),
    changed_by VARCHAR(50) ,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(10) NOT NULL
);

DELIMITER //
CREATE TRIGGER blog_title_change_trigger
BEFORE UPDATE ON Blog
FOR EACH ROW
BEGIN
    -- Validate title length
    IF CHAR_LENGTH(NEW.title) < 5 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Blog title must be at least 5 characters long';
    END IF;
    
    -- Log changes if title was modified
    IF NEW.title != OLD.title THEN
        INSERT INTO blog_audit_log (blog_id, old_title, new_title, action)
        VALUES (NEW.blog_id, OLD.title, NEW.title, 'UPDATE');
    END IF;
END//
DELIMITER ;

UPDATE Blog SET title = 'AI' WHERE blog_id = 1;

UPDATE Blog SET title = 'Future of AI' WHERE blog_id = 1;
SELECT * FROM blog_audit_log;


-- Create procedure with cursor
DELIMITER //
CREATE PROCEDURE generate_blog_report()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_blog_id INT;
    DECLARE v_title VARCHAR(255);
    DECLARE v_views INT;
    
    -- Declare cursor for blogs with their view counts
    DECLARE blog_cursor CURSOR FOR
        SELECT b.blog_id, b.title, COUNT(v.view_id) AS view_count
        FROM Blog b
        LEFT JOIN Views v ON b.blog_id = v.blog_id
        GROUP BY b.blog_id, b.title;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Create temporary table for results
    DROP TEMPORARY TABLE IF EXISTS temp_blog_report;
    CREATE TEMPORARY TABLE temp_blog_report (
        blog_id INT,
        title VARCHAR(255),
        view_count INT,
        popularity VARCHAR(20)
    );
    
    OPEN blog_cursor;
    
    read_loop: LOOP
        FETCH blog_cursor INTO v_blog_id, v_title, v_views;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Determine popularity based on views
        SET @popularity = CASE
            WHEN v_views > 100 THEN 'Very Popular'
            WHEN v_views > 50 THEN 'Popular'
            WHEN v_views > 10 THEN 'Average'
            ELSE 'Low Traffic'
        END;
        
        -- Insert into temp table
        INSERT INTO temp_blog_report
        VALUES (v_blog_id, v_title, v_views, @popularity);
    END LOOP;
    
    CLOSE blog_cursor;
    
    -- Return the results
    SELECT * FROM temp_blog_report ORDER BY view_count DESC;
END//
DELIMITER ;

-- Execute the procedure
CALL generate_blog_report();



-- Add constraints to Reports table
ALTER TABLE Reports
ADD CONSTRAINT chk_report_reason_length 
CHECK (CHAR_LENGTH(reason) >= 10),
ADD CONSTRAINT chk_not_own_blog
CHECK (blog_id NOT IN (
    SELECT blog_id FROM Blog WHERE author_id = member_id
));

-- Create trigger for additional validation
DELIMITER //
CREATE TRIGGER check_report_limit
BEFORE INSERT ON Reports
FOR EACH ROW
BEGIN
    DECLARE report_count INT;
    
    -- Check if member has already reported this blog 3 times
    SELECT COUNT(*) INTO report_count
    FROM Reports
    WHERE blog_id = NEW.blog_id AND member_id = NEW.member_id;
    
    IF report_count >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You have already reported this blog the maximum allowed times (3)';
    END IF;
END//
DELIMITER ;

-- Test the constraints
-- Attempt 1: Valid report
INSERT INTO Reports (blog_id, member_id, reason, status)
VALUES (1, 2, 'This blog contains inaccurate information', 'Pending');
-- Output: 1 row affected

-- Attempt 2: Short reason (violates CHECK constraint)
INSERT INTO Reports (blog_id, member_id, reason, status)
VALUES (1, 2, 'Bad post', 'Pending');
-- Output: Error Code: 3819. Check constraint 'chk_report_reason_length' is violated.

-- Attempt 3: Author reporting own blog (violates CHECK constraint)
INSERT INTO Reports (blog_id, member_id, reason, status)
VALUES (1, 12, 'Testing my own blog', 'Pending');
-- Output: Error Code: 3819. Check constraint 'chk_not_own_blog' is violated.

-- Attempt 4: Same member reporting same blog 4th time
INSERT INTO Reports (blog_id, member_id, reason, status)
VALUES (1, 2, 'Duplicate content issue', 'Pending'); -- 2nd
INSERT INTO Reports (blog_id, member_id, reason, status)
VALUES (1, 2, 'Spam content problem', 'Pending'); -- 3rd
INSERT INTO Reports (blog_id, member_id, reason, status)
VALUES (1, 2, 'Another reason to report', 'Pending'); -- 4th
-- Output: Error Code: 1644. You have already reported this blog the maximum allowed times (3)

-- Verify reports
SELECT * FROM Reports;
-- Sample Output:
-- | report_id | blog_id | member_id | reason                              | status  |
-- |-----------|---------|-----------|-------------------------------------|---------|
-- | 1         | 1       | 2         | This blog contains inaccurate info  | Pending |
-- | 2         | 1       | 2         | Duplicate content issue             | Pending |
-- | 3         | 1       | 2         | Spam content problem                | Pending |




-- Theme Table Normalization (3NF)
CREATE TABLE ThemeList (
    theme_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL
);

-- Inserting unique themes
INSERT INTO ThemeList (name)
VALUES 
  ('Tech'),
  ('Health & Wellness'),
  ('Travel'),
  ('Education'),
  ('Productivity');
  select *from themelist;
  

CREATE TABLE BlogTheme (
    blog_id INT,
    theme_id INT,
    applied_date DATE,
    PRIMARY KEY (blog_id, theme_id),
    FOREIGN KEY (blog_id) REFERENCES Blog(blog_id) ON DELETE CASCADE,
    FOREIGN KEY (theme_id) REFERENCES ThemeList(theme_id) ON DELETE CASCADE
);

-- Assigning 'Tech' theme to blog_id = 101
INSERT INTO BlogTheme (blog_id, theme_id, applied_date)
VALUES (
  1,
  (SELECT theme_id FROM ThemeList WHERE name = 'Tech'),
  CURDATE()
);

-- Assigning 'Travel' theme to blog_id = 102
INSERT INTO BlogTheme (blog_id, theme_id, applied_date)
VALUES (
  2,
  (SELECT theme_id FROM ThemeList WHERE name = 'Travel'),
  '2025-04-10'
);
select *from BlogTheme;

-- Category name moved to lookup table
CREATE TABLE CategoryList (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL
);

INSERT INTO CategoryList (name) VALUES 
('Technology'),
('Science');

SELECT * FROM CategoryList;

-- Many-to-many link
CREATE TABLE BlogCategory (
    blog_id INT,
    category_id INT,
    assigned_by VARCHAR(100) NOT NULL,
    PRIMARY KEY (blog_id, category_id),
    FOREIGN KEY (blog_id) REFERENCES Blog(blog_id),
    FOREIGN KEY (category_id) REFERENCES CategoryList(category_id)
);
INSERT INTO BlogCategory (blog_id, category_id, assigned_by) VALUES
(6, 1, 'Admin'),
(4, 2, 'Editor');

SELECT * FROM BlogCategory;



CREATE TABLE MediaType (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) UNIQUE NOT NULL
);
INSERT INTO MediaType (type_name) VALUES 
('Image'),
('Video');

SELECT * FROM MediaType;

CREATE TABLE BlogMedia (
    blog_id INT,
    type_id INT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (blog_id, type_id),
    FOREIGN KEY (blog_id) REFERENCES Blog(blog_id),
    FOREIGN KEY (type_id) REFERENCES MediaType(type_id)
);
INSERT INTO BlogMedia (blog_id, type_id, uploaded_at) VALUES
(6, 1, '2025-04-10'),
(2, 2, '2025-04-12');

SELECT * FROM BlogMedia;

select * from blog;
CREATE TABLE ReactionTypes (
    reaction_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) UNIQUE NOT NULL
);
INSERT INTO ReactionTypes (type_name) VALUES 
('Like'),
('Love');

SELECT * FROM ReactionTypes;

CREATE TABLE Reactions (
    reaction_id INT PRIMARY KEY AUTO_INCREMENT,
    blog_id INT,
    member_id INT,
    reaction_type_id INT,
    reacted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (blog_id) REFERENCES Blog(blog_id),
    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    FOREIGN KEY (reaction_type_id) REFERENCES ReactionTypes(reaction_type_id)
);
INSERT INTO Reactions (reaction_id, blog_id, member_id, reaction_type_id, reacted_at) VALUES
(1, 1, 12, 1, '2025-04-14'),
(2, 5, 13, 2, '2025-04-15');

SELECT * FROM Reactions;


CREATE TABLE ReportStatus (
    status_id INT PRIMARY KEY AUTO_INCREMENT,
    status_name VARCHAR(20) UNIQUE
);
INSERT INTO ReportStatus (status_name) VALUES 
('Pending'),
('Resolved');
INSERT INTO ReportStatus (status_name) VALUES 
('Analyzing');


SELECT * FROM ReportStatus;

CREATE TABLE ReportReasons (
    reason_id INT PRIMARY KEY AUTO_INCREMENT,
    reason_text TEXT NOT NULL
);
INSERT INTO ReportReasons (reason_text) VALUES 
('Misleading content'),
('Violates guidelines');

INSERT INTO ReportReasons (reason_text) VALUES 
('Violating content ethics');
CREATE TABLE Reports (
    report_id INT PRIMARY KEY AUTO_INCREMENT,
    blog_id INT,
    reason_id INT,
    status_id INT,
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (blog_id) REFERENCES Blog(blog_id),
    FOREIGN KEY (reason_id) REFERENCES ReportReasons(reason_id),
    FOREIGN KEY (status_id) REFERENCES ReportStatus(status_id)
);
INSERT INTO Reports (report_id, blog_id, reason_id, status_id, reported_at) VALUES
(1, 6, 1, 1, '2025-04-14'),
(2, 4, 2, 1, '2025-04-15');

INSERT INTO Reports (report_id, blog_id, reason_id, status_id, reported_at) VALUES
(3, 6, 3, 3, '2025-04-17');


SELECT * FROM Reports;


-- TRANSACTIONS
-- 1. Register a new member and post a blog
START TRANSACTION;

INSERT INTO Members (member_name, email, doj)
VALUES ('John Doe', 'john.doe@example.com', '2024-04-25');

INSERT INTO Blog (author_id, title)
VALUES (LAST_INSERT_ID(), 'My First Blog');

COMMIT;

-- Output
SELECT * FROM Members WHERE email = 'john.doe@example.com';
SELECT * FROM Blog WHERE title = 'My First Blog';

-- 2. Add a blog and rollback if the title is too short
START TRANSACTION;

INSERT INTO Blog (author_id, title)
VALUES (12, 'AICTE');  -- Title too short

ROLLBACK;

-- Output (should return nothing)
SELECT * FROM Blog WHERE title = 'AICTE';


--  3. Savepoint: insert feedback, rollback reaction
START TRANSACTION;

SAVEPOINT before_feedback;

INSERT INTO Feedback (blog_id, member_id)
VALUES (6, 12);

SAVEPOINT before_reaction;

INSERT INTO Reactions (blog_id, member_id)
VALUES (6, 12);

ROLLBACK TO before_reaction;
COMMIT;

-- Output
SELECT * FROM Feedback WHERE blog_id = 6 AND member_id = 12; 
SELECT * FROM Reactions WHERE blog_id = 6 AND member_id = 12;  -- Should be empty


-- 4. Insert announcement & announce, rollback if FK fails
START TRANSACTION;

INSERT INTO Announcements (title, expires_at, created_by)
VALUES ('Downtime Notice', '2025-06-01', 1);

-- Intentional FK error
INSERT INTO Announces (admin_id, announcement_id, announcement_type)
VALUES (999, LAST_INSERT_ID(), 'Downtime');

ROLLBACK;

-- Output (should return nothing)
SELECT * FROM Announcements WHERE title = 'Downtime Notice';
SELECT * FROM Announces WHERE announcement_type = 'Downtime';

-- 5. Save draft, then post blog
START TRANSACTION;

INSERT INTO Drafts (author_id)
VALUES (13);

SAVEPOINT after_draft;

INSERT INTO Blog (author_id, title)
VALUES (13, 'From Draft to Reality');

COMMIT;

-- Output
SELECT * FROM Drafts WHERE author_id = 13;
SELECT * FROM Blog WHERE title = 'From Draft to Reality';

-- 6. Update blog title and rollback on invalid change
START TRANSACTION;

UPDATE Blog
SET title = 'AI'
WHERE blog_id = 1;

-- Assuming trigger rejects, so manually rollback
ROLLBACK;

-- Output: Should show original title
SELECT * FROM Blog WHERE blog_id = 1;

-- 7. Bookmark and react to blog
START TRANSACTION;

INSERT INTO Bookmarks (member_id, blog_id)
VALUES (12, 6);

INSERT INTO Reactions (blog_id, member_id)
VALUES (6, 12);

COMMIT;

-- Output
SELECT * FROM Bookmarks WHERE member_id = 12 AND blog_id = 6;
SELECT * FROM Reactions WHERE blog_id = 6 AND member_id = 12;

-- 8. Insert multiple labels, rollback one
START TRANSACTION;

SAVEPOINT initial;

INSERT INTO Labels () VALUES ();
INSERT INTO Labels () VALUES ();

ROLLBACK TO initial;

COMMIT;
-- Output (Should return nothing new from this block)
SELECT * FROM Labels ORDER BY label_id DESC LIMIT 2;

 -- 9. Member adds blog, bookmarks it, and gives feedback (all-or-nothing)
 START TRANSACTION;

-- Step 1: Add a blog
INSERT INTO Blog (author_id, title)
VALUES (12, 'Transactional Blogging');

-- Step 2: Bookmark the blog
INSERT INTO Bookmarks (member_id, blog_id)
VALUES (12,7);

-- Save the blog_id for feedback
SET @last_blog_id = 7;

-- Step 3: Provide feedback
INSERT INTO Feedback (blog_id, member_id)
VALUES (@last_blog_id, 12);

COMMIT;

-- Output
SELECT * FROM Blog WHERE title = 'Transactional Blogging';
SELECT * FROM Bookmarks WHERE member_id = 12 AND blog_id = @last_blog_id;
SELECT * FROM Feedback WHERE blog_id = @last_blog_id AND member_id = 12;

-- 10. Add a new category and assign it to a blog
START TRANSACTION;

-- Step 1: Add a new category
INSERT INTO Categories (name)
VALUES ('AI & Robotics');

-- Step 2: Try to assign this category to a non-existent blog to simulate error
INSERT INTO BlogCategories (blog_id, category_id, assigned_by)
VALUES (6, LAST_INSERT_ID(), 'Admin');  -- blog_id = 999 likely doesn't exist

-- If this fails, everything rolls back
ROLLBACK;

-- Output
SELECT * FROM Categories WHERE name = 'AI & Robotics';
SELECT * FROM BlogCategories WHERE blog_id = 6;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Student_Submissions;
TRUNCATE TABLE Attempts;
TRUNCATE TABLE Questions;
TRUNCATE TABLE Vocabulary;
TRUNCATE TABLE Grammar_Structures;
TRUNCATE TABLE Quizzes;
TRUNCATE TABLE Lessons;
TRUNCATE TABLE Students;
TRUNCATE TABLE Classes;
TRUNCATE TABLE Levels;
TRUNCATE TABLE Teacher;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO Levels (Level, CLP_Required, Description) VALUES
(1, 100, 'A1'),
(2, 250, 'A1'),
(3, 500, 'A2'),
(4, 800, 'A2'),
(5, 1200, 'B1'),
(6, 1200, 'B1'),
(7, 1500, 'B2'),
(8, 1500, 'B2'),
(9, 1500, 'B2'),
(10, 2600, 'B2'),
(11, 8000, 'C1'),
(12, 20000, 'C1'),
(13, 10000000, 'C2');

-- 2. Bang Teacher: Doi ngu giang vien
INSERT INTO Teacher (Full_Name, Email) VALUES
('Nguyen Dang Khanh', 'khanhnd@hust.edu.vn'),
('Nguyen Duc Tien', 'tien@hust.edu.vn'),
('Pham Huy Hoang', 'hoang@hust.edu.vn'),
('Vu Duc Vuong', 'vuong@hust.edu.vn');

-- 3. Bang Classes: (KHONG NHAP No_of_Students - Trigger tu dem)
INSERT INTO Classes (Class_Name, Teacher_ID, CEFR_Level) VALUES
('Lop A1 - 1', 1, 'A1'),
('Lop A1 - 2', 1, 'A1'),
('Lop A2 - 1', 2, 'A2'),
('Lop B1 - 1', 3, 'B1'),
('Lop B2 - 1', 4, 'B2'),
('Lop A1 - 3', 1, 'A1'),
('Lop A2 - 2', 2, 'A2'),
('Lop B1 - 2', 3, 'B1'),
('Lop B2 - 2', 4, 'B2'),
('Lop C1 - 1', 1, 'C1'),
('Lop C1 - 2', 2, 'C1'),
('Lop C2 - 1', 3, 'C2'),
('Lop C2 - 2', 4, 'C2');

INSERT INTO Students (Full_Name, Email, Assessment_CEFR) VALUES
('Hoang Tuyen', 'airituyen@hust.edu.vn', 'A1'),        
('Binh Minh', 'binhminh@hust.edu.vn', 'A1'),       
('Tuan Anh', 'kiet@hust.edu.vn', 'A1'),           
('Bay Ta', 'ronaldo@hust.edu.vn', 'A2'),
('Tuan Dat', 'dat@hust.edu.vn', 'A2'),
('Giang A Lu', 'Alu@hust.edu.vn', 'B1'),
('Vinh Lua', 'vinh@hust.edu.vn', 'B2'),
('Ken Chim', 'kenchim@hust.edu.vn', 'C1');



-- ==============================================================================
-- BẢNG LESSONS: 5 Bài giảng theo 5 chủ đề chuyên biệt
-- ==============================================================================
INSERT INTO Lessons (Level_Required, Title, Teacher_ID) VALUES
(1, 'Bai 1: Do an va Thuc uong (Danh tu Dem duoc & Khong dem duoc)', 1), -- Chu de Food & Drinks
(2, 'Bai 2: Thoi quen hang ngay (Trang tu chi tan suat)', 2),             -- Chu de Daily Routines
(3, 'Bai 3: Du lich va Ky nghi (Tuong lai don & Be going to)', 3),        -- Chu de Travel
(4, 'Bai 4: Moi truong & Bao ton (Cau bi dong)', 4),                      -- Chu de Environment
(5, 'Bai 5: Cong viec va Su nghiep (Menh de nhuong bo)', 1);             -- Chu de Work & Careers


-- ==============================================================================
-- BẢNG GRAMMAR_STRUCTURES: Công thức (Content) và Ví dụ (Example tiếng Anh)
-- ==============================================================================
INSERT INTO Grammar_Structures (Lesson_ID, Content, Example) VALUES
-- Bai 1 (Food & Drinks)
(1, 'Noun (Countable) + s/es', 'I have two apples and three eggs.'),
(1, 'Some / Any + Noun', 'Do you have any milk? I need some water.'),
(2, 'S + Adverb of Frequency + V(s/es)', 'She always wakes up early in the morning.'),
(2, 'S + be + Adverb of Frequency + Adj', 'He is usually late for school.'),


(3, 'S + will + V(infinitive)', 'I will travel to Japan next year.'),
(3, 'S + am/is/are + going to + V(infinitive)', 'We are going to book a flight tomorrow.'),


(4, 'S + be + PII + (by O)', 'The trees are planted by students every spring.'),
(4, 'S + should/must + be + PII', 'Plastic bags must be banned immediately.'),

(5, 'Although/Even though + S + V, S + V', 'Although he was tired, he finished the report.'),
(5, 'S + V + in order to / so as to + V(infinitive)', 'She studies hard in order to pass the interview.');


-- ==============================================================================
-- BẢNG VOCABULARY: Chủ đề khớp với Lesson, Example tiếng Anh, Meaning tiếng Việt
-- ==============================================================================
INSERT INTO Vocabulary (Content, Meaning, Example, Lesson_ID) VALUES
-- Bai 1 (Food & Drinks)
('Apple', 'Qua tao', 'I eat an apple every day.', 1),
('Water', 'Nuoc loc', 'Please give me a glass of water.', 1),
('Bread', 'Banh mi', 'She is eating bread for breakfast.', 1),
('Delicious', 'Ngon mieng', 'This pizza is absolutely delicious.', 1),
('Hungry', 'Doi bung', 'I am very hungry right now.', 1),

('Wake up', 'Thuc day', 'I wake up at 6 AM.', 2),
('Breakfast', 'Bua sang', 'We have breakfast together.', 2),
('Usually', 'Thuong xuyen', 'I usually go to bed at 10 PM.', 2),
('Homework', 'Bai tap ve nha', 'He does his homework after school.', 2),
('Shower', 'Tam rua', 'She takes a hot shower in the evening.', 2),

('Luggage', 'Hanh ly', 'Please carry my luggage to the room.', 3),
('Flight', 'Chuyen bay', 'The flight to Paris is delayed.', 3),
('Destination', 'Diem den', 'London is our final destination.', 3),
('Passenger', 'Hanh khach', 'The passenger is waiting at the gate.', 3),
('Book', 'Dat truoc', 'I want to book a hotel room online.', 3),


('Pollution', 'Su o nhiem', 'Air pollution is a serious global problem.', 4),
('Recycle', 'Tai che', 'We must recycle paper and plastic.', 4),
('Environment', 'Moi truong', 'Protect the environment for our future.', 4),
('Destroy', 'Pha huy', 'Deforestation destroys animal habitats.', 4),
('Global warming', 'Hien tuong nong len toan cau', 'Global warming melts the ice in the Arctic.', 4),

('Colleague', 'Dong nghiep', 'My colleague is very supportive and kind.', 5),
('Salary', 'Muc luong', 'He earns a high salary in that IT company.', 5),
('Promote', 'Thang chuc', 'She was promoted to team manager last week.', 5),
('Resign', 'Tu chuc', 'The CEO decided to resign after the scandal.', 5),
('Interview', 'Cuoc phong van', 'I have a job interview tomorrow morning.', 5);


-- ==============================================================================
-- BẢNG QUIZZES: Khởi tạo 5 bài thi cho 5 Lesson mới
-- ==============================================================================
INSERT INTO Quizzes (Lesson_ID, Minimum_Pass_Score, Possible_Points) VALUES 
(1, 0, 150),    -- Quiz ID=5 (Bai 6): 3 cau, Quy 150d
(2, 0, 150),    -- Quiz ID=6 (Bai 7): 3 cau, Quy 150d
(3, 0, 300),    -- Quiz ID=7 (Bai 8): 3 cau, Quy 300d
(4, 0, 450),    -- Quiz ID=8 (Bai 9): 3 cau, Quy 450d
(5, 0, 600);   -- Quiz ID=9 (Bai 10): 3 cau, Quy 600d


-- ==============================================================================
-- BẢNG QUESTIONS: Nội dung test bám sát Vocabulary và Grammar vừa học
-- ==============================================================================
INSERT INTO Questions (Quiz_ID, Content, Correct_Answer) VALUES 
(1, 'Dien vao cho trong: I drink a glass of ___ every morning. chili/water/orange', 'water'),
(1, 'Dien vao cho trong: Do you have ___ eggs in the fridge? any/many/few', 'any'),
(1, 'Tu trai nghia voi "Hungry" (doi bung) la gi? full/empty/alone', 'full'),


(2, 'Dien vao cho trong: She ___ goes to the gym on weekends. usually/do not/loves', 'usually'),
(2, 'Toi an bua sang luc 7 gio: I have ___ at 7 AM.', 'breakfast'),
(2, 'Chon the dung cua dong tu: He (watch) TV every night.', 'watches'),

(3, 'Nhin nhung dam may den kia! It ___ going to rain.', 'is'),
(3, 'Toi se xach hanh ly giup ban: I ___ help you with your luggage.', 'will'),
(3, 'Tu dong nghia cua "Luggage" (hanh ly) la gi? baggage/bag/suitcase', 'baggage'),


(4, 'Dien vao cho trong (Bi dong): The room ___ cleaned every day.', 'is'),
(4, 'Rac thai phai duoc vut vao thung: The rubbish must ___ thrown in the bin.', 'be'),
(4, 'Tu trai nghia cua "Destroy" (pha huy) la gi? protect/ruin/save', 'protect'),


(5, '___ it was raining heavily, we still went to the meeting.', 'Although'),
(5, 'He saved money in ___ to buy a new laptop.', 'order'),
(5, 'Tu dong nghia cua "Colleague" (dong nghiep) la gi? colleague/coworker/employer', 'coworker');

-- ==============================================================================
-- BẢNG LESSONS: 5 Bài giảng tiếp theo (ID từ 6 đến 10)
-- ==============================================================================
INSERT INTO Lessons (Level_Required, Title, Teacher_ID) VALUES
(1, 'Bai 6: Gia dinh va Ban be (Dong tu To have)', 2),               -- Chu de Family & Friends
(2, 'Bai 7: Mua sam va Quan ao (Cau so sanh)', 3),                   -- Chu de Shopping & Clothes
(3, 'Bai 8: Suc khoe va The hinh (Dong tu khuyet thieu)', 4),        -- Chu de Health & Fitness
(4, 'Bai 9: Cong nghe tuong lai (Tuong lai hoan thanh)', 1),         -- Chu de Technology & Future
(5, 'Bai 10: Van hoa va Xa hoi (Cau dao ngu)', 2);                   -- Chu de Culture & Society


-- ==============================================================================
-- BẢNG GRAMMAR_STRUCTURES: Công thức và Ví dụ cho Bài 6 -> 10
-- ==============================================================================
INSERT INTO Grammar_Structures (Lesson_ID, Content, Example) VALUES
(6, 'S + have/has + Noun', 'I have two brothers and one sister.'),
(6, 'S + do/does not + have + Noun', 'She does not have a car.'),


(7, 'S + V + adj-er / more adj + than + O', 'This shirt is cheaper than that one.'),
(7, 'S + V + the adj-est / the most adj', 'It is the most expensive dress in the store.'),


(8, 'S + should / ought to + V(infinitive)', 'You should drink more water.'),
(8, 'S + had better (not) + V(infinitive)', 'You had better not eat too much fast food.'),


(9, 'S + will have + PII', 'By next year, they will have launched the new AI.'),
(9, 'S + will be + V-ing', 'At 8 PM tomorrow, I will be playing a VR game.'),


(10, 'Never / Rarely / Seldom + auxiliary + S + V', 'Rarely do we see such a beautiful traditional festival.'),
(10, 'Not only + auxiliary + S + V + but also + ...', 'Not only did he learn the language, but he also embraced the culture.');


-- ==============================================================================
-- BẢNG VOCABULARY: Từ vựng Bài 6 -> 10
-- ==============================================================================
INSERT INTO Vocabulary (Content, Meaning, Example, Lesson_ID) VALUES

('Parents', 'Bo me', 'My parents live in a small town.', 6),
('Sibling', 'Anh chi em ruot', 'Do you have any siblings?', 6),
('Relative', 'Nguoi ho hang', 'All my relatives gathered for dinner.', 6),
('Marry', 'Ket hon', 'They plan to marry next spring.', 6),
('Childhood', 'Tuoi tho', 'I had a very happy childhood.', 6),


('Discount', 'Giam gia', 'I bought this jacket at a 50% discount.', 7),
('Receipt', 'Hoa don', 'Please keep the receipt for returns.', 7),
('Customer', 'Khach hang', 'The store offers great customer service.', 7),
('Try on', 'Thu quan ao', 'Can I try on these shoes?', 7),
('Cashier', 'Thu ngan', 'You can pay the cashier over there.', 7),


('Disease', 'Can benh', 'Regular exercise helps prevent heart disease.', 8),
('Exercise', 'Tap the duc', 'He does exercise every morning.', 8),
('Medicine', 'Thuoc men', 'Take this medicine twice a day.', 8),
('Symptom', 'Trieu chung', 'Fever is a common symptom of the flu.', 8),
('Recover', 'Phuc hoi', 'It took her a week to recover from the illness.', 8),


('Artificial Intelligence', 'Tri tue nhan tao', 'Artificial Intelligence is changing the world.', 9),
('Virtual Reality', 'Thuc te ao', 'He plays games using a Virtual Reality headset.', 9),
('Innovate', 'Doi moi', 'Companies must innovate to survive.', 9),
('Breakthrough', 'Buoc dot pha', 'Scientists made a major breakthrough in medicine.', 9),
('Obsolete', 'Loi thoi', 'Flip phones are now completely obsolete.', 9),


('Heritage', 'Di san', 'We must preserve our cultural heritage.', 10),
('Custom', 'Phong tuc', 'It is a local custom to bow when greeting.', 10),
('Diversity', 'Su da dang', 'The city is known for its cultural diversity.', 10),
('Integration', 'Su hoi nhap', 'Global integration brings both challenges and opportunities.', 10),
('Stereotype', 'Khuon mau, dinh kien', 'We should avoid making judgments based on stereotypes.', 10);


-- ==============================================================================
-- BẢNG QUIZZES: 5 bài thi cho Lesson 6 -> 10
-- ==============================================================================
INSERT INTO Quizzes (Lesson_ID, Minimum_Pass_Score, Possible_Points) VALUES 
(6, 0, 150),    -- Quiz ID=6 (Bai 6)
(7, 0, 150),    -- Quiz ID=7 (Bai 7)
(8, 0, 300),    -- Quiz ID=8 (Bai 8)
(9, 0, 450),    -- Quiz ID=9 (Bai 9)
(10, 0, 600);   -- Quiz ID=10 (Bai 10)


-- ==============================================================================
-- BẢNG QUESTIONS: Nội dung test cho Quiz 6 -> 10
-- ==============================================================================
INSERT INTO Questions (Quiz_ID, Content, Correct_Answer) VALUES 

(6, 'Dien vao cho trong: I ___ two sisters and one brother.', 'have'),
(6, 'Dien vao cho trong: She ___ not have a pet.', 'does'),
(6, 'Tu dong nghia cua "Relative" (nguoi ho hang) la gi? family/sibling/parents/friends', 'family'),


(7, 'This jacket is ___ than the black one.', 'cheaper'),
(7, 'It is the ___ beautiful dress here.', 'most'),
(7, 'Ban can giu ___ de doi tra hang (Hoa don).', 'receipt'),


(8, 'You ___ see a doctor if you feel sick.', 'should'),
(8, 'He had ___ not stay up late.', 'better'),
(8, 'Tu trai nghia cua "Recover" (phuc hoi) la gi? worsen/improve/decline', 'improve'),


(9, 'By 2030, they will ___ built a new smart city.', 'have'),
(9, 'At 10 AM tomorrow, we will be ___ the new software.', 'testing'),
(9, 'Tu trai nghia cua "Obsolete" (loi thoi, cu ky) la gi? modern/ancient/contemporary', 'modern'),


(10, 'Rarely ___ she go out after dark.', 'does'),
(10, 'Not ___ did they win, but they also broke the record.', 'only'),
(10, 'Tu dong nghia cua "Custom" (phong tuc) la gi? custom/tradition/heritage', 'tradition');
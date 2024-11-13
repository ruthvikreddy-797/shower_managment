-- Create the Floors table to define each floor in the building
CREATE TABLE Floors (
    floor_id INT PRIMARY KEY,
    floor_number INT UNIQUE
);

-- Insert sample data into Floors table (assuming 3 floors)
INSERT INTO Floors (floor_id, floor_number) VALUES 
(1, 1), 
(2, 2), 
(3, 3);

-- Create the Students table to store student details, using room and bed numbers, and assigning each student to a floor
CREATE TABLE Students (
    room_number INT,
    bed_number INT,
    name VARCHAR(50) NOT NULL,
    floor_id INT,
    PRIMARY KEY (room_number, bed_number),
    FOREIGN KEY (floor_id) REFERENCES Floors(floor_id)
);

-- Insert sample data into Students table, assuming each room has 4 beds, and assigning students to floors
INSERT INTO Students (room_number, bed_number, name, floor_id) VALUES 
(101, 1, 'John Doe', 1), 
(101, 2, 'Jane Smith', 1), 
(101, 3, 'Emily Johnson', 1), 
(101, 4, 'Michael Brown', 1),
(102, 1, 'Alice Williams', 2), 
(102, 2, 'David Wilson', 2), 
(102, 3, 'Chris Miller', 2), 
(102, 4, 'Sarah Davis', 2),
(103, 1, 'Robert White', 3),
(103, 2, 'Laura Green', 3),
(103, 3, 'James Brown', 3),
(103, 4, 'Sophia Black', 3);

-- Create the Stalls table to define each bathroom stall on each floor
CREATE TABLE Stalls (
    stall_id INT PRIMARY KEY,
    floor_id INT,
    stall_number INT,
    FOREIGN KEY (floor_id) REFERENCES Floors(floor_id)
);

-- Insert data for 8 stalls per floor, assuming each floor has exactly 8 stalls
INSERT INTO Stalls (stall_id, floor_id, stall_number) VALUES
(1, 1, 1), (2, 1, 2), (3, 1, 3), (4, 1, 4), (5, 1, 5), (6, 1, 6), (7, 1, 7), (8, 1, 8),
(9, 2, 1), (10, 2, 2), (11, 2, 3), (12, 2, 4), (13, 2, 5), (14, 2, 6), (15, 2, 7), (16, 2, 8),
(17, 3, 1), (18, 3, 2), (19, 3, 3), (20, 3, 4), (21, 3, 5), (22, 3, 6), (23, 3, 7), (24, 3, 8);

-- Create the TimeSlots table to store each 15-minute time slot from 5:30 AM to 8:00 AM
CREATE TABLE TimeSlots (
    time_slot TIME PRIMARY KEY
);

-- Insert 15-minute time slots from 5:30 AM to 8:00 AM
INSERT INTO TimeSlots (time_slot) VALUES 
('05:30:00'), ('05:45:00'), 
('06:00:00'), ('06:15:00'), ('06:30:00'), ('06:45:00'),
('07:00:00'), ('07:15:00'), ('07:30:00'), ('07:45:00'),
('08:00:00');

-- Create the Bookings table to store each booking entry
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    room_number INT,
    bed_number INT,
    stall_id INT,
    booking_date DATE,
    time_slot TIME,
    FOREIGN KEY (room_number, bed_number) REFERENCES Students(room_number, bed_number),
    FOREIGN KEY (stall_id) REFERENCES Stalls(stall_id),
    FOREIGN KEY (time_slot) REFERENCES TimeSlots(time_slot),
    UNIQUE (stall_id, booking_date, time_slot),
    
    -- Constraint to ensure the student's floor matches the stall's floor
    CHECK ((SELECT floor_id FROM Students WHERE Students.room_number = room_number AND Students.bed_number = bed_number) = 
           (SELECT floor_id FROM Stalls WHERE Stalls.stall_id = stall_id))
);

-- Example insert into Bookings (assuming the student and stall exist)
INSERT INTO Bookings (room_number, bed_number, stall_id, booking_date, time_slot)
VALUES (101, 1, 1, '2024-11-15', '05:30:00');

-- Sample query to check availability: 
-- List all time slots with their booking status for a specific stall on a given date
SELECT t.time_slot, 
       IF(b.booking_id IS NULL, 'Available', 'Booked') AS status
FROM TimeSlots t
LEFT JOIN Bookings b 
ON t.time_slot = b.time_slot 
   AND b.booking_date = '2024-11-15' 
   AND b.stall_id = 1;
